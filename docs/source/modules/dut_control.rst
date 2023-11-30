.. _dut_control-label:

DUT Control Module
******************

This module controls the operation of the Device Under Test (DUT) and provides 
the clock signal for the DUT as well as functions that are related to the DUTs 
clock domain.

Setting DUT Clock
=================

The control board can provide a clock for the DUT ranging from 400 KHz to 100 MHz. The default value is 5 MHz.
To set it, use the following method:

.. code-block:: python

    ctrl.setDUTClk(clkValue)

**Note:** Setting the DUT clock will set the OutLen, TriggerMode, DUTInterface back to default settings as well as reset the DUT.


DUT Selection
=============

The target connector (FOBOS Shield) is based on the ChipWhisperer target connector. 
Some DUTs though do not follow the FOBOS target connector specification. This module 
allows to switch the pin mappings based on the selected DUT. The DUT options are: 

- DUT_FOBOS : A DUT that follows the FOBOS target connector specification
- DUT_CW305 : The ChipWhisperer CW305 board does not connect the reset pin to the FPGA. Therefore, we use the FD2C_CLK pin for FC_RST.
- DUT_MTC   : Enables I2C communication to a microcontroller DUT connected to the FOBOS Multi-Target Connector (MTC).
- DUT_CW308 : Enables serial communication.

.. code-block:: python

    ctrl.setDUT(FOBOSCtrl.Value)

 
Trigger Settings
================

The controller can send a trigger to the Oscilloscope once the DUT starts processing the data (i.e., di_ready = 0). Or it can be configured to trigger any number of clock cycles after this event occurs.

- TRIGGER_WAIT_CYCLES : The number of clock cycles after which the trigger is asserted (after di_ready goes to zero).
- TRIGGER_LENGTH_CYCLES : The time the trigger signal is asserted.
- TRIGGER_TYPE : possible values: TRG_NORM | TRG_FULL | TRG_NORM_CLK | TRG_FULL_CLK
        - TRG_NORM : normal trigger mode. In this mode the TRIGGER_WAIT_CYCLES and TRIGGER_LENGTH_CYCLES are applied.
        - TRG_FULL : Full trigger mode. While DUT is running (between di_ready = 0 and do_valid = 1) the trigger is asserted.
        - TRG_NORM_CLK : same as TRG_NORM but the trigger signal is AND-ed with the clock.
        - TRG_FULL_CLK : same as TRG_FULL but the trigger signal is AND-ed with the clock.
.. - CUT_MODE : Controls how the trace retrieved from the scope will be processed. Possible values: FULL | TRIG_HIGH
..         - FULL : The trace is cut starting at the rising edge of the trigger to the end of the screen.
..         - TRIG_HIGH : The trace is cut from the rising edge to the falling edge of the trigger i.e., the trace where the trigger is high will be saved.

.. code-block:: python

    ctrl.TriggerMode(FOBOSCtrl.Value)

.. **Bakry** 

.. - Why is TRIGGER_TYPE now TriggerMode?
.. - What happens when to the openADC module when TRG_FULL_CLK is selected?


DUT Reset Feature
=================

In some cases, the control board may need to reset the DUT because the interesting part of the victim algorithm has already executed. This is specifically valuable for ciphers that take a long time to complete. In this case, the cipher runs for a configurable number of clock cycles and then is reset without waiting for it to complete. This helps reduce acquisition time.
The number of cycles is counted after di_ready goes to 0.
Note: When you use this feature, no output is returned from the DUT.
To set it use the following command and set TIME_TO_RESET to any number other than zero. This number is set to zero by default which disables this feature.

.. code-block:: python

    ctrl.setTimeToReset(TIME_TO_RST)


Timeout Setting
===============

In some cases, due to communication error or DUT non-responsiveness the control board sends a 
timeout error message to the control PC when a configurable time has elapsed. The default value is 5 
seconds which is enough for almost all cases. Once timeout is reached, the control board resets the DUT, clears any pending DUT data transfers and return the timeout status to the capture software.
To set the timeout value, use the method:

.. code-block:: python

    ctrl.setTimeout(TIMEOUT)


Glitch Setting
==============

.. **Bakry**, please document the glitch module!


DUT Working Counter
===================

This module counts the number of clock cycles that passed between the DUT starting an operation to when it completes the operation. This is very useful for automatic benchmarking and for verifying simulation results.

.. code-block:: python

    ctrl.getWorkCount()



..
    Below, we show how the pins on the Basys3 PMOD ports are assinged. ::

    #JA
    #+----------+----------+----------+----------+
    #|          |  din3    |  do_ready|  rst     |
    #|  G2      |  J2      |  L2      |  J1      |
    #+----------+----------+----------+----------+
    #|  din0    |  din2    |  din1    |  do_valid|
    #|  G3      |  H2      |  K2      |  H1      |
    #+----------+----------+----------+----------+

    #JXADC
    #+----------+----------+----------+----------+
    #|  dout1   |  dout3   |  di_ready|  dut_clk |
    #|  N2      |  M2      |  L3      |  J3      |
    #+----------+----------+----------+----------+
    #|  dout0   |  dout2   |  di_valid|          |
    #|  N1      |  M1      |  M3      |  K3      |
    #+----------+----------+----------+----------+

    #JC
    #+----------+----------+----------+------------+
    #|          |          |          | trigger_out|
    #|          |          |          |            |
    #+----------+----------+----------+------------+
    #|          |          |          |            |
    #|          |          |          |            |
    #+----------+----------+----------+------------+
