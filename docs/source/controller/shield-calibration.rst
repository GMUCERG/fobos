.. _power-calibration:

Power Calibration
-----------------

These steps explain how to calibrate the power measurement facilities of the FOBOS Shield. 

Power calibration requires that the SCA workstation, the Pynq Board and a Rigol DL3021A DC load are on the same network. The DC load should be on and the load function should be switched on. 

Use a webbrowser on the SCA workstation and connect to your Pynq board, e.g. http://192.168.2.99. 

Go to the *fobos* folder and start the *power_calibration.pynb* notebook.
Verify that the IP address for the DC load in the first cell is correct. If you want to use a different DC load, you have to edit the SCPI commands.

Execute the first cell. This takes a while the first time it is run.

Make sure that you connect the wires from the load as well as the sense wires to the power sources on the FOBOS shield as prompted by the script. 


