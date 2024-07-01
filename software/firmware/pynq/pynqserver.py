import os
import sys
import logging
import socket
import time
import pickle
from pathlib import Path
import numpy as np
from pynq import Overlay
from pynq import allocate
from pynq import Clocks
from pynq_drivers.config.pynq_conf import IP, PORT, OVERLAY_FILE, FOBOS_HOME
sys.path.append(f"{FOBOS_HOME}/software/")
import foboslib as fb
# from foboslib.capture.ctrl.fb import fb
from pynq_drivers.pynqlocal import PYNQCtrl
from pynq_drivers.openadc2 import OpenADCScope2
from pynq_drivers.power import PowerManager

#import numpy as np
MSG_LEN_SIZE    = 10
OPCODE_SIZE     = 4
STATUS_SIZE     = 4
DONE_CMD        = 9999
RCV_BYTES       = 512
SOCKET_TIMEOUT  = 10 # seconds
##change these settings. they must be dynamic
TV_SIZE         = 48
OUTPUT_SIZE     = 16

OUT_LEN         = 16 # default aes-128 output in byes
TRACE_NUM       = 10
SAMPLING_FREQ   = 10
DUT_CLK         = 1
SAMPLE_NUM      = 1000
ADC_GAIN        = 20
ADC_HILO        = 22
TV_SIZE         = 48 #108
OUTPUT_SIZE     = 16 #44
STATUS_FILE     = "/tmp/fobos_status.txt"
EXIT_FILE       = "/tmp/fobos_exit"
LOG_FILE        = "/tmp/fobos.log"
MAX_START_RETRIES = 15
RETRY_WAIT      = 10

class server():
    def __init__(self, ip, port):
        logging.basicConfig(filename=LOG_FILE, filemode='w', level=logging.INFO,
                            format='%(asctime)s %(name)s - %(levelname)s - %(message)s')
        self.logger = logging.getLogger('FOBOS server')
        self.logger.info("Fobos server starting ...")
        if os.path.isfile(EXIT_FILE):
            os.remove(EXIT_FILE)
        self.interface = fb.INTERFACE_4BIT
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        for i in range(MAX_START_RETRIES):
            try:
                self.logger.info(f'Attempting address binding. ip={ip} port={port}')
                self.socket.bind((ip, port))
                self.socket.listen(5)
                self.logger.info(f'Address binding succeeded.')
                break
            except:
                if i == MAX_START_RETRIES-1:
                    self.logger.error(f'Address binding failed. Exiting ...')
                    exit(1)
                self.logger.info(f'Address binding failed. Retrying in {RETRY_WAIT} seconds ...')
                time.sleep(RETRY_WAIT)

    def resetAll(self):
        print("Loading Overlay: ",OVERLAY_FILE)
        overlay = Overlay(OVERLAY_FILE)
        print(dir(overlay))
        print("Bus clock = ",Clocks.fclk0_mhz)
        Clocks.fclk0_mhz=100
        print("Bus clock = ",Clocks.fclk0_mhz)
        self.ctrl = PYNQCtrl(overlay)
        self.fobosAcq = OpenADCScope2(overlay)
        self.led = overlay.user_led_0
        self.led.write(0,4)
        self.powerManager = PowerManager(overlay)
        self.samplesPerTrace = SAMPLE_NUM
        self.outputBuffer = allocate(shape=(int(self.samplesPerTrace / 4 + 2),), dtype=np.uint64)
        #Configure defaults
        self.ctrl.setDUTClk(DUT_CLK)
        self.ctrl.setOutLen(OUT_LEN)
        self.ctrl.setTriggerMode(fb.TRG_FULL)
        self.ctrl.setDUTInterface(self.interface)
        self.ctrl.forceReset()
        self.ctrl.releaseReset()
        self.logger.info("Overlay reloaded. Control board reset complete.")
    
    def sendResponse(self, status, responseMsg):
        self.logger.debug(f'send respnse: status={status}, response={responseMsg}')
        msg = bytes(f'{len(responseMsg) + STATUS_SIZE :<{MSG_LEN_SIZE}}' + f'{status:<{STATUS_SIZE}}', 'utf-8') + responseMsg
        try:
            self.clt.send(msg)
            status = 0
        except:
            print("error sending message")
            self.clt.close()
            status = -1
        return status

    def recvMsg(self):
        opcode = -1
        param = ""
        full_msg = b''
        new_msg = True
        while True:
            try:
                msg = self.clt.recv(RCV_BYTES)
            except:
                self.logger.error('Error while receiving message')
                opcode = -2
                return opcode, param
            if new_msg:
                self.logger.debug(f'New msg size is {msg[:MSG_LEN_SIZE]}')
                new_msg = False
                try:
                    msg_len = int(msg[:MSG_LEN_SIZE])
                except:
                    self.logger.debug("Illegal message size")
                    opcode = -1
                    param = ""
                    return opcode, param
            full_msg += msg
            if len(full_msg) - MSG_LEN_SIZE ==msg_len:
                try:
                    opcode = int(full_msg[MSG_LEN_SIZE : MSG_LEN_SIZE + STATUS_SIZE])
                    param = pickle.loads(full_msg[MSG_LEN_SIZE + STATUS_SIZE:])
                    break
                except:
                    self.logger.debug("Error with message opcode or paramter")
                    opcode  = -1
                    param = ""
                    return opcode, param
        if opcode in [fb.PROCESS, fb.PROCESS_GET_TRACE]:
            print(f'tv len = {len(param)}')
            param = param.rstrip()
        else:
            if not isinstance(param, int):
                print(f"Integer expected as a parameter for opcode {opcode}")
                opcode  = -1
                param = 0
                return opcode, param
        self.logger.debug(f'msg_len={msg_len}, opcode={opcode}, param={param}')
        return opcode, param
    
    def closeRequested(self):
        if os.path.isfile(EXIT_FILE):
            os.remove(EXIT_FILE)
            return True
        return False
    
    def acceptConnection(self):
        self.socket.settimeout(SOCKET_TIMEOUT)
        while True:
            if self.closeRequested():
                return False
            try:
                self.clt, addr = self.socket.accept()
                self.logger.info(f'Connection established. addr = {addr}')
                return True
            except:
                self.logger.debug(f'Socket accept timeout.')
                self.touchStatusFile()

    def run(self):
        while True:
            self.logger.info("Fobos server ready. Waiting for connection ...")
            if not self.acceptConnection():
                self.logger.info("Recieved close command. Exitting ...")
                break
            self.resetAll()

            while True:
                opcode, param = self.recvMsg()
                self.touchStatusFile()
                self.logger.debug(f'msg received : opcode={opcode}, param = {param}')
                if int(opcode) == fb.DISCONNECT:
                    self.fobosAcq.setGain(0) #clear ADC gain
                    self.sendResponse(0, pickle.dumps("Disconnect requested. Bye!"))
                    self.led.write(0,0)
                    self.clt.close()
                    self.logger.info(f'Client done. Connection closed')
                    break
                elif int(opcode) == -1:
                    self.sendResponse(1, pickle.dumps("Illegal message received. Ignored."))
                    self.logger.error(f'Illegal message received.')
                    continue
                elif int(opcode) == -2:
                    self.logger.error("Cannot receive message due to socket error. Closing connection")
                status, response = self.doOperation(int(opcode), param)
                status = self.sendResponse(status, pickle.dumps(response))
                if status == -1:
                    self.logger.error('Could not send respose to client. Closing connection')
                    self.clt.close()
                    break

    def touchStatusFile(self):
        Path(STATUS_FILE).touch()

    def doOperation(self, opcode, param):
        status = 0
        response = ''
        try:
            if opcode == fb.PROCESS:
                tvLen = len(param)
                if tvLen != 0 and tvLen % 4 == 0:
                    self.logger.debug(f'action = PROCESS. param = {param}')
                    result = self.ctrl.processData(param)
                    response = result
                else:
                    self.logger.error(f'Invalid test vector length: {tvLen}')
                    status = fb.ERR_TV_LEN_INVALID
                    response = fb.ERR_MSGS[status]
            elif opcode == fb.PROCESS_GET_TRACE:
                tvLen = len(param)
                if tvLen != 0 and tvLen % 4 == 0: 
                    self.logger.debug(f'action = PROCESS. param = {param}')
                    self.fobosAcq.arm()
                    result = self.ctrl.processData(param)
                    trace = self.fobosAcq.getTrace()
                    response = (result, trace,)
                    # response = result
                else:
                    self.logger.error(f'Invalid test vector length: {tvLen}')
                    status = fb.ERR_TV_LEN_INVALID
                    response = fb.ERR_MSGS[status]
            elif opcode == fb.SET_DUT_CLK:
                self.logger.info(f'CMD: set DUT clk = {param} KHz')
                status, response = self.ctrl.setDUTClk(param)
                if status==fb.SUCCESS:
                    # DEFAULTS
                    self.ctrl.setOutLen(OUT_LEN)
                    self.ctrl.setTriggerMode(fb.TRG_FULL)
                    self.ctrl.setDUTInterface(self.interface)
                    self.ctrl.forceReset()
                    time.sleep(0.1)
                    self.ctrl.releaseReset()
                    response = f'Set DUT clk = {param//1000} MHz. Defaults restored'
            # Basic settings
            elif opcode == fb.SET_DUT:
                self.logger.info(f'CMD: set DUT = {param}')
                status, response = self.ctrl.setDUT(param)
            elif opcode == fb.SET_DUT_INTERFACE:
                self.logger.info(f'CMD: set DUT interface = {param}')
                status, response = self.ctrl.setDUTInterface(param)
            elif opcode == fb.OUT_LEN:
                self.logger.info(f'CMD: set outLen = {param}')
                status, response = self.ctrl.setOutLen(param)            
            elif opcode == fb.TRG_MODE:
                self.logger.info(f'CMD: set trigger mode = {param}')
                status, response = self.ctrl.setTriggerMode(param)
            elif opcode == fb.TRG_WAIT:
                self.logger.info(f'CMD: set trigger wait = {param}')
                status, response = self.ctrl.setTriggerWait(param)
            elif opcode == fb.TRG_LEN:
                self.logger.info(f'CMD: set trigger mode = {param}')
                status, response = self.ctrl.setTriggerLen(param)
            elif opcode == fb.TIMEOUT:
                self.logger.info(f'CMD: set timeout = {param}')
                status = fb.ERR_NOT_IMPLEMENTED
                response = fb.ERR_MSGS[status]
            elif opcode == fb.FORCE_RST:
                self.logger.info(f'CMD: force DUT reset')
                status, response = self.ctrl.forceReset()
            elif opcode == fb.RELEASE_RST:
                self.logger.info(f'CMD: release DUT reset')
                status, response = self.ctrl.releaseReset()
            # Power glitch settings
            elif opcode == fb.POWER_GLITCH_ENABLE:
                self.logger.info(f'CMD: enable power glitch')
                status = fb.ERR_NOT_IMPLEMENTED
                response = fb.ERR_MSGS[status]
            elif opcode == fb.POWER_GLITCH_WAIT:
                self.logger.info(f'CMD: set power glitch wait')
                status = fb.ERR_NOT_IMPLEMENTED
                response = fb.ERR_MSGS[status]
            elif opcode == fb.POWER_GLITCH_PATTERN0:
                self.logger.info(f'CMD: set power glitch pattern 0')
                status = fb.ERR_NOT_IMPLEMENTED
                response = fb.ERR_MSGS[status]
            elif opcode == fb.POWER_GLITCH_PATTERN1:
                self.logger.info(f'CMD: set power glitch pattern 0')
                status = fb.ERR_NOT_IMPLEMENTED
                response = fb.ERR_MSGS[status]
            # ADC settings
            elif opcode == fb.SET_SAMPLING_FREQ:
                self.logger.info(f'CMD: set sampling frequency')
                status, response = self.fobosAcq.setAdcClockFreq(param)
            elif opcode == fb.SET_ADC_GAIN:
                self.logger.info(f'CMD: set ADC gain')
                status, response = self.fobosAcq.setGain(param)
            elif opcode == fb.SET_ADC_HILO:
                self.logger.info(f'CMD: set ADC hi/low,{param}')
                status, response = self.fobosAcq.setHiLo(param)
            elif opcode == fb.SET_SAMPLES_PER_TRACE:
                self.logger.info(f'CMD: samples per trace  = {param}')
                status, response = self.fobosAcq.setSamplesPerTrace(param)
            # powe manager setting
            elif opcode == fb.PWMGR_SET_GAIN_VAR:
                response = f"Set var gain  = {param}"
                print(response)
                self.powerManager.GainVarSet(param)
            elif opcode == fb.PWMGR_GET_GAIN_VAR:
                gain = self.powerManager.GainVarGet()
                response = f"Get var gain = {gain}"
            elif opcode == fb.PWMGR_GET_VOLT_VAR:
                volt = self.powerManager.MeasVoltVar()
                response = f"Get var gain = {volt}"
            elif opcode == fb.PWMGR_GET_CURR_VAR:
                curr = self.powerManager.MeasCurrVar()
                response = f"Get var gain = {curr}"
            elif opcode == fb.PWMGR_SET_HW_TRIG:
                self.powerManager.TrigHwEnOn()
                response = f'Set hardware trig enabled'
            elif opcode == fb.PWMGR_CLEAR_HW_TRIG:
                self.powerManager.TrigHwEnOff()
                response = f'Set hardware trig disabled'            
            elif opcode == fb.PWMGR_SET_SW_TRIG:       
                self.powerManager.TrigSwEnOn()
                response = f'Set software trig enabled'
            elif opcode == fb.PWMGR_CLEAR_SW_TRIG:
                self.powerManager.TrigSwEnOff()
                response = f'Set software trig disabled'
            elif opcode == fb.PWMGR_RESET:
                self.powerManager.Reset()
                response = f'Power manager reset'    
            elif opcode == fb.PWMGR_CLEAR_MEASUREMENTS:
                self.powerManager.MeasClear()
                response = f'Measurement registers cleared'
            elif opcode == fb.PWMGR_STAT_HW_TRIG:
                stat = self.powerManager.TrigHwStat()
                response = f"Get var gain = {stat}"
            elif opcode == fb.PWMGR_GET_COUNT:
                count = self.powerManager.MeasCountValue()
                response = f"Get measure count = {count}"
            elif opcode == fb.PWMGR_CHECK_OVERFLOW:
                overflow = self.powerManager.MeasCountOverflow()
                response = f"Get var gain = {overflow}"
            elif opcode == fb.PWMGR_CHECK_BUSY:
                busy = self.powerManager.MeasBusy()
                response = f"Get var gain = {busy}"
            elif opcode == fb.PWMGR_MAX_VOLT_VAR:
                volt = self.powerManager.MeasMaxVoltVar()
                response = f"Get var gain = {volt}"
            elif opcode == fb.PWMGR_AVG_VOLT_VAR:
                volt = self.powerManager.MeasAvgVoltVar()
                response = f"Get var gain = {volt}"
            elif opcode == fb.PWMGR_MAX_CURR_VAR:
                curr = self.powerManager.MeasMaxCurrVar()
                response = f"Get var gain = {curr}"
            elif opcode == fb.PWMGR_AVG_CURR_VAR:
                curr = self.powerManager.MeasAvgCurrVar()
                response = f"Get var gain = {curr}"
            elif opcode == fb.fb_GET_DUT_CYCLES:
                cc = self.ctrl.getWorkCount()
                response = f"Get work count = {cc}"
            ### Untested:
            elif opcode == fb.PWMGR_SET_GAIN_3V3:
                val = self.powerManager.Gain3v3Set(param)
                response = f"set 3v3 gain = {param}"
            elif opcode == fb.PWMGR_GET_GAIN_3V3:
                val = self.powerManager.Gain3v3Get()
                response = f"set 3v3 gain = {val}"        
            elif opcode == fb.PWMGR_GET_VOLT_3V3:
                val = self.powerManager.MeasVolt3v3()
                response = f"Get Volt 3v3 = {val}"
            elif opcode == fb.PWMGR_GET_CURR_3V3:
                val = self.powerManager.MeasCurr3v3()
                response = f"Get Curr 3v3 = {val}"
            elif opcode == fb.PWMGR_MAX_VOLT_3V3:
                val = self.powerManager.MeasMaxVolt3v3()
                response = f"Get Max Volt 3v3 = {val}"
            elif opcode == fb.PWMGR_AVG_VOLT_3V3:
                val = self.powerManager.MeasAvgVolt3v3()
                response = f"Get Max Avg 3v3 = {val}"
            elif opcode == fb.PWMGR_MAX_CURR_3V3:
                val = self.powerManager.MeasMaxCurr3v3()
                response = f"Get Max Curr 3v3 = {val}"
            elif opcode == fb.PWMGR_AVG_CURR_3V3:
                val = self.powerManager.MeasAvgCurr3v3()
                response = f"Get Max Curr 3v3 = {val}"
            elif opcode == fb.PWMGR_SET_GAIN_5V:
                val = self.powerManager.Gain5vSet(param)
                response = f"set = {param}"
            elif opcode == fb.PWMGR_GET_GAIN_5V:
                val = self.powerManager.Gain5vGet()
                response = f"set 5v gain = {val}"
            elif opcode == fb.PWMGR_GET_VOLT_5V:
                val = self.powerManager.MeasVolt5v()
                response = f"Get Volt 5v = {val}"
            elif opcode == fb.PWMGR_GET_CURR_5V:
                val = self.powerManager.MeasCurr5v()
                response = f"Get Curr 5v = {val}"
            elif opcode == fb.PWMGR_MAX_VOLT_5V:
                val = self.powerManager.MeasMaxVolt5v()
                response = f"Get Max Volt 5v = {val}"
            elif opcode == fb.PWMGR_AVG_VOLT_5V:
                val = self.powerManager.MeasAvgVolt5v()
                response = f"Get Max Avg 5v = {val}"
            elif opcode == fb.PWMGR_MAX_CURR_5V:
                val = self.powerManager.MeasMaxCurr5v()
                response = f"Get Max Curr 5v = {val}"
            elif opcode == fb.PWMGR_AVG_CURR_5V:
                val = self.powerManager.MeasAvgCurr5v()
                response = f"Get Max Curr 5v = {val}"
            elif opcode == fb.PWMGR_STAT_SW_TRIG:
                val = self.powerManager.TrigSwStat()
                response = f"SW trig stat = {val}"
            elif opcode == fb.PWMGR_SET_VAR_ON:
                val = self.powerManager.OutVarOn()
                response = f"Out var on"
            elif opcode == fb.PWMGR_SET_VAR_OFF:
                val = self.powerManager.OutVarOff()
                response = f"Out var off"
            elif opcode == fb.PWMGR_SET_VAR_VOLT:
                val = self.powerManager.OutVarSet(float(param))
                response = f"set = {param}"
            else:
                status = fb.ERR_NOT_IMPLEMENTED
                response = fb.ERR_MSGS[status]
            # Error handling
            if status !=fb.SUCCESS:
                errorMessage = fb.ERR_MSGS[status]
                self.logger.error(f'RESPONSE: status={status}, msg: response={errorMessage}')
                return status, errorMessage
            elif opcode not in [fb.PROCESS, fb.PROCESS_GET_TRACE]:
                self.logger.info(f'RESPONSE: status={status}, msg: response={response}')
                return status, response
            else:
                self.logger.debug(f'RESPONSE: status={status}, msg: response={response}')
                return status, response

        except Exception as e:
            import traceback
            traceback.print_exc()
            self.logger.error(f'Error: Unhandeled exception')
            status = -1
            response = "Unhandeled exception"
            return status, response

s = server(IP, PORT)
s.run()
