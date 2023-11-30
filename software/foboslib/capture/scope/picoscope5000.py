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
from picosdk.ps5000a import ps5000a as ps
import matplotlib.pyplot as plt
from picosdk.functions import adc2mV, assert_pico_ok, mV2adc


class Picoscope():

    def __init__(self, sampleResolution=8, preTriggerSamples=0,
                 postTriggerSamples=1000):
        """
        Open oscilloscope
        """
        # Create chandle and status ready for use
        self.chandle = ctypes.c_int16()
        self.status = {}
        # Open 5000 series PicoScope
        # Resolution set to 12 Bit
        if sampleResolution == 8:
            res = "PS5000A_DR_8BIT"
        elif sampleResolution == 12:
            res = "PS5000A_DR_12BIT"
        elif sampleResolution == 14:
            res = "PS5000A_DR_14BIT"
        elif sampleResolution == 15:
            res = "PS5000A_DR_15BIT"
        elif sampleResolution == 16:
            res = "PS5000A_DR_16BIT"
        else:
            raise Exception("Scope resolution not supported." +
                            " Please select one of 8,12,14,15,16")
        resolution = ps.PS5000A_DEVICE_RESOLUTION[res]
        self.sampleResolution = sampleResolution
        self.status["openunit"] = ps.ps5000aOpenUnit(
            ctypes.byref(self.chandle),
            None, resolution)

        try:
            assert_pico_ok(self.status["openunit"])
        except: # PicoNotOkError:
            powerStatus = self.status["openunit"]
            if powerStatus == 286:
                self.status["changePowerSource"] = ps.ps5000aChangePowerSource(
                    self.chandle,
                    powerStatus)
            elif powerStatus == 282:
                self.status["changePowerSource"] = ps.ps5000aChangePowerSource(
                    self.chandle,
                    powerStatus)
            else:
                raise Exception("Error initializing PicoScope")

            assert_pico_ok(self.status["changePowerSource"])

        self.disableAllChannel()
        # Set number of samples
        self.preTriggerSamples = preTriggerSamples
        self.postTriggerSamples = postTriggerSamples
        self.maxSamples = self.preTriggerSamples + self.postTriggerSamples
        # Max ADC value depends on resolution. Prog manual page 11
        self.maxADC = ctypes.c_int16()
        self.status["maximumValue"] = ps.ps5000aMaximumValue(
            self.chandle,
            ctypes.byref(self.maxADC))
        assert_pico_ok(self.status["maximumValue"])

    def setChannel(self, channelName='CHANNEL_A',
                   coupling='DC', rangemv='1V'):
        """
        Configure volatge range and coupling for a channel.
        parameters:
        -----
        channelName : string
            possible values : CHANNEL_A | CHANNEL_B
        coupling : string
            possible values DC | AC
        ranegmv : string
            Voltage range 10MV - 500MV, 1V-20V
        """
        # Set up channel A
        # handle = chandle
        if channelName == 'CHANNEL_A':
            chan = "PS5000A_CHANNEL_A"
        elif channelName == 'CHANNEL_B':
            chan = "PS5000A_CHANNEL_B"
        else:
            raise Exception("Scope channel supported. Please select one of CHANNEL_A or CHANNEL_B")

        channel = ps.PS5000A_CHANNEL[chan]
        # enabled = 1
        if coupling == 'DC':
            coup = "PS5000A_DC"
        elif coupling == 'AC':
            coup = "PS5000A_AC"
        else:
            raise Exception("Scope coupling supported. Please select one of DC or AC")
        couplingType = ps.PS5000A_COUPLING[coup]
        ##set range
        if rangemv == '10mV':
            srange = "PS5000A_10MV"
        elif rangemv == '20mV':
            srange = "PS5000A_20MV"
        elif rangemv == '50mV':
            srange = "PS5000A_50MV"
        elif rangemv == '100mV':
            srange = "PS5000A_100MV"
        elif rangemv == '200mV':
            srange = "PS5000A_200MV"
        elif rangemv == '500mV':
            srange = "PS5000A_500MV"
        elif rangemv == '1V':
            srange = "PS5000A_1V"
        elif rangemv == '2V':
            srange = "PS5000A_2V"
        elif rangemv == '5V':
            srange = "PS5000A_5V"
        elif rangemv == '10V':
            srange = "PS5000A_10V"
        elif rangemv == '20V':
            srange = "PS5000A_20V"
        else:
            raise Exception("Scope voltage range supported. Supported ranges:" +
                    "\t10mV, 20mV, 50mV, 100mV, 200mV, 500mV, 1V, 2V, 5V, 10V, 20V.")


        chRange = ps.PS5000A_RANGE[srange]
        # analogue offset = 0 V
        self.status[channelName] = ps.ps5000aSetChannel(self.chandle, channel, 1, 
                            couplingType, chRange, 0)
        if channelName == 'CHANNEL_A':
            self.chARange = chRange
            self.chAEnabled = True
        else:
            self.chBRange = chRange
            self.chBEnabled = True

        assert_pico_ok(self.status[channelName])

    def disableAllChannel(self):

        channel = ps.PS5000A_CHANNEL['PS5000A_CHANNEL_A']
        chRange = ps.PS5000A_RANGE['PS5000A_1V']
        couplingType = ps.PS5000A_COUPLING['PS5000A_DC']
        self.status['CHANNEL_A'] = ps.ps5000aSetChannel(self.chandle, channel, 0, 
                            couplingType, chRange, 0)
        channel = ps.PS5000A_CHANNEL['PS5000A_CHANNEL_B']
        chRange = ps.PS5000A_RANGE['PS5000A_1V']
        couplingType = ps.PS5000A_COUPLING['PS5000A_DC']
        self.status['CHANNEL_B'] = ps.ps5000aSetChannel(self.chandle, channel, 0, 
                            couplingType, chRange, 0)

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
            chan = 'PS5000A_CHANNEL_A'
            chRange = self.chARange
        elif channelName == 'CHANNEL_B':
            chan = 'PS5000A_CHANNEL_B'
            chRange = self.chBRange
        elif channelName == 'EXTERNAL':
            chan = 'PS5000A_EXTERNAL'
            chRange = ps.PS5000A_RANGE['PS5000A_5V']
        else:
            print('scope.setTrigger: channel name not supported: use (CHANNEL_A, CHANNEL_B, EXTERNAL)')
            raise
        source = ps.PS5000A_CHANNEL[chan]

        threshold = int(mV2adc(thresholdmv, chRange, self.maxADC))
        # direction = PS5000A_RISING = 2
        # delay = 0 s
        # auto Trigger = 1000 ms
        if direction == 'RISING_EDGE':
            direction = ps.PS5000A_THRESHOLD_DIRECTION['PS5000A_RISING']
        else:
            direction = ps.PS5000A_THRESHOLD_DIRECTION['PS5000A_FALLING']

        self.status["trigger"] = ps.ps5000aSetSimpleTrigger(self.chandle,
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
        See Programmer's guide page 22
        prameters: samplingInterval : number of nano second between every two samples
        returns : maximum timebase value the can provide (samplingInterval or less)
        """
        s = samplingIntervalns
        if self.sampleResolution == 8:
            if s < 8:
                n = int(math.log(s,2))
            elif s>= 8 and s < 1000000000:
                n = int(s / 8 + 2)

        elif self.sampleResolution == 12:
            if s < 2:
                raise Exception('Requested sampling interval not possible for current resolution = {} bit'.format(self.sampleResolution))
            elif s >= 2 and s < 16:
                n = int(math.log(s / 2, 2) + 1)
            elif s >= 16 and s < 1000000000:
                n = int(s / 16 + 3)

        elif self.sampleResolution == 14 or self.sampleResolution == 15:
            if s < 8:
                raise Exception('Requested sampling interval not possible for current resolution = {} bit'.format(self.sampleResolution))
            if s < 16:
                n = 3
            elif s >= 16 and s < 1000000000:
                n = int(s / 8 + 2)

        elif self.sampleResolution == 16:
            if s < 16:
                #print('Requested sampling interval not possible for current resolution = {} bit'.format(self.sampleResolution))
                raise Exception('Requested sampling interval not possible for current resolution = {} bit'.format(self.sampleResolution))
            if s < 32:
                n = 4
            elif s >= 32 and s < 1000000000:
                n = int(s / 16 + 3)

        else:
            raise Exception('Sampling Resolution not vaild')
        print('Calculated timebase = {}'.format(n))

        self.timebase = n

        self.timeIntervalns = ctypes.c_float()
        self.returnedMaxSamples = ctypes.c_int32()
        self.status["getTimebase2"] = ps.ps5000aGetTimebase2(
            self.chandle,
            self.timebase,
            self.maxSamples,
            ctypes.byref(self.timeIntervalns),
            ctypes.byref(self.returnedMaxSamples), 0)
        print('Actual Sampling Interval ns: {}'.format(self.timeIntervalns))
        print('Max Samples: {}'.format(self.returnedMaxSamples))
        assert_pico_ok(self.status["getTimebase2"])

    def setDataBuffers(self):
        if self.chAEnabled is True:
            self.bufferA = (ctypes.c_int16 * self.maxSamples)()
            self.bufferB = (ctypes.c_int16 * self.maxSamples)()
            source = ps.PS5000A_CHANNEL["PS5000A_CHANNEL_A"]
            self.status["setDataBuffersA"] = ps.ps5000aSetDataBuffer(
                self.chandle,
                source,
                ctypes.byref(self.bufferA),
                self.maxSamples,
                0,
                0)
            assert_pico_ok(self.status["setDataBuffersA"])

        if self.chBEnabled is True:
            source = ps.PS5000A_CHANNEL["PS5000A_CHANNEL_B"]
            self.status["setDataBuffersB"] = ps.ps5000aSetDataBuffer(
                self.chandle,
                source,
                ctypes.byref(self.bufferB),
                self.maxSamples,
                0,
                0)
            assert_pico_ok(self.status["setDataBuffersB"])

    def arm(self):
        self.status["runBlock"] = ps.ps5000aRunBlock(
            self.chandle,
            self.preTriggerSamples,
            self.postTriggerSamples,
            self.timebase,
            None,
            0,  # segment index
            None, None)
        assert_pico_ok(self.status["runBlock"])

    def readTrace(self):
        # Check for data collection to finish using ps5000aIsReady
        ready = ctypes.c_int16(0)
        check = ctypes.c_int16(0)
        while ready.value == check.value:
            self.status["isReady"] = ps.ps5000aIsReady(self.chandle,
                                                       ctypes.byref(ready))

        overflow = ctypes.c_int16()
        # create converted type maxSamples
        self.cmaxSamples = ctypes.c_int32(self.maxSamples)
        self.status["getValues"] = ps.ps5000aGetValues(
            self.chandle, 0,
            ctypes.byref(self.cmaxSamples),
            0, 0, 0, ctypes.byref(overflow))
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
            self.status["isReady"] = ps.ps5000aIsReady(self.chandle, ctypes.byref(ready))

        overflow = ctypes.c_int16()
        # create converted type maxSamples
        self.cmaxSamples = ctypes.c_int32(self.maxSamples)
        self.status["getValues"] = ps.ps5000aGetValues(self.chandle, 0, 
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
        self.status["stop"] = ps.ps5000aStop(self.chandle)
        assert_pico_ok(self.status["stop"])

        # Close unit Disconnect the scope
        # handle = chandle
        self.status["close"] = ps.ps5000aCloseUnit(self.chandle)
        assert_pico_ok(self.status["close"])

        # display status returns
        print(self.status)


def main():
    # Setup
    scope = Picoscope(sampleResolution=8, requestedSamplingInterval=2)
    scope.setChannel(channelName='CHANNEL_A', rangemv='1V')
    scope.setTrigger(channelName='CHANNEL_A', direction='RISING_EDGE',
                     thresholdmv=200)
    scope.setDataBuffers()
    # in loop
    scope.arm()
    trace = scope.getTrace()

    plt.plot(trace)
    plt.show()


if __name__ == '__main__':
    main()
