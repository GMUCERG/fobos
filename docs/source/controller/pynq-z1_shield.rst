.. _control-pynqZ1-setup-label:

Pynq-Z1 Setup with FOBOS Shield
===============================
Below, we describe how to setup the FOBOS Shield with the Pynq-Z1 board. 

Modifying the Pynq-Z1 Board
---------------------------

    In order to use the FOBOS Shield, a small modification has to be made to the Pynq-Z1 board. 
    On the Pynq board, the 200 Ohm resistor R88 in the line IO29 of the ADC clock has to be 
    removed and replaced with a blob of solder or 0 Ohm resistor. The resistor attenuates the ADC clock signal too much.
    The board with the removed resistor is shown in (:numref:`fig_pynq_modification`).

.. _fig_pynq_modification:
.. figure::  ../figures/pynq-modifications-rev2.png
   :align:   center
   :scale: 30 %

   Modifications to Pynq-Z1 for FOBOS Shield

Attach the FOBOS Shield
-----------------------

    Carefully align the connectors of the FOBOS Shield with the Pynq-Z1 Arduino/Chipkit headers and 
    firmly press down to securely connect the boards.

.. _fig_pynqZ1_shield:
.. figure::  ../figures/fobos-shield-rev2.jpg
   :align:   center
   :scale: 20 %

   Pynq-Z1 with FOBOS Shield

Connecting the Control Board
----------------------------

    You have two options to power the Pynq-Z1 board, either through USB or through an external 7V-15V DC power supply
    connected to the barrel connector J18.

    If you choose the power the Pynq-Z1 board from USB, you have to set the jumper JP5 on the Pynq-Z1 board to ``USB``.
    The FOBOS shield requires more power than USB can supply, so you have to connect an external 
    well regulated 5V DC power supply to the FOBOS Shield J17 barrel connector and select ``EXT`` on 
    jumper JP3 on the shield. USB has only sufficient power for the Pynq board.

    If you choose to power the Pynq-Z1 board with an external power supply then the FOBOS Shield
    can be powered from the Pynz-Z1 board. Set the jumper JP5 on the Pynq-Z1 board to ``REG``. 
    Select ``INT`` on jumper JP3 on the FOBOS Shield.

    Connect the Pynq-Z1 board to your network with an Ethernet cable (CAT-5 or better for optimal performance).

    Only during installation, or if you choose to power the Pynq-Z1 board through USB, is the connection from 
    the SCA workstation to the Pynq-Z1 board via USB requiered.
    
    Power-up the boards using the power switch SW4 on the Pynq-Z1 board.
    

