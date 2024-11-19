import sys
import logging
import time
from pynq import Overlay
from pynq import Clocks
from config.pynq_conf import OVERLAY_FILE, FOBOS_HOME
sys.path.append(f"{FOBOS_HOME}/software/")
import foboslib as fb
from foboslib.commands import Commands as cmd
from foboslib.errors import Errors as err
from pynq_drivers.pynqlocal import PYNQCtrl
from pynq_drivers.openadc2 import OpenADCScope2
from pynq_drivers.power import PowerManager

class CtrlBoard():

    def __init__(self):
        logging.basicConfig(filename=fb.LOG_FILE, filemode='w', level=logging.INFO,
                            format='%(asctime)s %(name)s - %(levelname)s - %(message)s')
        self.config = {}
        self.default_config = {}
        self._define_default_config()
        self.logger = logging.getLogger('FOBOS control board initialized.')
        self.reset_all()

    def reset_all(self):
        self.logger.info('Loding overlay and reseting ctrl and target boards ...')
        self.logger.info(f'Loding overlay file : {OVERLAY_FILE}')
        overlay = Overlay(OVERLAY_FILE)
        self.logger.info(f'Bus clock = {Clocks.fclk0_mhz}')
        self.logger.info(f'Zynq bus clock : {Clocks.fclk0_mhz}')
        Clocks.fclk0_mhz = self.default_config['main_clk_mhz']
        self.logger.info(f'Bus clock = {Clocks.fclk0_mhz}')
        self.ctrl = PYNQCtrl(overlay)
        self.fobosAcq = OpenADCScope2(overlay)
        self.led = overlay.user_led_0
        self.led.write(0,4)
        self.powerManager = PowerManager(overlay)
        self._apply_default_config()
        self.logger.info('Overlay reloaded. Control board reset complete.')

    def do_operation(self, opcode, param):
        result = None
        trace = None
        print(f'ctrl_borad: opcode = {opcode}, param = {param}')

        match opcode:
            # data processsing
            case cmd.PROCESS               : status, result, _ = self._do_process_data(param, get_traces=False)
            case cmd.PROCESS_GET_TRACE     : status, result, trace = self._do_process_data(param, get_trace=True)
            # dut control
            case cmd.SET_DUT_CLK           : status = self._do_set_dut_clk_khz(param)
            case cmd.SET_DUT               : status = self._do_set_dut_type(param)
            case cmd.SET_DUT_INTERFACE     : status = self._do_set_dut_interface(param)
            case cmd.OUT_LEN               : status = self._do_set_output_length(param)
            case cmd.TIMEOUT               : status = self._do_set_timeout(param)
            case cmd.FORCE_RST             : status = self._do_force_dut_reset(param)
            case cmd.RELEASE_RST           : status = self._do_release_dut_reset(param)
            # trigger control
            case cmd.TRG_MODE              : status = self._do_set_trigger_mode(param)
            case cmd.TRG_WAIT              : status = self._do_set_trigger_wait_cycles(param)
            case cmd.TRG_LEN               : status = self._do_set_trigger_length(param)
            # ADC control
            case cmd.SET_SAMPLING_FREQ     : status = self._do_set_sampling_freq_khz(param)
            case cmd.SET_ADC_GAIN          : status = self._do_set_adc_gain(param)
            case cmd.SET_ADC_HILO          : status = self._do_set_adc_hilo(param)
            case cmd.SET_SAMPLES_PER_TRACE : status = self._do_set_samples_per_trace(param)
            case _                         : status = err.ERR_NOT_IMPLEMENTED
        
        return status, result, trace

    # operations ------------------------------------------------------------------
    def _do_process_data(self, tv, get_trace):
        tv_len = len(tv)
        if tv_len == 0 or tv_len % 4 != 0:
            self.logger.error(f'Invalid test vector length: {tv_len}')
            return err.ERR_TV_LEN_INVALID, None, None

        if get_trace:
            self.logger.debug(f'Opcode = PROCESS_DATA_GET_TRACE. param = {tv}')
            self.fobosAcq.arm()
            status, result = self.ctrl.processData(tv)
            if status==0:
                trace = self.fobosAcq.getTrace()
            return status, result, trace
        else:
            self.logger.debug(f'Opcode = PROCESS_DATA. param = {tv}')
            status, result = self.ctrl.processData(tv)
            return status, result, None
        
    def _do_set_dut_clk_khz(self, dut_clk_khz):
        self.logger.info(f'Opcode = SET_DUT_CLK. param = {dut_clk_khz} KHz')
        status, _ = self.ctrl.setDUTClk(dut_clk_khz)
        print(f'status={status}')
        if status==0:
            self.config['dut_clk_khz'] = dut_clk_khz
            return 0
        return err.ERR_DUT_CLK_OUT_OF_RANGE
    
    def _do_set_dut_interface(self, dut_interface):
        status, _ = self.ctrl.setDUTInterface(dut_interface)
        if status==0:
            self.config['dut_interface'] = dut_interface
            return 0
        return err.ERR_UNSUPPORTED_INTERFACE_TYPE

    def _do_set_dut_type(self, dut_type):
        status, _ = self.ctrl.setDUT(dut_type)
        if status==0:
            self.config['dut_type'] = dut_type
            return 0
        return err.ERR_DUT_NOT_SUPPORTED
    
    def _do_set_output_length(self, output_length):                
        status, _ = self.ctrl.setOutLen(output_length)
        if status==0:
            self.config['output_length'] = output_length
            return 0
        return err.ERR_OUTLEN_INVALID
    
    def _do_set_trigger_mode(self, trigger_mode):
        status, _ = self.ctrl.setTriggerMode(trigger_mode)
        if status==0:
            self.config['trigger_mode'] = trigger_mode
            return 0
        return err.ERR_TRIG_MODE_INVALID
    
    def _do_set_trigger_wait_cycles(self, trigger_wait_cycles):
        status, _ = self.ctrl.setTriggerWait(trigger_wait_cycles)
        if status==0:
            self.config['trigger_wait_cycles'] = trigger_wait_cycles
            return 0
        return err.ERR_TRIG_WAIT_INVALID
    
    def _do_set_trigger_length(self, trigger_length):
        status, _ = self.ctrl.setTriggerMode(trigger_length)
        if status==0:
            self.config['trigger_length'] = trigger_length
            return 0
        return err.ERR_TRIG_LEN_INVALID
    
    def _do_set_timeout(self, timeout):
        return err.ERR_NOT_IMPLEMENTED
    
    def _do_force_dut_reset(self):
        status, _ = self.ctrl.forceReset()
        if status==0:
            self.config['dut_reset'] = 1
            return 0
        return status
    
    def _do_release_dut_reset(self):
        status, _ = self.ctrl.releaseReset()
        if status==0:
            self.config['dut_reset'] = 0
            return 0
        return status
    
    def _do_set_sampling_freq_khz(self, sampling_freq_khz):
        status, _ = self.fobosAcq.setAdcClockFreq(sampling_freq_khz)
        if status==0:
            self.config['sampling_frequency_khz'] = sampling_freq_khz
            return 0
        return err.ERR_SAMPLING_FREQ_INVALID

    def _do_set_adc_gain(self, adc_gain):
        status, _ = self.fobosAcq.setGain(adc_gain)
        if status==0:
            self.config['adc_gain'] = adc_gain
            return 0
        return err.ERR_ADC_GAIN_INVALID

    def _do_set_adc_hilo(self, adc_hilo):
        status, _ = self.fobosAcq.setHiLo(adc_hilo)
        if status==0:
            self.config['hilo'] = adc_hilo
            return 0
        return err.ERR_ADC_GAIN_HILO_INVALID

    def _do_set_samples_per_trace(self, samples_per_trace):
        status, _ = self.fobosAcq.setSamplesPerTrace(samples_per_trace)
        if status==0:
            self.config['samples_per_trace'] = samples_per_trace
            return 0
        return err.ERR_SAMPLES_PER_TRACE_INVALID
    
    # end operation ---------------------------------------------------

    def _define_default_config(self):
        self.default_config['main_clk_mhz'] = 100
        self.default_config['dut_clk_khz'] = 10000
        self.default_config['dut_interface'] = fb.INTERFACE_4BIT
        self.default_config['output_length'] = 16
        self.default_config['dut_type'] = fb.DUT_DEFAULT
        self.default_config['trigger_mode']  = fb.TRG_FULL
        self.default_config['trigger_wait_cycles'] = 0 # cycles
        self.default_config['trigger_length'] = 1 # cycles
        self.default_config['sampling_freq_khz'] = 50000
        self.default_config['samples_per_trace'] = 1000
        self.default_config['adc_gain'] = 40
        self.default_config['adc_hilo'] = 1
        self.default_config['dut_reset'] = 0

    def _apply_default_config(self):
        self.logger.info('Applying default config ...')
        self._do_set_dut_clk_khz( self.default_config['dut_clk_khz'])
        self._do_set_dut_interface(self.default_config['dut_interface'] )
        self._do_set_output_length(self.default_config['output_length'])
        self._do_set_dut_type(self.default_config['dut_type'])
        self._do_set_trigger_mode(self.default_config['trigger_mode'])
        self._do_set_trigger_wait_cycles(self.default_config['trigger_wait_cycles'])
        self._do_set_trigger_length(self.default_config['trigger_length'])
        self._do_set_sampling_freq_khz(self.default_config['sampling_freq_khz'])
        self._do_set_samples_per_trace(self.default_config['samples_per_trace'])
        self._do_set_adc_gain(self.default_config['adc_gain'])
        self._do_set_adc_hilo(self.default_config['adc_hilo'])
        self._do_force_dut_reset()
        time.sleep(0.1)
        self._do_release_dut_reset()
        self.logger.info('Default config applied. Board reset.')
