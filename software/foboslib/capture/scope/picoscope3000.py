#############################################################################
#                                                                           #
#   Copyright 2019-2023 CERG                                                #
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

import ctypes
import numpy as np
import math
from picosdk.ps3000a import ps3000a as ps
import matplotlib.pyplot as plt
from picosdk.functions import adc2mV, assert_pico_ok, mV2adc

class Picoscope():

    def __init__(self, 
                 sampleResolution=8, 
                 preTriggerSamples=0,
                 postTriggerSamples=1000):
        """
        Open oscilloscope
        """
        # Create chandle
        self.chandle = ctypes.c_int16()
        self.status = {}
        # This is an 8-bit scope!
        if sampleResolution == 8:
            pass
        else:
            raise Exception("Scope resolution not supported." +
                            " only 8 bits resolution is supported")

        self.sampleResolution = sampleResolution
        self.status["openunit"] = ps.ps3000aOpenUnit(
            ctypes.byref(self.chandle),
            None
        )

        try:
            assert_pico_ok(self.status["openunit"])
        except:
            powerStatus = self.status["openunit"]
            if powerStatus == 286:
                self.status["changePowerSource"] = ps.ps3000aChangePowerSource(
                    self.chandle,
                    powerStatus)
            elif powerStatus == 282:
                self.status["changePowerSource"] = ps.ps3000aChangePowerSource(
                    self.chandle,
                    powerStatus)
            else:
                raise Exception("Picoscope initialization error")

            assert_pico_ok(self.status["changePowerSource"])

        self.disableAllChannel()
        # Set number of samples
        self.preTriggerSamples = preTriggerSamples
        self.postTriggerSamples = postTriggerSamples
        self.maxSamples = self.preTriggerSamples + self.postTriggerSamples
        # Max ADC value depends on resolution. Prog manual page 11
        self.maxADC = ctypes.c_int16()
        self.status["maximumValue"] = ps.ps3000aMaximumValue(
            self.chandle,
            ctypes.byref(self.maxADC))
        assert_pico_ok(self.status["maximumValue"])
        
    def setChannel(self, channelName='CHANNEL_A',
                   coupling='DC', rangemv=100):
        """
        Configure volatge range and coupling for a channel.
        parameters:
        -----
        channelName : string
            possible values : CHANNEL_A | CHANNEL_B
        coupling : string
            possible values : DC | AC
        ranegmv : string
            Voltage range 20MV - 500MV, 1V-20V
        """
        # Set up channel A
        # handle = chandle
        if channelName == 'CHANNEL_A':
            chan = "PS3000A_CHANNEL_A"
        elif channelName == 'CHANNEL_B':
            chan = "PS3000A_CHANNEL_B"
        else:
            raise Exception("Scope channel not supported. Please select one of CHANNEL_A or CHANNEL_B")

        channel = ps.PS3000A_CHANNEL[chan]
        # enabled = 1
        if coupling == 'DC':
            coup = "PS3000A_DC"
        elif coupling == 'AC':
            coup = "PS3000A_AC"
        else:
            raise Exception("Scope coupling supported. Please select one of DC or AC")
        couplingType = ps.PS3000A_COUPLING[coup]
        ##set range
        
        if rangemv   == 20:
            srange = "PS3000A_20MV"
        elif rangemv == 50:
            srange = "PS3000A_50MV"
        elif rangemv == 100:
            srange = "PS3000A_100MV"
        elif rangemv == 200:
            srange = "PS3000A_200MV"
        elif rangemv == 500:
            srange = "PS3000A_500MV"
        elif rangemv == 1000:
            srange = "PS3000A_1V"
        elif rangemv == 2000:
            srange = "PS3000A_2V"
        elif rangemv == 5000:
            srange = "PS3000A_5V"
        elif rangemv == 10000:
            srange = "PS3000A_10V"
        elif rangemv == 20000:
            srange = "PS3000A_20V"
        else:
            raise Exception("Scope voltage range supported (mV). Supported ranges:" +
                    "\t20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000.")


        chRange = ps.PS3000A_RANGE[srange]
        self.status[channelName] = ps.ps3000aSetChannel(
                                    self.chandle, channel,
                                    1, 
                                    couplingType, 
                                    chRange,
                                    0
                                    )
        if channelName == 'CHANNEL_A':
            self.chARange = chRange
            self.chAEnabled = True
        else:
            self.chBRange = chRange
            self.chBEnabled = True

        self.setChannelDataBuffer(channelName)
        assert_pico_ok(self.status[channelName])

    def disableAllChannel(self):
        channel = ps.PS3000A_CHANNEL['PS3000A_CHANNEL_A']
        chRange = ps.PS3000A_RANGE['PS3000A_1V']
        couplingType = ps.PS3000A_COUPLING['PS3000A_DC']
        self.status['CHANNEL_A'] = ps.ps3000aSetChannel(
                                    self.chandle, 
                                    channel, 
                                    0, # disable
                                    couplingType, 
                                    chRange, 
                                    0
                                   )
        channel = ps.PS3000A_CHANNEL['PS3000A_CHANNEL_B']
        chRange = ps.PS3000A_RANGE['PS3000A_1V']
        couplingType = ps.PS3000A_COUPLING['PS3000A_DC']
        self.status['CHANNEL_B'] = ps.ps3000aSetChannel(
                                    self.chandle, 
                                    channel, 
                                    0, #disable
                                    couplingType, 
                                    chRange, 
                                    0
                                   )

        self.chAEnabled = False
        self.chBEnabled = False


    def setTrigger(self, channelName= 'CHANNEL_A', thresholdmv = 500,
                   direction = 'RISING_EDGE', autoTriggerDelay = 2000):
        """
        Configure trigger channel
        parameters
        -----
        channelName : string
            possible values : CHANNEL_A|CHANNEL_B|EXTERNAL
        """
        # Set up single trigger
        # handle = chandle
        # enabled = 1
        if channelName == 'CHANNEL_A':
            chan = 'PS3000A_CHANNEL_A'
            chRange = self.chARange
        elif channelName == 'CHANNEL_B':
            chan = 'PS3000A_CHANNEL_B'
            chRange = self.chBRange
        elif channelName == 'EXTERNAL':
            chan = 'PS3000A_EXTERNAL'
            chRange = ps.PS3000A_RANGE['PS3000A_5V']
        else:
            print('scope.setTrigger: channel name not supported: use (CHANNEL_A, CHANNEL_B, EXTERNAL)')
            raise
        source = ps.PS3000A_CHANNEL[chan]

        threshold = int(mV2adc(thresholdmv, chRange, self.maxADC))

        if direction == 'RISING_EDGE':
            direction = ps.PS3000A_THRESHOLD_DIRECTION['PS3000A_RISING']
        else:
            direction = ps.PS3000A_THRESHOLD_DIRECTION['PS3000A_FALLING']

        self.status["trigger"] = ps.ps3000aSetSimpleTrigger(self.chandle,
                                    1,  # enable
                                    source,
                                    threshold,
                                    direction,
                                    0,  # delay
                                    autoTriggerDelay # auto trigger ms
                                )
        assert_pico_ok(self.status["trigger"])

    def setSamplingInterval(self, samplingIntervalns):
        """
        Calculate timebase (n) to satisfy maxSampiling interval (minSamplingFreq)
        See Programmer's guide page 8
        prameters: samplingInterval : number of nano second between every two samples
        returns : maximum timebase value the can provide (samplingInterval or less)
        """
        if samplingIntervalns < 8:
            self.timebase = int(math.log(samplingIntervalns,2))
        elif samplingIntervalns>= 8 and samplingIntervalns < 1000000000:
            self.timebase = int(samplingIntervalns / 8 + 2)

        print('Calculated timebase = {}'.format(self.timebase))

        self.timeIntervalns = ctypes.c_float()
        self.returnedMaxSamples = ctypes.c_int16()
        self.status["getTimebase2"] = ps.ps3000aGetTimebase2(
            self.chandle,
            self.timebase,
            self.maxSamples,
            ctypes.byref(self.timeIntervalns),
            1,
            ctypes.byref(self.returnedMaxSamples),
            0
        )
        print('Actual Sampling Interval ns: {}'.format(self.timeIntervalns))
        print('Max Samples: {}'.format(self.returnedMaxSamples))
        assert_pico_ok(self.status["getTimebase2"])

    def setChannelDataBuffer(self, channelName):
        if channelName == 'CHANNEL_A':
            self.bufferA = (ctypes.c_int16 * self.maxSamples)()
            source = ps.PS3000A_CHANNEL["PS3000A_CHANNEL_A"]
            self.status["setDataBuffersA"] = ps.ps3000aSetDataBuffer(
                                                self.chandle,
                                                source,
                                                ctypes.byref(self.bufferA),
                                                self.maxSamples,
                                                0,
                                                0
                                            )
            assert_pico_ok(self.status["setDataBuffersA"])

        elif channelName == 'CHANNEL_B':
            self.bufferB = (ctypes.c_int16 * self.maxSamples)()
            source = ps.PS3000A_CHANNEL["PS3000A_CHANNEL_B"]
            self.status["setDataBuffersB"] = ps.ps3000aSetDataBuffer(
                                                self.chandle,
                                                source,
                                                ctypes.byref(self.bufferB),
                                                self.maxSamples,
                                                0,
                                                0
                                            )
            assert_pico_ok(self.status["setDataBuffersB"])

        else:
            raise Exception('Invalid channel name. Valid names: CHANNEL_A or CHANNEL_B')

    def arm(self):
        self.status["runBlock"] = ps.ps3000aRunBlock(
                                    self.chandle,
                                    self.preTriggerSamples,
                                    self.postTriggerSamples,
                                    self.timebase,
                                    1,
                                    None,
                                    0,  # segment index
                                    None,
                                    None
                                )
        assert_pico_ok(self.status["runBlock"])

    def readTrace(self):
        ready = ctypes.c_int16(0)
        check = ctypes.c_int16(0)
        while ready.value == check.value:
            self.status["isReady"] = ps.ps3000aIsReady(self.chandle, ctypes.byref(ready))

        overflow = ctypes.c_int16()
        self.cmaxSamples = ctypes.c_int32(self.maxSamples)
        self.status["getValues"] = ps.ps3000aGetValues(
                                    self.chandle, 0,
                                    ctypes.byref(self.cmaxSamples),
                                    0, 
                                    0, 
                                    0, 
                                    ctypes.byref(overflow)
                                   )
        assert_pico_ok(self.status["getValues"])
        trace = np.array(self.bufferA)
        return trace

    def readTracev(self):
        ready = ctypes.c_int16(0)
        check = ctypes.c_int16(0)
        # busy wait
        while ready.value == check.value:
            self.status["isReady"] = ps.ps3000aIsReady(self.chandle, ctypes.byref(ready))

        overflow = ctypes.c_int16()
        self.cmaxSamples = ctypes.c_int32(self.maxSamples)
        self.status["getValues"] = ps.ps3000aGetValues(
                                       self.chandle, 
                                       0, 
                                       ctypes.byref(self.cmaxSamples), 
                                       0,
                                       0, 
                                       0, 
                                       ctypes.byref(overflow))
        assert_pico_ok(self.status["getValues"])
        trace = np.array(adc2mV(self.bufferA, self.chARange, self.maxADC )) / 1000.0
        return trace

    def closeConnection(self):
        self.status["stop"] = ps.ps3000aStop(self.chandle)
        assert_pico_ok(self.status["stop"])

        self.status["close"] = ps.ps3000aCloseUnit(self.chandle)
        assert_pico_ok(self.status["close"])

        print(self.status)


def main():
    # Setup
    scope = Picoscope(sampleResolution=8, postTriggerSamples=1000)
    scope.setChannel(channelName='CHANNEL_A', rangemv=1000)
    scope.setSamplingInterval(samplingIntervalns=8)
    scope.setTrigger(channelName='CHANNEL_A', direction='RISING_EDGE',
                     thresholdmv=200)
    # scope.setDataBuffers()
    # in loop
    scope.arm()
    trace = scope.readTrace()

    plt.plot(trace)
    plt.ylim(0, 20000)
    plt.show()
    scope.closeConnection()


if __name__ == '__main__':
    main()
