#############################################################################
#                                                                           #
#   Copyright 2021 CERG                                                     #
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
# FOBOS Shield Powermanager class
# Author: Jens-Peter Kaps
# GMU
# August 5, 2021
# This class hides the Powermanager hardware of the FOBOS Shield rev 2
# Rev 2 had 3 power channels: 3v3, 5v, Var supplying nominal 3.3V, 5V, 
# and a variable voltage between 0.9V and 3.65V respectively
import os, sys
from pynq import DefaultIP
import pandas as pd 
import time

# import conf from parent folder
#sys.path.append('../config/')
from pynq_drivers.config.pynq_conf import FOBOS_HOME, BOARD
class PowerDriver(DefaultIP):
    """
    Power is the Python driver for the FOBOS Power module
    """

    if(BOARD == "Pynq-Z1"):
        # Register Definitions (rev 2) Pynq Z1
        command       = 0x00
        status        = 0x04
        volt3v3       = 0x08
        current3v3    = 0x0C
        volt5v        = 0x10
        current5v     = 0x14
        voltvar       = 0x18
        currentvar    = 0x1C
        avgvolt3v3    = 0x20
        avgcurrent3v3 = 0x24
        avgvolt5v     = 0x28
        avgcurrent5v  = 0x2C
        avgvoltvar    = 0x30
        avgcurrentvar = 0x34
        maxvolt3v3    = 0x38
        maxcurrent3v3 = 0x3C
        maxvolt5v     = 0x40
        maxcurrent5v  = 0x44
        maxvoltvar    = 0x48
        maxcurrentvar = 0x4C
        volt_output   = 0x50
        samplecount   = 0x54

    if(BOARD == "Pynq-Z2"):
        # Register Definitions (rev 1) Pynq Z2
        command       = 0x00
        status        = 0x04
        volt3v3       = 0x10
        current3v3    = 0x14
        volt5v        = 0x18
        current5v     = 0x1C
        voltvar       = 0x08
        currentvar    = 0x0C
        avgvolt3v3    = 0x28
        avgcurrent3v3 = 0x2C
        avgvolt5v     = 0x30
        avgcurrent5v  = 0x34
        avgvoltvar    = 0x20
        avgcurrentvar = 0x24
        maxvolt3v3    = 0x40
        maxcurrent3v3 = 0x44
        maxvolt5v     = 0x48
        maxcurrent5v  = 0x4C
        maxvoltvar    = 0x38
        maxcurrentvar = 0x3C
        volt_output   = 0x50
        samplecount   = 0x54

    # Command and Status Bits
    power_good    = 0x00000001
    out_enable    = 0x00000001
    clear_bit     = 0x00000002
    busy          = 0x00000002
    trighw        = 0x00000100
    trigsw        = 0x00000200
    oflow         = 0x00000400

    # XADC and XBP  parameters
    xadc_limit = 65520
    xadc_resolution = 65535  # 2^16 -1
    xadc_max = 5 # Volt
    xadc_multiplier = xadc_max / xadc_resolution
    xbp_shunt = 0.1 # Ohm, should be 0.1
    xbpgains = [25, 50, 100, 200]
    varvolts = [3.65, 3.6, 3.55, 3.5, 3.45, 3.4, 3.35, 3.3, 3.25, 3.2, 3.15, 3.1, 3.05, 3, 2.95, 2.9, 2.85, 2.8, 2.75, 2.7,
                2.65, 2.6, 2.55, 2.5, 2.45, 2.4, 2.35, 2.3, 2.25, 2.2, 2.15, 2.1, 2.05, 2, 1.95, 1.9, 1.85, 1.8, 1.75, 1.7,
                1.65, 1.6, 1.55, 1.5, 1.45, 1.4, 1.35, 1.3, 1.25, 1.2, 1.15, 1.1, 1.05, 1, 0.95, 0.9]

    enCalibration = True
    calibration_file = "{}/software/firmware/pynq/pynq_drivers/config/power_conf.csv".format(FOBOS_HOME)
    
    callcurroffs = [250, 540, 250]
    
    def __init__(self, description, *args, **kwargs):
        """
        Construct a new 'Power' object.
        """
        super().__init__(description=description)   
        try:
            self.calibration_df = pd.read_csv(self.calibration_file)
        except:
            self.calibration_df = None
            print("Unable to load power manager calibration file")

    bindto = ['CERG:cerg:powermanager:1.1']

    def enableCalibration(self, cal):
        self.enCalibration = cal
    
    def GetCalibration(self, src, mtype, gain):
        if (self.calibration_df is None):
            return [0,0,0,0]
        
        cond = (self.calibration_df['source'] == src) & (self.calibration_df['gain'] == gain) & (self.calibration_df['type'] == mtype)
        if len(self.calibration_df.loc[cond].values.tolist()) < 1:
            return [0,0,0,0]
        else:
            
            coeffs = self.calibration_df.loc[cond].values.tolist()[0][3]
            coeffs = [float(x) for x in coeffs.strip('][').split(', ')]
            return list(coeffs)
    
    def writeGain3v3(self, gain):
        try:
            gainbits = self.xbpgains.index(gain)
        except ValueError:
            print("Valid gain values are: 25, 50, 100, and 200.")
        else:
            cmd = self.mmio.read(self.command)
            cmd = cmd & 0xFFFFFFF3
            cmd = cmd | (gainbits << 2)
            self.mmio.write(self.command,cmd)
            return 

    def readGain3v3(self):
        return (self.xbpgains[(self.mmio.read(self.status) >> 2) & 0x00000003])

    def writeGain5v(self, gain):
        try:
            gainbits = self.xbpgains.index(gain)
        except ValueError:
            print("Valid gain values are: 25, 50, 100, and 200.")
        else:
            cmd = self.mmio.read(self.command)
            cmd = cmd & 0xFFFFFFCF
            cmd = cmd | (gainbits << 4)
            self.mmio.write(self.command,cmd)
            return 

    def readGain5v(self):
        return (self.xbpgains[(self.mmio.read(self.status) >> 4) & 0x00000003])
    
    def writeGainVar(self, gain):
        try:
            gainbits = self.xbpgains.index(gain)
        except ValueError:
            print("Valid gain values are: 25, 50, 100, and 200.")
        else:
            cmd = self.mmio.read(self.command)
            cmd = cmd & 0xFFFFFF3F
            cmd = cmd | (gainbits << 6)
            self.mmio.write(self.command,cmd)
            return 

    def readGainVar(self):
        return (self.xbpgains[(self.mmio.read(self.status) >> 6) & 0x00000003])
    
    def readVarSetting(self):
        return (self.varvolts[(self.mmio.read(self.volt_output))])
    
    def writeVarSetting(self, value):
        try:
            voltbits = self.varvolts.index(value)
        except ValueError:
            print("Only voltages between 0.9V and 3.65V in 0.05V steps are allowed.")
            return 0
        else:
            self.mmio.write(self.volt_output, voltbits)
            return 1

    def enableVar(self):
        cmd = self.mmio.read(self.command)
        cmd = cmd | self.out_enable
        self.mmio.write(self.command, cmd)
        return
    
    def disableVar(self):
        cmd = self.mmio.read(self.command)
        cmd = cmd & ~self.out_enable
        self.mmio.write(self.command, cmd)
        return
    
    def checkVarGood(self):
        return (self.mmio.read(self.status) & self.power_good)
    
    def checkVarOn(self):
        return (self.mmio.read(self.command) & self.out_enable)

    
    def convertVoltVar(self, value):
        if (value >= self.xadc_limit):
            print("XADC clipped! Value read: {}".format(value))
            return -1
        value = value * self.xadc_multiplier
        if self.enCalibration:
            coeffs = self.GetCalibration("VAR", "VOLT", self.readGainVar()) 
            value = value + coeffs[0]*value**3 + coeffs[1]*value**2 + coeffs[2]*value + coeffs[3]   
        return value
   
    def convertVolt5v(self, value):
        if (value >= self.xadc_limit):
            print("XADC clipped! Value read: {}".format(value))
            return -1
        value = value * self.xadc_multiplier
        if self.enCalibration:
            coeffs = self.GetCalibration("5V", "VOLT", self.readGainVar()) 
            value = value + coeffs[0]*value**3 + coeffs[1]*value**2 + coeffs[2]*value + coeffs[3]   
        return value

    def convertVolt3v3(self, value):
        if (value >= self.xadc_limit):
            print("XADC clipped! Value read: {}".format(value))
            return -1
        value = value * self.xadc_multiplier
        if self.enCalibration:
            coeffs = self.GetCalibration("3V3", "VOLT", self.readGainVar()) 
            value = value + coeffs[0]*value**3 + coeffs[1]*value**2 + coeffs[2]*value + coeffs[3]   
        return value

    def convertCurrVar(self, value):
        if (value >= self.xadc_limit):
            print("XADC clipped! Value read: {}".format(value))
            return -1
        value = (value-self.callcurroffs[2]) * self.xadc_multiplier
        value = value / (self.xbp_shunt * self.readGainVar())
        if self.enCalibration:
            coeffs = self.GetCalibration("VAR", "CURR", self.readGainVar()) 
            value = value + coeffs[0]*value**3 + coeffs[1]*value**2 + coeffs[2]*value + coeffs[3]   
        return value
   
    def convertCurr3v3(self, value):
        if (value >= self.xadc_limit):
            print("XADC clipped! Value read: {}".format(value))
            return -1
        value = (value-self.callcurroffs[0]) * self.xadc_multiplier
        value = value / (self.xbp_shunt * self.readGain3v3())
        if self.enCalibration:
            coeffs = self.GetCalibration("3V3", "CURR", self.readGain3v3()) 
            value = value + coeffs[0]*value**3 + coeffs[1]*value**2 + coeffs[2]*value + coeffs[3]   
        return value

    def convertCurr5v(self, value):
        if (value >= self.xadc_limit):
            print("XADC clipped! Value read: {}".format(value))
            return -1
        value = (value-self.callcurroffs[1]) * self.xadc_multiplier
        value = value / (self.xbp_shunt * self.readGain5v())
        if self.enCalibration:
            coeffs = self.GetCalibration("5V", "CURR", self.readGain5v()) 
            value = value + coeffs[0]*value**3 + coeffs[1]*value**2 + coeffs[2]*value + coeffs[3]   
        return value

    def readVolt3v3(self):
        return self.convertVolt3v3(self.mmio.read(self.volt3v3))

    def readVolt5v(self):
        return self.convertVolt5v(self.mmio.read(self.volt5v))

    def readVoltVar(self):
        return self.convertVoltVar(value = self.mmio.read(self.voltvar))
       
    def readCurr3v3(self):
        return self.convertCurr3v3(self.mmio.read(self.current3v3))

    def readCurr5v(self):
        return self.convertCurr5v(self.mmio.read(self.current5v))
    
    def readCurrVar(self):
        return self.convertCurrVar(self.mmio.read(self.currentvar))
    
    def enableSwTrig(self):
        cmd = self.mmio.read(self.command)
        cmd = cmd | self.trigsw
        self.mmio.write(self.command, cmd)
        return        
    
    def disableSwTrig(self):
        cmd = self.mmio.read(self.command)
        cmd = cmd & ~self.trigsw
        self.mmio.write(self.command, cmd)
        return
    
    def statusSwTrig(self):
        return ((self.mmio.read(self.status) & self.trigsw) >> 9) 
    
    def enableHwTrig(self):
        cmd = self.mmio.read(self.command)
        cmd = cmd | self.trighw
        self.mmio.write(self.command, cmd)
        return        
    
    def disableHwTrig(self):
        cmd = self.mmio.read(self.command)
        cmd = cmd & ~self.trighw
        self.mmio.write(self.command, cmd)
        return
    
    def statusHwTrig(self):
        return ((self.mmio.read(self.status) & self.trighw) >> 8) 
    
    def clearregs(self):
        cmd = self.mmio.read(self.command)
        cmd = cmd | self.clear_bit
        self.mmio.write(self.command, cmd)
        cmd = cmd & ~self.clear_bit
        self.mmio.write(self.command, cmd)
        return
    
    def reset(self):
        self.mmio.write(self.command, self.clear_bit)
        self.mmio.write(self.command, 0x00000000)
        return
    
    def cntover(self):
        return ((self.mmio.read(self.status) & self.oflow) >> 10)
    
    def samplecnt(self):
        return self.mmio.read(self.samplecount)
    
    def readBusy(self):
        return ((self.mmio.read(self.status) & self.busy) >> 1)
    
    def readMaxVolt3v3(self):
        return self.convertVolt3v3(self.mmio.read(self.maxvolt3v3))
    
    def readMaxVolt5v(self):
        return self.convertVolt5v(self.mmio.read(self.maxvolt5v))
    
    def readMaxVoltVar(self):
        return self.convertVoltVar(self.mmio.read(self.maxvoltvar))
    
    def readAvgVolt3v3(self):
        return self.convertVolt3v3(self.mmio.read(self.avgvolt3v3))
    
    def readAvgVolt5v(self):
        return self.convertVolt5v(self.mmio.read(self.avgvolt5v))
    
    def readAvgVoltVar(self):
        return self.convertVoltVar(self.mmio.read(self.avgvoltvar))
    
    def readMaxCurr3v3(self):
        return self.convertCurr3v3(self.mmio.read(self.maxcurrent3v3))
    
    def readMaxCurr5v(self):
        return self.convertCurr5v(self.mmio.read(self.maxcurrent5v))
    
    def readMaxCurrVar(self):
        return self.convertCurrVar(self.mmio.read(self.maxcurrentvar))
    
    def readAvgCurr5v(self):
        return self.convertCurr5v(self.mmio.read(self.avgcurrent5v))
    
    def readAvgCurr3v3(self):
        return self.convertCurr3v3(self.mmio.read(self.avgcurrent3v3))
    
    def readAvgCurrVar(self):
        return self.convertCurrVar(self.mmio.read(self.avgcurrentvar))

    
class PowerManager():
    """
    FOBOS Power Manager collection of functions
    """

    PowerIF = None

    def __init__(self, overlay, useCalibration=True):
        self.PowerIF = overlay.powermanager_0
        self.PowerIF.enableCalibration(useCalibration)
        # read callibration values. If file does not exist promt user to run callibration
        # self.PowerIF.loadCal()
        

    def Gain3v3Set(self, gain):
        self.PowerIF.writeGain3v3(gain)

    def Gain3v3Get(self):
        return(self.PowerIF.readGain3v3())

    def Gain5vSet(self, gain):
        self.PowerIF.writeGain5v(gain)

    def Gain5vGet(self):
        return(self.PowerIF.readGain5v())

    def GainVarSet(self, gain):
        self.PowerIF.writeGainVar(gain)

    def GainVarGet(self):
        return(self.PowerIF.readGainVar())
        
    def OutVarOn(self):
        self.PowerIF.enableVar()
        trycnt = 0
        while True:
            try:
                self.PowerIF.checkVarGood()
            except 0:
                if trycnt > 2:
                    self.PowerIF.disableVar()
                    print("Var power is not good and now turned off. Check load.")
                    return
                trycnt = trycnt + 1
                timesleep(0.1)
            else:
                return(self.PowerIF.readVarSetting())
                return

    def OutVarOff(self):
        self.PowerIF.disableVar()
        
    def OutVarSet(self, value):
        if self.PowerIF.writeVarSetting(value):
            if self.PowerIF.checkVarOn():
                self.OutVarOn()  # run VarOn again to confirm if Power still good
        else:
            self.OutVarOff() # can't set invalid value, hence turn Var Power off.
            print("Var power is turned off.")
        
    def OutVarGet(self):
        return(self.PowerIF.readVarSetting())
        
    def MeasVolt3v3(self):
        return(self.PowerIF.readVolt3v3())

    def MeasVolt5v(self):
        return(self.PowerIF.readVolt5v())

    def MeasVoltVar(self):
        return(self.PowerIF.readVoltVar())

    def MeasCurr3v3(self):
        return(self.PowerIF.readCurr3v3())
    
    def MeasCurr5v(self):
        return(self.PowerIF.readCurr5v())
    
    def MeasCurrVar(self):
        return(self.PowerIF.readCurrVar())
    
    def TrigSwEnOn(self):
        self.PowerIF.enableSwTrig()
        
    def TrigSwEnOff(self):
        self.PowerIF.disableSwTrig()
        
    def TrigSwStat(self):
        if (self.PowerIF.statusSwTrig()):
            print("Software trigger has fired")
        else:
            print("Software trigger has not fired")

    def TrigHwEnOn(self):
        self.PowerIF.enableHwTrig()
        
    def TrigHwEnOff(self):
        self.PowerIF.disableHwTrig()
        
    def TrigHwStat(self):
        if (self.PowerIF.statusHwTrig()):
            print("Hardware trigger has fired")
            return 0
        else:
            print("Hardware trigger has not fired")
            return 1

    def MeasClear(self):
        """
        Clears all measurement results, i.e. average and maximum values as 
        well as the sample counter. Resets trigger status to not fired.
        """
        self.PowerIF.clearregs()
        
    def Reset(self):
        """
        Clears all measurement results, i.e. average and maximum values as 
        well as the sample counter. Resets trigger status to not fired.
        Also turns off var power, sets var power back to the default 3.65V. 
        Returns all gains back to default 25.
        """
        self.PowerIF.reset()
        
    def MeasCountValue(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown.")
            return -1
        else:
            return(self.PowerIF.samplecnt())
        
    def MeasCountOverflow(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown.")
            return 1
        else:
            print("Sample Counter has not overflown.")
            return 0
            
    def MeasBusy(self):
        """
        After a trigger (HW or SW) fiuntitledres, the powermanager will be busy
        until the trigger is released. While its busy, the maximum and 
        average values will be updated and won't be steady.
        -----
        Returns: int
            0 when not busy
            1 when busy
        """
        return(self.PowerIF.readBusy())
        
    def MeasMaxVolt3v3(self):
        return(self.PowerIF.readMaxVolt3v3())
    
    def MeasMaxVolt5v(self):
        return(self.PowerIF.readMaxVolt5v())
            
    def MeasMaxVoltVar(self):
        return(self.PowerIF.readMaxVoltVar())

        
    def MeasAvgVolt3v3(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown. Value will not be correct.")
        return(self.PowerIF.readAvgVolt3v3())
    
    def MeasAvgVolt5v(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown. Value will not be correct.")
        return(self.PowerIF.readAvgVolt5v())
            
    def MeasAvgVoltVar(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown. Value will not be correct.")
        return(self.PowerIF.readAvgVoltVar())

    def MeasMaxCurr3v3(self):
        return(self.PowerIF.readMaxCurr3v3())
    
    def MeasMaxCurr5v(self):
        return(self.PowerIF.readMaxCurr5v())
            
    def MeasMaxCurrVar(self):
        return(self.PowerIF.readMaxCurrVar())

    def MeasAvgCurr3v3(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown. Value will not be correct.")
        return(self.PowerIF.readAvgCurr3v3())
    
    def MeasAvgCurr5v(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown. Value will not be correct.")
        return(self.PowerIF.readAvgCurr5v())
            
    def MeasAvgCurrVar(self):
        if (self.PowerIF.cntover()):
            print("Sample Counter has overflown. Value will not be correct.")
        return(self.PowerIF.readAvgCurrVar())            

    # 
    # CaliVoltStart # start callibration
    # CaliCurrStart
    # 
 
