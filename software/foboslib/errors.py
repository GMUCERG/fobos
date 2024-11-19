class Errors:
    # Error codes
    ERR_SUCCESS                    = 0
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
    ERR_ADC_GAIN_HILO_INVALID      = 11
    ERR_TV_LEN_INVALID             = 12
    ERR_NOT_IMPLEMENTED            = 999

    err_data = {
        ERR_SUCCESS                    : {'err_msg' : "Success"},
        ERR_DUT_CLK_OUT_OF_RANGE       : {'err_msg' : 'DUT clock is out of range. DUT clock should be in the range [1-100] MHz'},
        ERR_UNSUPPORTED_INTERFACE_TYPE : {'err_msg' : 'DUT interface type not supported'},
        ERR_OUTLEN_INVALID             : {'err_msg' : 'Output length in bytes should be divisible by 4 and less than or equal to 65532'},
        ERR_TRIG_MODE_INVALID          : {'err_msg' : 'Trigger mode invalid. Valid values are 0, 1, 2, 3'},
        ERR_TRIG_LEN_INVALID           : {'err_msg' : 'Trigger length invalid. Valid range is [1 2**32-1]'},
        ERR_TRIG_WAIT_INVALID          : {'err_msg' : 'Trigger wait invalid. Valid range is [0 2**32-1]'},
        ERR_SAMPLING_FREQ_INVALID      : {'err_msg' : 'Sampling frequncy invalid. Valid range is [1 100] MHz'},
        ERR_ADC_GAIN_INVALID           : {'err_msg' : 'ADC gain invalid. Valid range is [0 60]'},
        ERR_ADC_GAIN_HILO_INVALID      : {'err_msg' : 'ADC gain HiLo value must be 0 or 1'},
        ERR_SAMPLES_PER_TRACE_INVALID  : {'err_msg' : 'Samples per traces invalid. Valid range is  and must be divisble by 4'},
        ERR_NOT_IMPLEMENTED            : {'err_msg' : 'Opcode not implemented'},
        ERR_DUT_NOT_SUPPORTED          : {'err_msg' : 'DUT not supported. Allowed values are 0 and 1'},
        ERR_TV_LEN_INVALID             : {'err_msg' : 'Test vector length invalid. It should be greater than zero and multiple of 4 bytes'}
    }