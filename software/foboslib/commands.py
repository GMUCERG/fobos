class Commands:
    # opcodes
    OUT_LEN                  = 0
    TRG_WAIT                 = 1
    TRG_LEN                  = 2
    TRG_MODE                 = 3
    TIME_TO_RST              = 4
    FORCE_RST                = 5
    RELEASE_RST              = 6
    TIMEOUT                  = 7
    SET_DUT_CLK              = 8
    SET_TEST_MODE            = 9
    ## power glitch
    POWER_GLITCH_WAIT        = 11
    POWER_GLITCH_ENABLE      = 12
    POWER_GLITCH_PATTERN0    = 13
    POWER_GLITCH_PATTERN1    = 14
    POWER_GLITCH_PATTERN2    = 15
    POWER_GLITCH_PATTERN3    = 16
    SET_DUT_INTERFACE        = 17
    DISCONNECT               = 18
    ## ADC
    SET_SAMPLING_FREQ        = 19
    SET_ADC_GAIN             = 20
    SET_SAMPLES_PER_TRACE    = 21
    SET_ADC_HILO             = 22
    SET_DUT                  = 23
    ## power manager
    PWMGR_SET_GAIN_VAR       = 24
    PWMGR_GET_GAIN_VAR       = 25
    PWMGR_GET_VOLT_VAR       = 26
    PWMGR_GET_CURR_VAR       = 27
    PWMGR_SET_HW_TRIG        = 28
    PWMGR_CLEAR_HW_TRIG      = 29
    PWMGR_RESET              = 30
    PWMGR_CLEAR_MEASUREMENTS = 31
    PWMGR_STAT_HW_TRIG       = 32
    PWMGR_CHECK_OVERFLOW     = 33
    PWMGR_CHECK_BUSY         = 34
    PWMGR_MAX_VOLT_VAR       = 35
    PWMGR_AVG_VOLT_VAR       = 36
    PWMGR_MAX_CURR_VAR       = 37
    PWMGR_AVG_CURR_VAR       = 38
    PWMGR_GET_COUNT          = 39
    PWMGR_SET_SW_TRIG        = 40
    PWMGR_CLEAR_SW_TRIG      = 41
    FOBOSCtrl_GET_DUT_CYCLES = 42
    PWMGR_SET_GAIN_5V        = 43
    PWMGR_GET_GAIN_5V        = 44
    PWMGR_GET_VOLT_5V        = 45
    PWMGR_GET_CURR_5V        = 46
    PWMGR_MAX_VOLT_5V        = 47
    PWMGR_AVG_VOLT_5V        = 48
    PWMGR_MAX_CURR_5V        = 49
    PWMGR_AVG_CURR_5V        = 50
    PWMGR_SET_GAIN_3V3       = 51
    PWMGR_GET_GAIN_3V3       = 52
    PWMGR_GET_VOLT_3V3       = 53
    PWMGR_GET_CURR_3V3       = 54
    PWMGR_MAX_VOLT_3V3       = 55
    PWMGR_AVG_VOLT_3V3       = 56
    PWMGR_MAX_CURR_3V3       = 57
    PWMGR_AVG_CURR_3V3       = 58
    PWMGR_STAT_SW_TRIG       = 59
    PWMGR_SET_VAR_ON         = 60
    PWMGR_SET_VAR_OFF        = 61
    PWMGR_SET_VAR_VOLT       = 62
    ## data processing
    PROCESS                  = 100
    PROCESS_GET_TRACE        = 101

    CMD_LOCK                 = 300
    CMD_UNLOCK               = 301
    CMD_LOCK_STATUS          = 302


    cmd_data = {
        OUT_LEN                  : {'name' : 'OUT_LEN'                  },
        TRG_WAIT                 : {'name' : 'TRG_WAIT'                 },
        TRG_LEN                  : {'name' : 'TRG_LEN'                  },
        TRG_MODE                 : {'name' : 'TRG_MODE'                 },
        TIME_TO_RST              : {'name' : 'TIME_TO_RST'              },
        FORCE_RST                : {'name' : 'FORCE_RST'                },
        RELEASE_RST              : {'name' : 'RELEASE_RST'              },
        TIMEOUT                  : {'name' : 'TIMEOUT'                  },
        SET_DUT_CLK              : {'name' : 'SET_DUT_CLK'              },
        SET_TEST_MODE            : {'name' : 'SET_TEST_MODE'            },
        POWER_GLITCH_WAIT        : {'name' : 'POWER_GLITCH_WAIT'        },
        POWER_GLITCH_ENABLE      : {'name' : 'POWER_GLITCH_ENABLE'      },
        POWER_GLITCH_PATTERN0    : {'name' : 'POWER_GLITCH_PATTERN0'    },
        POWER_GLITCH_PATTERN1    : {'name' : 'POWER_GLITCH_PATTERN1'    },
        POWER_GLITCH_PATTERN2    : {'name' : 'POWER_GLITCH_PATTERN2'    },
        POWER_GLITCH_PATTERN3    : {'name' : 'POWER_GLITCH_PATTERN3'    },
        SET_DUT_INTERFACE        : {'name' : 'SET_DUT_INTERFACE'        },
        DISCONNECT               : {'name' : 'DISCONNECT'               },
        SET_SAMPLING_FREQ        : {'name' : 'SET_SAMPLING_FREQ'        },
        SET_ADC_GAIN             : {'name' : 'SET_ADC_GAIN'             },
        SET_SAMPLES_PER_TRACE    : {'name' : 'SET_SAMPLES_PER_TRACE'    },
        SET_ADC_HILO             : {'name' : 'SET_ADC_HILO'             },
        SET_DUT                  : {'name' : 'SET_DUT'                  },
        PWMGR_SET_GAIN_VAR       : {'name' : 'PWMGR_SET_GAIN_VAR'       },
        PWMGR_GET_GAIN_VAR       : {'name' : 'PWMGR_GET_GAIN_VAR'       },
        PWMGR_GET_VOLT_VAR       : {'name' : 'PWMGR_GET_VOLT_VAR'       },
        PWMGR_GET_CURR_VAR       : {'name' : 'PWMGR_GET_CURR_VAR'       },
        PWMGR_SET_HW_TRIG        : {'name' : 'PWMGR_SET_HW_TRIG'        },
        PWMGR_CLEAR_HW_TRIG      : {'name' : 'PWMGR_CLEAR_HW_TRIG'      },
        PWMGR_RESET              : {'name' : 'PWMGR_RESET'              },
        PWMGR_CLEAR_MEASUREMENTS : {'name' : 'PWMGR_CLEAR_MEASUREMENTS' },
        PWMGR_STAT_HW_TRIG       : {'name' : 'PWMGR_STAT_HW_TRIG'       },
        PWMGR_CHECK_OVERFLOW     : {'name' : 'PWMGR_CHECK_OVERFLOW'     },
        PWMGR_CHECK_BUSY         : {'name' : 'PWMGR_CHECK_BUSY'         },
        PWMGR_MAX_VOLT_VAR       : {'name' : 'PWMGR_MAX_VOLT_VAR'       },
        PWMGR_AVG_VOLT_VAR       : {'name' : 'PWMGR_AVG_VOLT_VAR'       },
        PWMGR_MAX_CURR_VAR       : {'name' : 'PWMGR_MAX_CURR_VAR'       },
        PWMGR_AVG_CURR_VAR       : {'name' : 'PWMGR_AVG_CURR_VAR'       },
        PWMGR_GET_COUNT          : {'name' : 'PWMGR_GET_COUNT'          },
        PWMGR_SET_SW_TRIG        : {'name' : 'PWMGR_SET_SW_TRIG'        },
        PWMGR_CLEAR_SW_TRIG      : {'name' : 'PWMGR_CLEAR_SW_TRIG'      },
        FOBOSCtrl_GET_DUT_CYCLES : {'name' : 'FOBOSCtrl_GET_DUT_CYCLES' },
        PWMGR_SET_GAIN_5V        : {'name' : 'PWMGR_SET_GAIN_5V'        },
        PWMGR_GET_GAIN_5V        : {'name' : 'PWMGR_GET_GAIN_5V'        },
        PWMGR_GET_VOLT_5V        : {'name' : 'PWMGR_GET_VOLT_5V'        },
        PWMGR_GET_CURR_5V        : {'name' : 'PWMGR_GET_CURR_5V'        },
        PWMGR_MAX_VOLT_5V        : {'name' : 'PWMGR_MAX_VOLT_5V'        },
        PWMGR_AVG_VOLT_5V        : {'name' : 'PWMGR_AVG_VOLT_5V'        },
        PWMGR_MAX_CURR_5V        : {'name' : 'PWMGR_MAX_CURR_5V'        },
        PWMGR_AVG_CURR_5V        : {'name' : 'PWMGR_AVG_CURR_5V'        },
        PWMGR_SET_GAIN_3V3       : {'name' : 'PWMGR_SET_GAIN_3V3'       },
        PWMGR_GET_GAIN_3V3       : {'name' : 'PWMGR_GET_GAIN_3V3'       },
        PWMGR_GET_VOLT_3V3       : {'name' : 'PWMGR_GET_VOLT_3V3'       },
        PWMGR_GET_CURR_3V3       : {'name' : 'PWMGR_GET_CURR_3V3'       },
        PWMGR_MAX_VOLT_3V3       : {'name' : 'PWMGR_MAX_VOLT_3V3'       },
        PWMGR_AVG_VOLT_3V3       : {'name' : 'PWMGR_AVG_VOLT_3V3'       },
        PWMGR_MAX_CURR_3V3       : {'name' : 'PWMGR_MAX_CURR_3V3'       },
        PWMGR_AVG_CURR_3V3       : {'name' : 'PWMGR_AVG_CURR_3V3'       },
        PWMGR_STAT_SW_TRIG       : {'name' : 'PWMGR_STAT_SW_TRIG'       },
        PWMGR_SET_VAR_ON         : {'name' : 'PWMGR_SET_VAR_ON'         },
        PWMGR_SET_VAR_OFF        : {'name' : 'PWMGR_SET_VAR_OFF'        },
        PWMGR_SET_VAR_VOLT       : {'name' : 'PWMGR_SET_VAR_VOLT'       },
        PROCESS                  : {'name' : 'PROCESS'                  },
        PROCESS_GET_TRACE        : {'name' : 'PROCESS_GET_TRACE'        },
        CMD_LOCK                 : {'name' : 'CMD_LOCK'                 },
        CMD_UNLOCK               : {'name' : 'CMD_UNLOCK'               },
    }