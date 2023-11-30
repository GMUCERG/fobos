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
from picosdk.ps6000 import ps6000 as ps
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
        # Create chandle and status ready for use
        self.chandle = ctypes.c_int16()
        self.status = {}
        # This is an 8-bit scope
        if sampleResolution == 8:
            pass
        else:
            raise Exception("Scope resolution not supported." +
                            " only 8 bits resolution is supported")

        self.sampleResolution = sampleResolution
        self.status["openunit"] = ps.ps6000OpenUnit(
            ctypes.byref(self.chandle),
            None
        )

        assert_pico_ok(self.status["openunit"])

        self.disableAllChannel()
        # Set number of samples
        self.preTriggerSamples = preTriggerSamples
        self.postTriggerSamples = postTriggerSamples
        self.maxSamples = self.preTriggerSamples + self.postTriggerSamples
        # Max ADC value depends on resolution. Prog manual page 10
        self.maxADC = ctypes.c_int16()
        #self.status["maximumValue"] = ps.ps6000MaximumValue(
        #    self.chandle,
        #    ctypes.byref(self.maxADC))
        #assert_pico_ok(self.status["maximumValue"])

    def setChannel(self, channelName='CHANNEL_A',
                   coupling='DC_1M', rangemv='1V'):
        """
        Configure volatge range and coupling for a channel.
        parameters:
        -----
        channelName : string
            possible values : CHANNEL_A | CHANNEL_B | CHANNEL_C | CHANNEL_D
        coupling : string
            possible values :  AC | DC_1M | DC_50R
        ranegmv : string
            Voltage range 50MV - 500MV, 1V-20V
        """
        # Set up channel A
        # handle = chandle
        if channelName == 'CHANNEL_A':
            chan = "PS6000_CHANNEL_A"
        elif channelName == 'CHANNEL_B':
            chan = "PS6000_CHANNEL_B"
        elif channelName == 'CHANNEL_C':
            chan = "PS6000_CHANNEL_C"
        elif channelName == 'CHANNEL_D':
            chan = "PS6000_CHANNEL_D"
        else:
            raise Exception("Scope channel supported. Please select one of CHANNEL_A,  CHANNEL_B, CHANNEL_C, or CHANNEL_D")

        channel = ps.PS6000_CHANNEL[chan]
        # enabled = 1
        if coupling == 'AC':
            coup = "PS6000_AC"
        elif coupling == 'DC_1M':
            coup = "PS6000_DC_1M"
        elif coupling == 'DC_50R':
            coup = "PS6000_DC_50R"
        else:
            raise Exception("Scope coupling supported. Please select one of AC, DC_1M, or DC_50R")
        couplingType = ps.PS6000_COUPLING[coup]
        ##set range
        if rangemv == '50mV':
            srange = "PS6000_50MV"
        elif rangemv == '100mV':
            srange = "PS6000_100MV"
        elif rangemv == '200mV':
            srange = "PS6000_200MV"
        elif rangemv == '500mV':
            srange = "PS6000_500MV"
        elif rangemv == '1V':
            srange = "PS6000_1V"
        elif rangemv == '2V':
            srange = "PS6000_2V"
        elif rangemv == '5V':
            srange = "PS6000_5V"
        elif rangemv == '10V':
            srange = "PS6000_10V"
        elif rangemv == '20V':
            srange = "PS6000_20V"
        else:
            raise Exception("Scope voltage range supported. Supported ranges:" +
                    "\t50mV, 100mV, 200mV, 500mV, 1V, 2V, 5V, 10V, 20V.")


        chRange = ps.PS6000_RANGE[srange]
        # analogue offset = 0 V
        # bandwidth limiter = PS6000_BW_FULL
        self.status[channelName] = ps.ps6000SetChannel(
                                    self.chandle, channel, 
                                    1, 
                                    couplingType, 
                                    chRange, 
                                    0,
                                    0)
        if channelName == 'CHANNEL_A':
            self.chARange = chRange
            self.chAEnabled = True
        if channelName == 'CHANNEL_B':
            self.chBRange = chRange
            self.chBEnabled = True
        if channelName == 'CHANNEL_C':
            self.chCRange = chRange
            self.chCEnabled = True
        else:
            self.chDRange = chRange
            self.chDEnabled = True

        self.setChannelDataBuffer(channelName)
        assert_pico_ok(self.status[channelName])

    def disableAllChannel(self):

        channel = ps.PS6000_CHANNEL['PS6000_CHANNEL_A']
        chRange = ps.PS6000_RANGE['PS6000_1V']
        couplingType = ps.PS6000_COUPLING['PS6000_DC_1M']
        self.status['CHANNEL_A'] = ps.ps6000SetChannel(self.chandle, channel, 0, 
                            couplingType, chRange, 0, 0)
        channel = ps.PS6000_CHANNEL['PS6000_CHANNEL_B']
        chRange = ps.PS6000_RANGE['PS6000_1V']
        couplingType = ps.PS6000_COUPLING['PS6000_DC_1M']
        self.status['CHANNEL_B'] = ps.ps6000SetChannel(self.chandle, channel, 0, 
                            couplingType, chRange, 0, 0)
        channel = ps.PS6000_CHANNEL['PS6000_CHANNEL_C']
        chRange = ps.PS6000_RANGE['PS6000_1V']
        couplingType = ps.PS6000_COUPLING['PS6000_DC_1M']
        self.status['CHANNEL_C'] = ps.ps6000SetChannel(self.chandle, channel, 0, 
                            couplingType, chRange, 0, 0)
        channel = ps.PS6000_CHANNEL['PS6000_CHANNEL_D']
        chRange = ps.PS6000_RANGE['PS6000_1V']
        couplingType = ps.PS6000_COUPLING['PS6000_DC_1M']
        self.status['CHANNEL_D'] = ps.ps6000SetChannel(self.chandle, channel, 0, 
                            couplingType, chRange, 0, 0)

        self.chAEnabled = False
        self.chBEnabled = False
        self.chCEnabled = False
        self.chDEnabled = False


    def setTrigger(self, channelName= 'CHANNEL_A', thresholdmv = 500,
                    direction = 'RISING_EDGE', autoTriggerDelay = 2000):
        """
        Configure trigger channel
        parameters
        -----
        channelName : string
            possible values : CHANNEL_A|CHANNEL_B|CHANNEL_C|CHANNEL_D|EXTERNAL
        """
        # Set up single trigger
        # handle = chandle
        # enabled = 1
        if channelName == 'CHANNEL_A':
            chan = 'PS6000_CHANNEL_A'
            chRange = self.chARange
        elif channelName == 'CHANNEL_B':
            chan = 'PS6000_CHANNEL_B'
            chRange = self.chBRange
        elif channelName == 'CHANNEL_C':
            chan = 'PS6000_CHANNEL_C'
            chRange = self.chBRange
        elif channelName == 'CHANNEL_D':
            chan = 'PS6000_CHANNEL_D'
            chRange = self.chBRange
        elif channelName == 'EXTERNAL':
            chan = 'PS6000_TRIGGER_AUX'
            chRange = ps.PS6000_RANGE['PS6000_5V']
        else:
            print('scope.setTrigger: channel name not supported: use (CHANNEL_A, CHANNEL_B, CHANNEL_C, CHANNEL_D, or EXTERNAL)')
            raise
        source = ps.PS6000_CHANNEL[chan]

        threshold = int(mV2adc(thresholdmv, chRange, self.maxADC))
        # direction = PS5000A_RISING = 2
        # delay = 0 s
        # auto Trigger = 1000 ms
        if direction == 'RISING_EDGE':
            direction = ps.PS6000_THRESHOLD_DIRECTION['PS6000_RISING']
        else:
            direction = ps.PS6000_THRESHOLD_DIRECTION['PS6000_FALLING']

        self.status["trigger"] = ps.ps6000SetSimpleTrigger(self.chandle,
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
        See Programmer's guide page 24
        prameters: samplingInterval : number of nano second between every two samples
        returns : maximum timebase value the can provide (samplingInterval or less)
        """
        if samplingIntervalns < 6.4:
            self.timebase = int(math.log((samplingIntervalns *10),2)-1)
        elif samplingIntervalns>= 6.4 and samplingIntervalns < 5000000000:
            self.timebase = int((samplingIntervalns *10) / 64 + 4)

        print('Calculated timebase = {}'.format(self.timebase))

        self.timeIntervalns = ctypes.c_float()
        self.returnedMaxSamples = ctypes.c_int32()
        # oversample (1)
        self.status["getTimebase2"] = ps.ps6000GetTimebase2(
            self.chandle,
            self.timebase,
            self.maxSamples,
            ctypes.byref(self.timeIntervalns),
            1,
            ctypes.byref(self.returnedMaxSamples), 0)
        print('Actual Sampling Interval ns: {}'.format(self.timeIntervalns))
        print('Max Samples: {}'.format(self.returnedMaxSamples))
        assert_pico_ok(self.status["getTimebase2"])

    def setChannelDataBuffer(self, channelName):
        if channelName == 'CHANNEL_A':
            self.bufferA = (ctypes.c_int16 * self.maxSamples)()
            source = ps.PS6000_CHANNEL["PS6000_CHANNEL_A"]
            self.status["setDataBuffersA"] = ps.ps6000SetDataBuffer(
                self.chandle,
                source,
                ctypes.byref(self.bufferA),
                self.maxSamples,
                0)
            assert_pico_ok(self.status["setDataBuffersA"])

        if channelName == 'CHANNEL_B':
            self.bufferB = (ctypes.c_int16 * self.maxSamples)()
            source = ps.PS6000_CHANNEL["PS6000_CHANNEL_B"]
            self.status["setDataBuffersB"] = ps.ps6000SetDataBuffer(
                self.chandle,
                source,
                ctypes.byref(self.bufferB),
                self.maxSamples,
                0)
            assert_pico_ok(self.status["setDataBuffersB"])

        if channelName == 'CHANNEL_C':
            self.bufferC = (ctypes.c_int16 * self.maxSamples)()
            source = ps.PS6000_CHANNEL["PS6000_CHANNEL_C"]
            self.status["setDataBuffersC"] = ps.ps6000SetDataBuffer(
                self.chandle,
                source,
                ctypes.byref(self.bufferC),
                self.maxSamples,
                0)
            assert_pico_ok(self.status["setDataBuffersC"])

        if channelName == 'CHANNEL_D':
            self.bufferD = (ctypes.c_int16 * self.maxSamples)()
            source = ps.PS6000_CHANNEL["PS6000_CHANNEL_D"]
            self.status["setDataBuffersD"] = ps.ps6000SetDataBuffer(
                self.chandle,
                source,
                ctypes.byref(self.bufferD),
                self.maxSamples,
                0)
            assert_pico_ok(self.status["setDataBuffersD"])

    def arm(self):
        self.status["runBlock"] = ps.ps6000RunBlock(
            self.chandle,
            self.preTriggerSamples,
            self.postTriggerSamples,
            self.timebase,
            1, #oversampling
            None,
            0,  # segment index
            None, None)
        assert_pico_ok(self.status["runBlock"])

    def readTrace(self):
        # Check for data collection to finish using ps5000aIsReady
        ready = ctypes.c_int16(0)
        check = ctypes.c_int16(0)
        while ready.value == check.value:
            self.status["isReady"] = ps.ps6000IsReady(self.chandle,
                                                       ctypes.byref(ready))

        overflow = ctypes.c_int16()
        # create converted type maxSamples
        self.cmaxSamples = ctypes.c_int32(self.maxSamples)
        self.status["getValues"] = ps.ps6000GetValues(
                                    self.chandle, 0,
                                    ctypes.byref(self.cmaxSamples),
                                    1, 
                                    0, 
                                    0, 
                                    ctypes.byref(overflow))
        assert_pico_ok(self.status["getValues"])
        # convert ADC counts data to mV
        #adc2mVChAMax =  adc2mV(bufferAMax, chARange, maxADC)
        #adc2mVChBMax =  adc2mV(bufferBMax, chBRange, maxADC)
        trace = np.array(self.bufferA)
        return trace

    def readTracev(self):
        # Check for data collection to finish using ps5000aIsReady
        ready = ctypes.c_int16(0)
        check = ctypes.c_int16(0)
        while ready.value == check.value:
            self.status["isReady"] = ps.ps6000IsReady(self.chandle, ctypes.byref(ready))

        overflow = ctypes.c_int16()
        # create converted type maxSamples
        self.cmaxSamples = ctypes.c_int32(self.maxSamples)
        self.status["getValues"] = ps.ps6000GetValues(self.chandle, 0, 
                                ctypes.byref(self.cmaxSamples), 
                                0, 0, 0, ctypes.byref(overflow))
        assert_pico_ok(self.status["getValues"])
        # convert ADC counts data to mV
        #adc2mVChAMax =  adc2mV(bufferAMax, chARange, maxADC)
        #adc2mVChBMax =  adc2mV(bufferBMax, chBRange, maxADC)
        #trace = np.array(self.bufferA)
        trace = np.array(adc2mV(self.bufferA, self.chARange, self.maxADC )) / 1000.0
        return trace

    def closeConnection(self):
        self.status["stop"] = ps.ps6000Stop(self.chandle)
        assert_pico_ok(self.status["stop"])

        # Close unit Disconnect the scope
        # handle = chandle
        self.status["close"] = ps.ps6000CloseUnit(self.chandle)
        assert_pico_ok(self.status["close"])

        # display status returns
        print(self.status)


def main():
    # Setup
    scope = Picoscope(sampleResolution=8, postTriggerSamples=1000)
    scope.setChannel(channelName='CHANNEL_A', rangemv='1V')
    scope.setSamplingInterval(samplingIntervalns=8)
    scope.setTrigger(channelName='CHANNEL_A', direction='RISING_EDGE',
                     thresholdmv=200)
    # scope.setDataBuffers()
    # in loop
    scope.arm()
    trace = scope.readTrace()

    plt.plot(trace)
    plt.show()
    scope.closeConnection()


if __name__ == '__main__':
    main()
