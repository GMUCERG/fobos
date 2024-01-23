import sys
from pynq import DefaultIP
from pynq import allocate
import numpy as np
sys.path.append('../../../')
import foboslib as fb

class OpenADC2(DefaultIP):
    """
    OpenADC2 is the Python driver for the OpenADC Interface Light.
    """

    capture_cfg_reg_offset = 0x0
    gain_cfg_reg_offset = 0x4
    status_reg_offset = 0x8
    extra_cfg_reg_offset = 0xc
    
    def __init__(self, description, *args, **kwargs):
        """
        Construct a new 'OpenADC' object.
        """
        super().__init__(description=description)        

    bindto = ['user.org:user:openadc_interface_light:1.0']
    
    def read_capture_reg(self):
        """
        Read the capture configuration system register.

        :return: returns 32-bit register value
        """
        return self.mmio.read(self.capture_cfg_reg_offset)

    def set_capture_en(self, capture_en_bit):
        capture_cfg = self.mmio.read(self.capture_cfg_reg_offset)
        capture_cfg = capture_cfg & 0x7fffffff
        capture_cfg = capture_cfg | ((capture_en_bit << 31) & 0x80000000)
        self.mmio.write(self.capture_cfg_reg_offset, capture_cfg)

    def set_capture_rst(self, capture_rst_bit):
        capture_cfg = self.mmio.read(self.capture_cfg_reg_offset)
        capture_cfg = capture_cfg & 0x3fffffff # must clear capture_en
        capture_cfg = capture_cfg | ((capture_rst_bit << 30) & 0x40000000)
        self.mmio.write(self.capture_cfg_reg_offset, capture_cfg)
        
    def set_test_en(self, capture_test_en_bit):
        capture_cfg = self.mmio.read(self.capture_cfg_reg_offset)
        capture_cfg = capture_cfg & 0x5fffffff # must clear capture_en
        capture_cfg = capture_cfg | ((capture_test_en_bit << 29) & 0x20000000)
        self.mmio.write(self.capture_cfg_reg_offset, capture_cfg)
    
    def set_capture_blk_num(self, capture_blk_num):
        # set the number of blocks (each block is 4 samples)
        capture_cfg = self.mmio.read(self.capture_cfg_reg_offset)
        capture_cfg = capture_cfg & 0x7ffc0000 # must clear capture_en
        capture_cfg = capture_cfg | (capture_blk_num  & 0x3ffff)
        self.mmio.write(self.capture_cfg_reg_offset, capture_cfg)
    
    def set_test_cnt_start(self, test_cnt_start):
        # set the test mode start counter
        extra_cfg = self.mmio.read(self.extra_cfg_reg_offset)
        extra_cfg = extra_cfg & 0xfffffc00
        extra_cfg = extra_cfg | (test_cnt_start  & 0x3ff)
        self.mmio.write(self.extra_cfg_reg_offset, extra_cfg)
        
    def write_gain(self, gain):
        if (gain < 0) or (gain > 78):
            raise Execption("Invalid Gain, range 0-78 Only")
        gain_reg = self.mmio.read(self.gain_cfg_reg_offset)
        gain_reg = gain_reg & 0xffffff00
        gain_reg = gain_reg | (gain  & 0xff)
        self.mmio.write(self.gain_cfg_reg_offset, gain_reg)
    
    def write_hilo(self, hilo):
        gain_cfg = self.mmio.read(self.gain_cfg_reg_offset)
        print(f'gain_cfg_reg = {hex(gain_cfg)}')
        gain_cfg = gain_cfg & 0x7fffffff
        gain_cfg = gain_cfg | ((hilo << 31) & 0x80000000)
        self.mmio.write(self.gain_cfg_reg_offset, gain_cfg)
        print(f'gain_cfg_reg = {hex(gain_cfg)}')
        
    def read_hilo(self):
        gain_cfg = self.mmio.read(self.gain_cfg_reg_offset)
        print(f'gain_cfg_reg = {hex(gain_cfg)}')
        return ((self.mmio.read(self.gain_cfg_reg_offset) >> 31) & 0x1)
        
class OpenADCScope2():
    """
    OpenADC2 is the collection of utility functions for using the
    OpenADC board to capture on PYNQ
    """

    adc = None
    dma = None
    clockGen = None
    # MHz
    busClk = 100
    adcClk = None

    def __init__(self, overlay):
        self.adc = overlay.openadc_interface_li_1
        dir(self.adc)
        self.dma = overlay.axi_dma_1
        self.adcClk = overlay.clk_wiz_adc
        self.buffer = None
        self.blk_num = None
        self.samples_per_trace = None

    def setSamplesPerTrace(self, samples_per_trace):
        if samples_per_trace < fb.MIN_SAMPLES_PER_TRACE or samples_per_trace > fb.MAX_SAMPLES_PER_TRACE:
            status = fb.ERR_SAMPLES_PER_TRACE_INVALID
            response = fb.ERR_MSGS[status]
        else:
            import math
            self.samples_per_trace = samples_per_trace
            blk_num = math.ceil(samples_per_trace / 4)
            print(f'samples_per_trace={self.samples_per_trace}, blk_num ={blk_num}')
            self.adc.set_capture_blk_num(blk_num)
            self.buffer = allocate(shape=(blk_num,), dtype=np.uint64)
            status = fb.SUCCESS
            response = f'Set SamplesPerTrace = {samples_per_trace}'
        return status, response

    def enableTestMode(self, test_cnt_start=0):
        self.adc.set_test_cnt_start(test_cnt_start)
        self.adc.set_test_en(1)

    def disableTestMode(self):
        self.adc.set_test_en(0)

    def arm(self):
        if self.samples_per_trace is None:
            raise Exception("ADC samples per trace not set. Cannot arm.") 
        self.adc.set_capture_rst(1)
        self.adc.set_capture_rst(0)
        self.dma.recvchannel.transfer(self.buffer)
        self.adc.set_capture_en(1)

    def getTrace(self):
        self.dma.recvchannel.wait()
        trace = self.buffer.view('uint16').tolist()
        return trace[0:self.samples_per_trace]

    def defineBusClock(self, busClock):
        self.busClk = busClock

    def setAdcClockFreq(self, adcClockValue):
        # self.adcClk.setClock0Freq(adcClockValue)
        if adcClockValue < 1000 or adcClockValue > 100000:
            status = fb.ERR_SAMPLING_FREQ_INVALID
            response = fb.ERR_MSGS[fb.ERR_SAMPLING_FREQ_INVALID]
        else:
            self.adcClk.setClock0Freq(adcClockValue)
            status = fb.SUCCESS
            response = f'Set sampling frequency = {adcClockValue} KHz'
        return status, response

    def setAdcClockPhase(self, phase):
        import math
        if (phase > 360 or phase < 0):
            raise Exception('ADC Phase may only be between 0 and 360 degrees')
        self.adcClk.writeClk0Phase(math.floor(phase*1000))

    def setGain(self, gain):
        # self.adc.write_gain(gain)
        if gain < 0 or gain > 60:
            status = fb.ERR_ADC_GAIN_INVALID
            response = fb.ERR_MSGS[status]
        else:
            self.adc.write_gain(gain)
            status = fb.SUCCESS
            response = f'Set ADC gain = {gain}'
        return status, response

    def setHiLo(self, hilo):
        if not hilo in [0, 1]:
            status = fb.ERR_ADC_GAIN_HILO_INVALID
            response = fb.ERR_MSGS[status]
        else:
            self.adc.write_hilo(hilo)
            status = fb.SUCCESS
            response = f'Set ADC gain HiLo = {hilo}'
        print(f'gain reg set to {self.adc.read_hilo()}')
        return status, response

