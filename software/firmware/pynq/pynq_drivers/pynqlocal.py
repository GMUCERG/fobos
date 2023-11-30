##FOBOS control board class
##GMU
##Author: Abubakr Abdulgadir
##March 2019

import time
import sys
sys.path.append('../../../')
import foboslib as fb
# from foboslib.capture.ctrl.fb import fb
from pynq import allocate
import numpy as np
from pynq import Overlay
# keep the next two lines for driver binding
from .clkwizard import ClockWizard
from .openadc2 import OpenADC2

class PYNQCtrl():
    #status codes
    OK                  = 0x00
    ERROR               = 0x01
    TIMEOUT             = 0x02
    #dutcomm register offsets
    dutcomm_START       = 0x00
    dutcomm_STATUS      = 0x04
    dutcomm_INTERFACE   = 0x08
    dutcomm_EXP_OUT_LEN = 0x0c
    ##########################
    #dutctrl register offsets
    dutctrl_TRGLEN      = 0x00
    dutctrl_TRGWAIT     = 0x04
    dutctrl_TRGMODE     = 0x08
    dutctrl_FORCE_RST   = 0x1c
    dutctrl_DUT         = 0x38
    dutctrl_WORKCTR     = 0x3c
    ###trigger modes
    TRG_NORM            = 0X00
    TRG_FULL            = 0x01
    TRG_NORM_CLK        = 0x02
    TRG_FULL_CLK        = 0x03
    ###interface types - 4bit interface is default
    INTERFACE_4BIT      = 0x00
    INTERFACE_8BIT      = 0x01
    ##########################
    
    #constants
    
    def __init__(self, overlay):
        self.model = "FOBOS-CTRL-PYNQ-Z1"
        self.STATUS_LEN = 4
        self.outLen = 0
        self.dma = overlay.axi_dma_0
        self.dutcomm = overlay.dutcomm_0
        self.dutctrl = overlay.dut_controller_0
        self.dutClkWizard =overlay.clk_wiz
        self.input_buffer = None
        self.output_buffer = None
        self.inputSize = 0

    def setDUTClk(self, clkFreq):
        if not (isinstance(clkFreq, int) and clkFreq >= 1000 and clkFreq <= 100000):
            response = f"DUT clock = {int(clkFreq/1000)} MHz is out of range. DUT clock should be in the range [1-100] MHz"
            return fb.ERR_DUT_CLK_OUT_OF_RANGE, response
        
        self.dutClkWizard.setClock0Freq(clkFreq)
        response = f"Set DUT clk to {clkFreq} KHz"
        return fb.SUCCESS, response

    def __del__(self):
        #not sure if necessay
        self.input_buffer.freebuffer()
        self.output_buffer.freebuffer()
        
    def processData(self, data):
        """
        Sends data to FOBOS hardware for processing, e.g. encryption
        data: The data to be processed. This is a hexadecimal string.
        returns: the result of processing, e.g. ciphertext
        """
        inputSize = int(len(data)/2)
        #print(f'inputSize={inputSize}')
        if self.inputSize != inputSize:
            if self.input_buffer is not None:
                #print('free buffer')
                self.input_buffer.freebuffer()
            #print('allocate buffer')
            self.input_buffer = allocate(shape=(int(inputSize / 4),), dtype=np.uint32)
            self.inputSize = inputSize

        #put data in the buffer as 32bit integers
        data = data.strip()
        testVector = [int(data[i:i+8],16) for i in range(0, len(data), 8)]
        for i in range(0, len(testVector)):
            self.input_buffer[i] = testVector[i]
        self.dma.recvchannel.transfer(self.output_buffer) #configure dma to receive
        self.dma.sendchannel.transfer(self.input_buffer)  #configure dma to send 
        #print(f'in buf = {self.input_buffer}')
        self.dma.sendchannel.wait()
        self.dma.recvchannel.wait()
        result = ''.join(['{:08x}'.format(self.output_buffer[i]) for i in range(0, int(self.outLen / 4))])
        ##get result in correct format
        result2 = ''
        for i in range(len(result)):
            if (i % 2 == 0 and i != 0):
                result2 += ' '
            result2 += result[i]       
        return result2

    def sendDUTConf(self, data):
        """
        Sends data to FOBOS hardware for configuration, e.g. encryption
        data: The config parameters and command. This is a hexadecimal string.
        """
        print(f'Sending conf : {data}')
        inputSize = int(len(data)/2)
        input_buffer = allocate(shape=(int(inputSize / 4),), dtype=np.uint32)
        output_buffer = allocate(shape=(1,), dtype=np.uint32) # 32 bit ack
        #put data in the buffer as 32-bit integers
        data = data.strip()
        data_list = [int(data[i:i+8],16) for i in range(0, len(data), 8)]
        for i in range(0, len(data_list)):
            input_buffer[i] = data_list[i]
        
        prevOutLen = self.outLen #save outlen
        self.setOutLen(4) # ack size is 32 bits
        #send via DMA
        print('DUT config sent')
        ##
        self.dma.recvchannel.transfer(output_buffer) #configure dma to receive
        self.dma.sendchannel.transfer(input_buffer)  #configure dma to send
        print(f'out buf = {self.output_buffer}')
        self.dma.sendchannel.wait()
        self.dma.recvchannel.wait()
        input_buffer.freebuffer()
        output_buffer.freebuffer()
        self.setOutLen(prevOutLen)
        result = ''.join(['{:08x}'.format(output_buffer[i]) for i in range(0,1)])
        ##get result in correct format
        result2 = ''
        for i in range(len(result)):
            if (i % 2 == 0 and i != 0):
                result2 += ' '
            result2 += result[i]
        return result2

    def getModel(self):
        return self.model
    
    def setOutLen(self, outLen):
        """
        set Expected Output Length (outLen)
        """
        self.outLen = outLen
        if outLen%4 != 0 or outLen == 0 or outLen > fb.MAX_OUT_LEN:
            status = fb.ERR_OUTLEN_INVALID
            response = fb.ERR_MSGS[status]
            return status, response
        else:
            self.dutcomm.write(PYNQCtrl.dutcomm_EXP_OUT_LEN, int(outLen * 2))
            if self.output_buffer is not None:
                self.output_buffer.freebuffer()
            self.output_buffer = allocate(shape=(outLen//4,), dtype=np.uint32)
            response = f'Set output length = {outLen} bytes'
            return fb.SUCCESS, response

    def getOutLen(self):
        """
        get Expected Output Length (outLen)
        """
        return self.dutcomm.read(PYNQCtrl.dutcomm_EXP_OUT_LEN)
    
    def setTriggerWait(self, trigWait):
        """
        set number of trigger wait cycles
        """
        if trigWait < 0 or trigWait > fb.MAX_TRIG_WAIT:
            status = fb.ERR_TRIG_WAIT_INVALID
            response = fb.ERR_MSGS[status]
        else:
            self.dutctrl.write(PYNQCtrl.dutctrl_TRGWAIT, trigWait)
            status = fb.SUCCESS
            response = f'Set triger wait = {trigWait}'
        return status, response

    def getTriggerWait(self):
        """
        get number of trigger wait cycles
        """
        return self.dutctrl.read(PYNQCtrl.dutctrl_TRGWAIT)
        
    def setTriggerLen(self, trigLen):
        """
        set number of trigger length in cycles
        """
        if trigLen < 1 or trigLen > fb.MAX_TRIG_LEN:
            status = fb.ERR_TRIG_LEN_INVALID
            response = fb.ERR_MSGS[status]
        else:
            self.dutctrl.write(PYNQCtrl.dutctrl_TRGLEN, trigLen)
            status = fb.SUCCESS
            response = f'Set triger length = {trigLen}'
        return status, response

    def getTriggerLen(self):
        """
        get number of trigger length in cycles
        """
        return self.dutctrl.read(PYNQCtrl.dutctrl_TRGLEN)
    
    def getWorkCount(self):
        """
        get cycles elapsed during last hw trigger event
        """
        return self.dutctrl.read(PYNQCtrl.dutctrl_WORKCTR)
    
    def setTriggerMode(self, trigMode):
        """
        set trigger type
        """
        if not trigMode in [fb.TRG_NORM, fb.TRG_FULL, fb.TRG_NORM_CLK, fb.TRG_FULL_CLK]:
            status = fb.ERR_TRIG_MODE_INVALID
            response = fb.ERR_MSGS[status]
        else:
            self.dutctrl.write(PYNQCtrl.dutctrl_TRGMODE, trigMode)
            status = fb.SUCCESS
            response = f'Set triger mode = {trigMode}'
        return status, response
        
    def forceReset(self):
        """
        set reset ctrl and DUT
        """
        self.dutctrl.write(PYNQCtrl.dutctrl_FORCE_RST, 1)
        time.sleep(0.1)
        status = fb.SUCCESS
        response = f'DUT reset asserted'
        return status, response
    
    def releaseReset(self):
        """
        set reset ctrl and DUT
        """
        self.dutctrl.write(PYNQCtrl.dutctrl_FORCE_RST, 0)
        status = fb.SUCCESS
        response = f'DUT reset de-asserted'
        return status, response

    def getTriggerMode(self):
        """
        get trigger type
        """
        return self.dutctrl.read(PYNQCtrl.dutctrl_TRGMODE)
    
    def setDUTInterface(self, interfaceType):
        if not interfaceType in [fb.INTERFACE_4BIT, fb.INTERFACE_8BIT]:
            status = fb.ERR_UNSUPPORTED_INTERFACE_TYPE
            response = response = fb.ERR_MSGS[status]
        else:
            self.dutcomm.write(PYNQCtrl.dutcomm_INTERFACE, interfaceType)
            status = fb.SUCCESS
            response = f'set DUI interface = {interfaceType}'
        
        return status, response
   
    def setDUT(self, dut):
        """
        set trigger type
        """
        if not dut in fb.SUPPORTED_DUTS:
            status = fb.ERR_DUT_NOT_SUPPORTED
            response = response = fb.ERR_MSGS[status]
        else:
            self.dutctrl.write(PYNQCtrl.dutctrl_DUT, dut)
            status = fb.SUCCESS
            response = f'set DUT = {dut}'
            
        return status, response