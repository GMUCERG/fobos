#############################################################################
#                                                                           #
#   Copyright 2020 CERG                                                     #
#                                                                           #
#   Licensed under the Apache License, Version 2.0 (the "License");         #
#   you may not use this file except in compliance with the License.        #
#   You may obtain a copy of the License at                                 #
#                                                                           #
#       http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                           #
#   Unless required by applicable law or agreed to in writing, software     #
#   distributed under the License is distributed on an "AS IS" BASIS,       #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
#   See the License for the specific language governing permissions and     #
#   limitations under the License.                                          #
#                                                                           #
#############################################################################
# FOBOS PYNQ control board class
# Author: Abubakr Abdulgadir
# GMU
# Feb 25 2020
# This class hides the Control Board hardware and provides easy to use
# methods to configure and run operations on the DUT
# This class will interface to a PYNQ Z-1 board
# The board includes an ARM Cortex A9 processor
# This uses a protocol to talk to the PYNQ board
# The connection used is a gigabit ethernet connection

import socket
import pickle
import numpy as np
import select
from sys import exit
from .fobosctrl import FOBOSCtrl
from .hardware_mgr import HardwareManager

RCV_BYTES = 512

class PYNQCtrl(FOBOSCtrl):
    """
    Class to wrap protocol to interface with PYNQ controller.
    """

    def __init__(self, ip, port= 9999):
        """Init method
        Parameters:
        -----
        ip   : string
            PYNQ ip address.
        port : int
            port where PYNQ server is listening.
        """
        # get hardware
        self.hm = HardwareManager()
        if self.hm.lock():
            print('Acquired hardware lock')
        else:
            raise SystemExit('Hardware is in use by another user, please try again later. Exiting')

        self.magic = '20200225'
        self.outLen = 0
        self.MSG_LEN_SIZE = 10
        self.STATUS_SIZE = 4
        self.OPCODE_SIZE = 4
        self.timeToReset = 0
        self.RECV_TIMEOUT = 1
        # error codes
        # self.OK = bytearray([0x00, 0x00, 0x00, 0x00])
        # self.ERROR = bytearray([0x01, 0x00, 0x00, 0x00])
        # self.TIMEOUT = bytearray([0x02, 0x00, 0x00, 0x00])
        self.model = "PYNQ-Z1"
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            # self.socket.setblocking(0)
            self.socket.connect((ip, port))
        except Exception as  e:
            print(e)
            # release hw
            self.hm.unlock()
            raise SystemExit('Could not connect to control board')
        self.config = "# Acquisition parameters:\n"

    def _printResponse(self, opeartion, status, responseMsg):
        print(f'{opeartion}')
        if status != 0:
            print(f'\t\033[91mError\033[0m : {responseMsg}')
        else:
            print(f'\t\033[92mOK\033[0m    : {responseMsg}')

    def _setConf(self, opcode, param, userMsg):
        self.sendMsg(opcode=opcode, param=param)
        status, resposnseMsg = self.recvMsg()
        self._printResponse(userMsg, status, resposnseMsg)
        if status != 0:
            raise SystemExit()
        return status
    
    def detectHardware(self):
        pass

    def sendMsg(self, opcode, param):
        try:
            param = pickle.dumps(param)
            msg = bytes(f'{len(param) + self.OPCODE_SIZE :<{self.MSG_LEN_SIZE}}' + f'{int(opcode):<{self.OPCODE_SIZE}}', 'utf-8') + param
            self.socket.send(msg)
        except Exception as e:
            raise SystemExit('Erorr encountered while sending message. Exitting.')

    def recvMsg(self):
        full_msg = b''
        new_msg = True
        while True:
            try:
                msg = self.socket.recv(RCV_BYTES)
                if new_msg:
                    msg_len = int(msg[:self.MSG_LEN_SIZE])
                    new_msg = False
                full_msg += msg
                if len(full_msg) - self.MSG_LEN_SIZE ==msg_len:
                    status = int(full_msg[self.MSG_LEN_SIZE:self.MSG_LEN_SIZE + self.STATUS_SIZE])
                    response = pickle.loads(full_msg[self.MSG_LEN_SIZE + self.STATUS_SIZE:])
                    break
            except Exception as e:
                status = -1
                response = ""
                break
                
        return status, response

    def processData(self, data, outLen):
        self.sendMsg(FOBOSCtrl.PROCESS, data)
        status, response = self.recvMsg()
        return status, response

    def processData2(self, data, outLen):
        self.sendMsg(FOBOSCtrl.PROCESS_GET_TRACE, data)
        status, response = self.recvMsg()
        # print(response)
        result, trace = response
        trace = np.array(trace, dtype=np.uint16)
        # result = ""
        return status, result, trace

    def getModel(self):
        """
        The model of the control board
        Returns:
        -----
        model: srting
            The model of the control board
        """
        return self.model
    
    def getMagicNumber(self, devFile=None):
        pass

    def setOutLen(self, outLen):
        """
        set Expected Output Length (outLen)
        parameters:
        -----
        outLen : int
            The number of output bytes to be returned by the DUT
            (e.g 16 for AES-128)
        Returns: int
            Status
        """
        self.outLen = outLen
        # print(f'outlen={outLen}')
        self.config += f'OUT_LEN = {outLen}\n'
        self.sendMsg(opcode=FOBOSCtrl.OUT_LEN, param=outLen)
        status, resposnseMsg = self.recvMsg()
        self._printResponse('Setting output length (bytes)', status, resposnseMsg)
        if status != 0:
            raise SystemExit()
        return status

    def setTriggerWait(self, trigWait):
        """
        set number of trigger wait cycles
        parameters:
        -----
        trigWait : int
            The number of DUT cycles after di_ready geos to 0
            to issue the trigger.
        Returns: int
            Status
        """
        self.sendMsg(opcode=FOBOSCtrl.TRIG_WAIT, param=trigWait)
        status, resposnseMsg = self.recvMsg()
        self._printResponse('Setting trigger wait', status, resposnseMsg)
        if status != 0:
            raise SystemExit()
        return status

    def setTriggerLen(self, trigLen):
        """
        set trigger length
        parameters:
        -----
        trigLen : int
            The number of DUT cycles to keep trigger set.
        Returns: int
            Status
        """
        self.sendMsg(FOBOSCtrl.TRG_LEN, trigLen)
        status, resposnseMsg = self.recvMsg()
        self._printResponse('Setting trigger length', status, resposnseMsg)
        if status != 0:
            raise SystemExit()
        return status

    def setTriggerMode(self, trigType):
        """
        set trigger mode
        parameters:
        -----
        trigType : int
            Possible values
            TRG_NORM      = 0
            TRG_FULL      = 1
            TRG_NORM_CLK  = 2
            TRG_FULL_CLK  = 3
        Returns: int
        -----
            Status
        """
        self.sendMsg(FOBOSCtrl.TRG_MODE, trigType)
        status, resposnseMsg = self.recvMsg()
        self._printResponse('Setting trigger mode', status, resposnseMsg)
        if status != 0:
            raise SystemExit()
        return status

    def setTimeToReset(self, dutCycles):
        """
        set number of clock cycles after di_ready goes to 0
        to reset the DUT.
        parameters:
        -----
        dutCycles : int
            The number of DUT cycles to reset the DUT.
        Returns: int
        """
        self.timeToReset = dutCycles
        self.sendMsg(FOBOSCtrl.TIME_TO_RST, dutCycles)
        status, _ = self.recvMsg()
        return status

    def getTimeToReset(self):
        """
        get number of clock cycles after di_ready goes to 0
        to reset the DUT.
        Returns:
        -----
        int
            The number of clock cycle to reset DUT.
        """
        return self.timeToReset

    def setTimeout(self, seconds):
        """
        set number of seconds to stop waiting for DUT result.
        parameters:
        -----
        seconds : int
            Time in seconds. Range 1-40 seconds.
        Returns: int
        """
        self.timeout = seconds
        self.sendMsg(FOBOSCtrl.TIMEOUT, seconds)
        status, _ = self.recvMsg()
        return status

    def enableTestMode(self):
        """
        enable test mode. When this mode is enabled, the controller
        sends test-vectors to its internal dummy DUT.

        Returns:
        -----
        int
            Status
        """
        pass

    def disableTestMode(self):
        """
        Disable test mode. In this mode the ctrl board uses the real DUT.
        This is the default mode.

        Returns:
        -----
        int
            status
        """
        pass

    def forceReset(self):
        """
        Reset DUT

        Returns:
        -----
        int
            status
        """
        self.sendMsg(FOBOSCtrl.FORCE_RST, 0)
        status, _ = self.recvMsg()
        return status

    def releaseReset(self):
        """
        Release  DUT reset signal

        Returns:
        -----
        int
            status
        """
        self.sendMsg(FOBOSCtrl.RELEASE_RST, 0)
        status, _ = self.recvMsg()
        return status


    def setDUTClk(self, clkFreqMHz):
        """
        set DUT clock frequency generated by the control board.
        range is between 1 MHz - 100 MHz.
        parameters:
        -----
        clkFreqMhz : float
            The DUT clock frequency in Mhz
        Returns:
        -----
        int
            status
        """
        clkFreqKHz = int(clkFreqMHz * 1000)
        self.config += f'DUT_CLK = {clkFreqKHz}\n'
        self.sendMsg(FOBOSCtrl.SET_DUT_CLK, clkFreqKHz)
        status, resposnseMsg = self.recvMsg()
        self._printResponse('Setting DUT clk', status, resposnseMsg)
        if status != 0:
            raise SystemExit()

    def loadKey(self, key):
        """
        set the key value in the control board.
        parameters:
        -----
        key : string
            Key to send to ctrl board in hex format
        Returns:
        -----
        int
            status
        """
        self.sendMsg(FOBOSCtrl.SET_KEY, key)
        status, _ = self.recvMsg()
        return status


    def loadData(self, data):
        pass

    def run(self):
        pass

    def getResult(self):
        pass

    def setPowerGlitchEnable(self, val):
        """
        set power glithcer enable bit.
        parameters:
        -----
        val : Integer
            1 = enable, 0 = disable
        Returns:
        -----
        int
            status
        """
        print("enable glitch")
        self.sendMsg(FOBOSCtrl.POWER_GLITCH_ENABLE, val)
        status, _ = self.recvMsg()
        return status

    def setPowerGlitchWait(self, waitCycles):
        """
        set the power glitcher wait cycles.
        parameters:
        -----
        waitCycles : int
            The cycles to wait before relasing the glicth pattern
        Returns:
        -----
        int
            status
        """
        # print("set glitch wait")
        self.sendMsg(FOBOSCtrl.POWER_GLITCH_WAIT, waitCycles)
        status, _ = self.recvMsg()
        return status


    def setPowerGlitchPattern(self, pattern):
        """
        set the power glitch pattern reg
        parameters:
        -----
        pattern : string
            The pattern to set for glitch. The pattern is 64 bits written into 2 registers
        Returns:
        -----
        int
            status
        """
        print("pattern")
        pattern0 = int(pattern[8:16], 16) #lsb
        pattern1 = int(pattern[0:8], 16) #msb
        print('pattern=' + pattern)
        print('pattern0=' + str(pattern0))
        print(pattern[0:7])
        print('pattern1=' + str(pattern1))
        print(pattern[8:15])
        self.sendMsg(FOBOSCtrl.POWER_GLITCH_PATTERN0, pattern0)
        self.sendMsg(FOBOSCtrl.POWER_GLITCH_PATTERN1, pattern1)
        status, _ = self.recvMsg()
        return status

    def disconnect(self):
        self.sendMsg(FOBOSCtrl.DISCONNECT, 0)
        status, response = self.recvMsg()
        # print(response)
        self.socket.close()
        #release lock
        self.hm.unlock()
        return status, response

    def setDUTInterface(self, interface):
        self.sendMsg(FOBOSCtrl.SET_DUT_INTERFACE, interface)
        # status, _ = self.recvMsg()
        status, resposnseMsg = self.recvMsg()
        self._printResponse('Setting DUT interface type', status, resposnseMsg)
        if status != 0:
            raise SystemExit()
        # return status
    
    def setDUT(self, dut):
        self.sendMsg(FOBOSCtrl.SET_DUT, dut)
        status, _ = self.recvMsg()
        return status

    def setSamplingFrequency(self, freqMHz):
        freqKHz = int(freqMHz * 1000)
        # if freq > 100 or freq < 1:
            # raise ValueError("Error: Sampling frequency must be an integer between 1 MHz and 100 MHz")
        self.config += f'SAMPLING_FREQ = {freqMHz}\n'
        return self._setConf(FOBOSCtrl.SET_SAMPLING_FREQ, freqKHz, 'Setting sampling frequency')

        # self.sendMsg(FOBOSCtrl.SET_SAMPLING_FREQ, freq)
        # status, _ = self.recvMsg()
        # return status

    def setADCGain(self, gain):
        gain = int(gain)
        # if gain > 78 or gain < 0:
        #     raise ValueError("Error: ADC gain must be an integer between 0 and 78")
        # self.config += f'ADC_GAIN = {gain}\n'
        # self.sendMsg(FOBOSCtrl.SET_ADC_GAIN, gain)
        # status, _ = self.recvMsg()
        # return status
        self.config += f'ADC_GAIN = {gain}\n'
        return self._setConf(FOBOSCtrl.SET_ADC_GAIN, gain, 'Setting ADC gain')

    def setADCHiLo(self, hilo):
        hilo = int(hilo)
        if hilo > 1 :
            raise ValueError("Error: ADC HiLo must be either '0' or '1'")
        self.config += f'ADC_HiLo = {hilo}\n'
        self.sendMsg(FOBOSCtrl.SET_ADC_HILO, hilo)
        status, _ = self.recvMsg()
        return status
    
    def setSamplesPerTrace(self, samplesPerTrace):
        # if samplesPerTrace > 2**17  or samplesPerTrace < 0:
        #     raise ValueError("Error: SamplesPerTrace must be between 0 and 2**17")
        # self.config += f'SAMPLES_PER_TRACE = {samplesPerTrace}\n'
        # self.sendMsg(FOBOSCtrl.SET_SAMPLES_PER_TRACE, samplesPerTrace)
        # status, _ = self.recvMsg()
        # return status
        self.config += f'SAMPLES_PER_TRACE = {samplesPerTrace}\n'
        return self._setConf(FOBOSCtrl.SET_SAMPLES_PER_TRACE, samplesPerTrace, 'Setting samples per trace')

    def confPrng(self, seed, num_rand_words):
        # use 64-bit seed and number of 32-bit words to configure the dut prng
        seed_0 = seed & 0xffff
        seed = seed >> 16
        seed_1 = seed & 0xffff
        seed = seed >> 16
        seed_2 = seed & 0xffff
        seed = seed >> 16
        seed_3 = seed & 0xffff
        seed = seed >> 16
        cfg =  "0082" + hex(num_rand_words)[2:].zfill(4) # set conf_reg 2
        cfg += "0084" + hex(seed_0)[2:].zfill(4) # set conf_reg 4
        cfg += "0085" + hex(seed_1)[2:].zfill(4) # set conf_reg 5
        cfg += "0086" + hex(seed_2)[2:].zfill(4) # set conf_reg 6
        cfg += "0087" + hex(seed_3)[2:].zfill(4) # set conf_reg 7
        cfg += "00800002" # gen_rand command
        print(cfg)
        self.sendMsg(FOBOSCtrl.CONF_DUT, cfg)
        status, response = self.recvMsg()
        print(response)

    def pwSetHwTrig(self, value):
        if value == 1:
            self.config += f'PWMGR_SET_HW_TRIG\n'
            self.sendMsg(FOBOSCtrl.PWMGR_SET_HW_TRIG, "")
        else:
            self.config += f'PWMGR_CLEAR_HW_TRIG\n'
            self.sendMsg(FOBOSCtrl.PWMGR_CLEAR_HW_TRIG, "")
        
        
        status, response = self.recvMsg()
        return status
    
    def pwSetSwTrig(self, value):
        if value == 1:
            self.config += f'PWMGR_SET_SW_TRIG\n'
            self.sendMsg(FOBOSCtrl.PWMGR_SET_SW_TRIG, "")
        else:
            self.config += f'PWMGR_CLEAR_SW_TRIG\n'
            self.sendMsg(FOBOSCtrl.PWMGR_CLEAR_SW_TRIG, "")
            
        status, response = self.recvMsg()
        return response    
    

    def pwReset(self):
        self.config += f'PWMGR_RESET\n'
        self.sendMsg(FOBOSCtrl.PWMGR_RESET, "")

        status, response = self.recvMsg()
        return status
    
    def pwClearMeasurements(self):
        self.config += f'PWMGR_CLEAR_MEASUREMENTS\n'
        self.sendMsg(FOBOSCtrl.PWMGR_CLEAR_MEASUREMENTS, "")

        status, response = self.recvMsg()
        return status
    
    def pwCheckHwTrigStatus(self):
        self.config += f'PWMGR_STAT_HW_TRIG\n'
        self.sendMsg(FOBOSCtrl.PWMGR_STAT_HW_TRIG, "")

        status, response = self.recvMsg()
        trigstat = int(response.split("=")[-1].replace(" ",""))
        return trigstat
    
    def pwCheckSwTrigStatus(self):
        self.config += f'PWMGR_STAT_SW_TRIG\n'
        self.sendMsg(FOBOSCtrl.PWMGR_STAT_SW_TRIG, "")

        status, response = self.recvMsg()
        trigstat = int(response.split("=")[-1].replace(" ",""))
        return trigstat
    
    def pwCheckOverflow(self):
        self.config += f'PWMGR_CHECK_OVERFLOW\n'
        self.sendMsg(FOBOSCtrl.PWMGR_CHECK_OVERFLOW, "")

        status, response = self.recvMsg()
        overflowstat = int(response.split("=")[-1].replace(" ",""))
        return overflowstat

    def pwCheckBusy(self):
        self.config += f'PWMGR_CHECK_BUSY\n'
        self.sendMsg(FOBOSCtrl.PWMGR_CHECK_BUSY, "")

        status, response = self.recvMsg()
        busy = int(response.split("=")[-1].replace(" ",""))
        return busy
    
    def pwGetMeasCount(self):
        self.config += f'PWMGR_GET_COUNT\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_COUNT, "")
        
        status, response = self.recvMsg()
        curr = int(response.split("=")[-1].replace(" ",""))
        return curr
    
    def getDutCycles(self):
        self.config += f'FOBOSCtrl_GET_DUT_CYCLES\n'
        self.sendMsg(FOBOSCtrl.FOBOSCtrl_GET_DUT_CYCLES, "")
        
        status, response = self.recvMsg()
        curr = int(response.split("=")[-1].replace(" ",""))
        return curr
    
    def pwSetGainVar(self, gain):
        valid_gain = [25, 50, 100, 200]
        if gain not in valid_gain:
            print("Invalid gain value, select from {}".format(valid_gain))
            return
        else:
            self.config += f'PWMGR_SET_GAIN_VAR = {gain}\n'
            self.sendMsg(FOBOSCtrl.PWMGR_SET_GAIN_VAR, gain)
            status, _ = self.recvMsg()
            return status

    def pwSetVarOn(self, volt=None):
        if (volt == None or volt < .9 or volt > 3.5 or volt*100 % 5 != 0):
            print("ERROR: voltage in range [.9,3.5] in increments of .05 must be given when turning on variable power source!")
            return -1
        
        self.config += f'PWMGR_SET_VAR_VOLT = {volt}\n'
        self.sendMsg(FOBOSCtrl.PWMGR_SET_VAR_VOLT, volt)
        status, _ = self.recvMsg()
        
        if (status != "0"):
            self.config += f'PWMGR_SET_VAR_ON\n'
            self.sendMsg(FOBOSCtrl.PWMGR_SET_VAR_ON, "")
            status, response = self.recvMsg()
            
        return status
         
    def pwSetVarOff(self):
        self.config += f'PWMGR_SET_VAR_OFF\n'
        self.sendMsg(FOBOSCtrl.PWMGR_SET_VAR_OFF, "")
        
        status, response = self.recvMsg()
        return status
        
    def pwGetGainVar(self):
        self.config += f'PWMGR_GET_GAIN_VAR\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_GAIN_VAR, "")
        
        status, response = self.recvMsg()
        gain = int(response.split("=")[-1].replace(" ",""))
        return gain
    
    def pwGetVoltVar(self):
        self.config += f'PWMGR_GET_VOLT_VAR\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_VOLT_VAR, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt

    def pwGetCurrVar(self):
        self.config += f'PWMGR_GET_CURR_VAR\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_CURR_VAR, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr
    
    def pwGetMaxVoltVar(self):
        self.config += f'PWMGR_MAX_VOLT_VAR\n'
        self.sendMsg(FOBOSCtrl.PWMGR_MAX_VOLT_VAR, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt 
   
    def pwGetAvgVoltVar(self):
        self.config += f'PWMGR_AVG_VOLT_VAR\n'
        self.sendMsg(FOBOSCtrl.PWMGR_AVG_VOLT_VAR, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt

    def pwGetMaxCurrVar(self):
        self.config += f'PWMGR_MAX_CURR_VAR\n'
        self.sendMsg(FOBOSCtrl.PWMGR_MAX_CURR_VAR, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr 
   
    def pwGetAvgCurrVar(self):
        self.config += f'PWMGR_AVG_CURR_VAR\n'
        self.sendMsg(FOBOSCtrl.PWMGR_AVG_CURR_VAR, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr
    
    def pwSetGain5v(self, gain):
        valid_gain = [25, 50, 100, 200]
        if gain not in valid_gain:
            print("Invalid gain value, select from {}".format(valid_gain))
            return
        else:
            self.config += f'PWMGR_SET_GAIN_5V = {gain}\n'
            self.sendMsg(FOBOSCtrl.PWMGR_SET_GAIN_5V, gain)
            status, _ = self.recvMsg()
        return status

    def pwGetGain5v(self):
        self.config += f'PWMGR_GET_GAIN_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_GAIN_5V, "")

        status, response = self.recvMsg()
        gain = int(response.split("=")[-1].replace(" ",""))
        return gain
    
    def pwGetVolt5v(self):
        self.config += f'PWMGR_GET_VOLT_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_VOLT_5V, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt

    def pwGetCurr5v(self):
        self.config += f'PWMGR_GET_CURR_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_CURR_5V, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr
    
    def pwGetMaxVolt5v(self):
        self.config += f'PWMGR_MAX_VOLT_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_MAX_VOLT_5V, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt 
   
    def pwGetAvgVolt5v(self):
        self.config += f'PWMGR_AVG_VOLT_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_AVG_VOLT_5V, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt

    def pwGetMaxCurr5v(self):
        self.config += f'PWMGR_MAX_CURR_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_MAX_CURR_5V, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr 
   
    def pwGetAvgCurr5v(self):
        self.config += f'PWMGR_AVG_CURR_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_AVG_CURR_5V, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr
    
    def pwSetGain3v3(self, gain):
        valid_gain = [25, 50, 100, 200]
        if gain not in valid_gain:
            print("Invalid gain value, select from {}".format(valid_gain))
            return
        else:
            self.config += f'PWMGR_SET_GAIN_3V3 = {gain}\n'
            self.sendMsg(FOBOSCtrl.PWMGR_SET_GAIN_3V3, gain)
            status, _ = self.recvMsg()

    def pwGetGain3v3(self):
        self.config += f'PWMGR_GET_GAIN_3V3\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_GAIN_3V3, "")
        
        status, response = self.recvMsg()
        gain = int(response.split("=")[-1].replace(" ",""))
        return gain
    
    def pwGetVolt3v3(self):
        self.config += f'PWMGR_GET_VOLT_3V3\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_VOLT_3V3, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt

    def pwGetCurr3v3(self):
        self.config += f'PWMGR_GET_CURR_3V3\n'
        self.sendMsg(FOBOSCtrl.PWMGR_GET_CURR_3V3, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr
    
    def pwGetMaxVolt3v3(self):
        self.config += f'PWMGR_MAX_VOLT_3V3\n'
        self.sendMsg(FOBOSCtrl.PWMGR_MAX_VOLT_3V3, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt 
   
    def pwGetAvgVolt3v3(self):
        self.config += f'PWMGR_AVG_VOLT_3V3\n'
        self.sendMsg(FOBOSCtrl.PWMGR_AVG_VOLT_3V3, "")
        
        status, response = self.recvMsg()
        volt = float(response.split("=")[-1].replace(" ",""))
        return volt

    def pwGetMaxCurr3v3(self):
        self.config += f'PWMGR_MAX_CURR_5V\n'
        self.sendMsg(FOBOSCtrl.PWMGR_MAX_CURR_5V, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr 
   
    def pwGetAvgCurr3v3(self):
        self.config += f'PWMGR_AVG_CURR_3V3\n'
        self.sendMsg(FOBOSCtrl.PWMGR_AVG_CURR_3V3, "")
        
        status, response = self.recvMsg()
        curr = float(response.split("=")[-1].replace(" ",""))
        return curr        

    def pwOutVarSet(self, volt):
        self.config += f'PWMGR_SET_VAR_VOLT = {volt}\n'
        self.sendMsg(FOBOSCtrl.PWMGR_SET_VAR_VOLT, volt)
        status, _ = self.recvMsg()
        return status
    
def main():
    import time
    ctrl = PYNQCtrl('192.168.10.99', 9995)
    status = ctrl.setTriggerWait(5)
    print(status)
    time.sleep(3)
    status = ctrl.setTriggerLen(6)
    print(status)
    status = ctrl.setTimeToReset(10)
    print(status)
    status = ctrl.setPowerGlitchWait(5)
    print(status)
    # data = [1,2,3]
    # status, resp = ctrl.processData(data, 10)
    # print(status)
    # print(resp)
    ctrl.disconnect()
if __name__=='__main__':
    main()
