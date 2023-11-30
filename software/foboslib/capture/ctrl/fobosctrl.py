#############################################################################
#                                                                           #
#   Copyright 2019 CERG                                                     #
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
# FOBOS control board class
# Author: Abubakr Abdulgadir
# GMU
# Aug 7 2018
# This class provide constants used by fobos contoller protocol

import os

class FOBOSCtrl:
    # General Constants
    SUCCESS                       = 0

    
    ACK_LEN = 4    # acknowledgement length in bytes
    PARAM_LEN = 4  # config prarameter length in bytes
    # config parameters numbers. Each number can serve as register number
    # or array index. These parameters must be sent to the hardware board.
    OUT_LEN = 0
    TRG_WAIT = 1
    TRG_LEN = 2
    TRG_MODE = 3
    TIME_TO_RST = 4
    FORCE_RST = 5
    RELEASE_RST = 6
    TIMEOUT = 7
    SET_DUT_CLK = 8
    SET_TEST_MODE = 9
    #power glitch
    POWER_GLITCH_WAIT = 11
    POWER_GLITCH_ENABLE = 12
    POWER_GLITCH_PATTERN0 = 13
    POWER_GLITCH_PATTERN1 = 14
    POWER_GLITCH_PATTERN2 = 15 #reserved
    POWER_GLITCH_PATTERN3 = 16 #reserved
    SET_DUT_INTERFACE = 17
    DISCONNECT = 18
      ####ADC
    SET_SAMPLING_FREQ = 19
    SET_ADC_GAIN = 20
    SET_SAMPLES_PER_TRACE = 21
    SET_ADC_HILO = 22
    
    SET_DUT = 23

    PROCESS = 100
    PROCESS_GET_TRACE = 101

    # Power Manager Commands
    PWMGR_SET_GAIN_VAR = 24
    PWMGR_GET_GAIN_VAR = 25
    PWMGR_GET_VOLT_VAR = 26
    PWMGR_GET_CURR_VAR = 27
    PWMGR_SET_HW_TRIG = 28
    PWMGR_CLEAR_HW_TRIG = 29
    PWMGR_RESET = 30
    PWMGR_CLEAR_MEASUREMENTS = 31
    PWMGR_STAT_HW_TRIG = 32
    PWMGR_CHECK_OVERFLOW = 33
    PWMGR_CHECK_BUSY = 34
    PWMGR_MAX_VOLT_VAR = 35
    PWMGR_AVG_VOLT_VAR = 36
    PWMGR_MAX_CURR_VAR = 37
    PWMGR_AVG_CURR_VAR = 38
    PWMGR_GET_COUNT = 39
    PWMGR_SET_SW_TRIG  = 40
    PWMGR_CLEAR_SW_TRIG  = 41
    FOBOSCtrl_GET_DUT_CYCLES = 42

    PWMGR_SET_GAIN_5V  = 43
    PWMGR_GET_GAIN_5V  = 44
    PWMGR_GET_VOLT_5V  = 45
    PWMGR_GET_CURR_5V  = 46
    PWMGR_MAX_VOLT_5V  = 47
    PWMGR_AVG_VOLT_5V  = 48
    PWMGR_MAX_CURR_5V  = 49
    PWMGR_AVG_CURR_5V  = 50
    
    PWMGR_SET_GAIN_3V3  = 51
    PWMGR_GET_GAIN_3V3  = 52
    PWMGR_GET_VOLT_3V3  = 53
    PWMGR_GET_CURR_3V3  = 54
    PWMGR_MAX_VOLT_3V3  = 55
    PWMGR_AVG_VOLT_3V3  = 56
    PWMGR_MAX_CURR_3V3  = 57
    PWMGR_AVG_CURR_3V3  = 58

    PWMGR_STAT_SW_TRIG = 59
    PWMGR_SET_VAR_ON  = 60
    PWMGR_SET_VAR_OFF = 61
    PWMGR_SET_VAR_VOLT = 62

    # Trigger parameters
    TRG_NORM = 0
    TRG_FULL = 1
    TRG_NORM_CLK = 2
    TRG_FULL_CLK = 3
    # test mode parameters
    ENABLED = 1
    DISABLED = 0

    ###interface types - 4bit interface is default
    INTERFACE_4BIT      = 0x00
    INTERFACE_8BIT      = 0x01
    
    ##DUT
    DEFAULT             = 0x00
    NEXYS3              = 0x00
    NEXYS4              = 0x00
    CW305               = 0x01
    SUPPORTED_DUTS      = [DEFAULT, NEXYS3, NEXYS4, CW305]

    ## limits
    MAX_OUT_LEN           = 65532
    MIN_SAMPLES_PER_TRACE = 4
    MAX_SAMPLES_PER_TRACE = 131072
    MAX_TRIG_LEN          = 2**32-1
    MAX_TRIG_WAIT         = 2**32-1
    ##########################
    # Error codes
    
    ERR_DUT_CLK_OUT_OF_RANGE       = 1
    ERR_UNSUPPORTED_INTERFACE_TYPE = 2
    ERR_OUTLEN_INVALID             = 3
    ERR_TRIG_MODE_INVALID          = 4
    ERR_TRIG_LEN_INVALID           = 5
    ERR_TRIG_WAIT_INVALID          = 6
    ERR_SAMPLING_FREQ_INVALID      = 7
    ERR_ADC_GAIN_INVALID           = 8
    ERR_SAMPLES_PER_TRACE_INVALID  = 9
    ERR_DUT_NOT_SUPPORTED          = 10
    ERR_NOT_IMPLEMENTED            = 999

    ERR_MSGS = {
        ERR_DUT_CLK_OUT_OF_RANGE       : 'DUT clock is out of range. DUT clock should be in the range [1-100] MHz',
        ERR_UNSUPPORTED_INTERFACE_TYPE : 'DUT interface type not supported',
        ERR_OUTLEN_INVALID             : 'Output length in bytes should be divisible by 4 and less than or equal to 65532',
        ERR_TRIG_MODE_INVALID          : 'Trigger mode invalid. Valid values are 0, 1, 2, 3',
        ERR_TRIG_LEN_INVALID           : 'Trigger length invalid. Valid range is [1 2**32-1]',
        ERR_TRIG_WAIT_INVALID          : 'Trigger wait invalid. Valid range is [0 2**32-1]',
        ERR_SAMPLING_FREQ_INVALID      : 'Sampling frequncy invalid. Valid range is [1 100] MHz',
        ERR_ADC_GAIN_INVALID           : 'ADC gain invalid. Valid range is [0 60]',
        ERR_SAMPLES_PER_TRACE_INVALID  : f'Samples per traces invalid. Valid range is [{MIN_SAMPLES_PER_TRACE} {MAX_SAMPLES_PER_TRACE}] and must be divisble by 4',
        ERR_NOT_IMPLEMENTED            : 'opcode not implemented',
        ERR_DUT_NOT_SUPPORTED          : 'DUT not supported. Allowed values are 0 and 1'
    }
