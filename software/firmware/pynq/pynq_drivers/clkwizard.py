import math
from pynq import DefaultIP

class ClockWizard(DefaultIP):
    """
    ClockWizard is the Python driver for the ClockWizard IP Core.
    """
    
    reg0_offset = 0x0
    reg_offset = 0x208
    size_clk_regs = 0xC
    div_offset = 0x0
    phase_offset = 0x4
    duty_offset = 0x8
    busClk = 100 #clock wizard input frequency
    def __init__(self, description, *args, **kwargs):
        """
        Construct a new 'Clock Wizard' object.
        """
        super().__init__(description=description)
    def readConfigReg0(self):
        return self.mmio.read(self.reg0_offset)

    def clearConfigReg0(self):
        self.mmio.write(self.reg0_offset, 0)
    def readDiv(self, clk_index):
        """
        Read the divisor for a clock_out.

        :return: returns 32-bit register value
        """
        return self.mmio.read(self.reg_offset + (self.size_clk_regs*clk_index) + self.div_offset)
    def readPhase(self, clk_index):
        """
        Read the divisor for a clock_out.

        :return: returns 32-bit register value
        """
        return self.mmio.read(self.reg_offset + (self.size_clk_regs*clk_index) + self.phase_offset)
    def readDuty(self, clk_index):
        """
        Read the divisor for a clock_out.

        :return: returns 32-bit register value
        """
        return self.mmio.read(self.reg_offset + (self.size_clk_regs*clk_index) + self.duty_offset)
    def writeDiv(self, clk_index, integer, fraction):
        """
        Write the divisor for a clock_out.

        """
        div = self.mmio.read(self.reg_offset + (self.size_clk_regs*clk_index) + self.div_offset)
        div = (div & 0xffffff00) | (integer & 0xFF)
        div = (div & 0xfffc00ff) | ((fraction & 0x3FF) << 8)
        self.mmio.write(self.reg_offset + (self.size_clk_regs*clk_index) + self.div_offset, div)

    def writePhase(self, clk_index, integer):
        self.mmio.write(self.reg_offset + (self.size_clk_regs*clk_index) + self.phase_offset, integer)

    def readClk0Div(self):
        return self.readDiv(0)

    def readClk0Phase(self):
        return self.readPhase(0)

    def writeClk0Div(self, integer, fraction):
        self.writeDiv(0, integer, fraction)

    def writeClk0Phase(self, integer):
        self.writePhase(0, integer)
    

    def setClock0Freq(self, clkKHz):
        clockValue = clkKHz / 1000
        if (clockValue > 100 or clockValue < 1):
            raise Exception('Clk may only be between 1 and 100 MHz')
        if clockValue > 15: # make sure clk is reliable
            self.mmio.write(0x200, 0x00000a01) #set mul to 10 and div to 1
        else:
            self.mmio.write(0x200, 0x00000102) #set mul to 1  and div to 2
        conf = self.readConfigReg0()
        # print('clkout %x' %conf)
        intDiv = conf & 0xff
        intMult = (conf & 0xff00) >> 8
        fracMult = (conf & 0x3ff0000) >> 16
        # print('%d %d %d' % (intDiv, intMult, fracMult))
        while fracMult > 1:
            fracMult = fracMult / 10
        clkOut = (self.busClk * (intMult + fracMult)) / intDiv
        # print('clkout %d' %clkOut)
        divisor = clkOut / clockValue
        divInt = math.floor(divisor)
        divFrac = divisor - divInt
        # print('divInt')
        # print(divInt)
        # print('divFrac')
        # print(divFrac)
        divFracStored = divFrac
        if divFrac != 0:
            while (divFrac < 1024):
                divFrac = divFrac * 10
            divFrac = math.floor(divFrac / 10)
        finalClk = clkOut / (divInt + divFracStored)
        # print('divInt')
        # print(divInt)
        # print('divFrac')
        # print(int(divFrac))
        self.writeClk0Div(divInt, int(divFrac))
        ##apply config
        self.mmio.write(0x25c, 0x00000003)
        # print("Set clk frequency to {}".format(finalClk))
        return finalClk
    
    bindto = ['xilinx.com:ip:clk_wiz:6.0']
