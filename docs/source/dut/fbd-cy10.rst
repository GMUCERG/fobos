.. _dut_fbd-cy10-label:

========================================
FOBOS FBD-Cy10 (Intel/Altera 10 LP FPGA)
========================================

.. figure::  ../figures/FBD-Cy10.jpg
   :align:   center
   :height: 350 px

   FOBOS FBD-Cy10 DUT with Intel/Altera Cyclone 10 LP-025 FPGA


Connection to FOBOS Shield control board
----------------------------------------

When using the FOBOS Shield, simply connect the 20pin ribbon cable to the target connector of the FOBOS Shield and the FBD-Cy10. 
Connect an SMA cable to the SMA connector J6 of the FBD-Cy10 and to the Measure connector J10 on the FOBOS Shield or to an oscilloscope for measuring changes in power consumption for SCA measurement.

.. figure::  ../figures/FOBOS3-Cyclone10LP-025_label.jpg
   :align:   center
   :height: 350 px


   FODOS 3 Setup with Cyclone 10 LP-025 DUT


Make sure to set the DUT to FOBOS and DUT interface to INTERFACE_4BIT in your Jupyter notebook using the following commands.
This configures the FOBOS Control to DUT communication.

.. code-block:: py

    ctrl.setDUT(FOBOSCtrl.FOBOS)
    ctrl.setDUTInterface(FOBOSCtrl.INTERFACE_4BIT) 


Implementing Cryptographic Algorithms for the FBD-Cy10 DUT
----------------------------------------------------------

Follow the instructions in :numref:`algorithm-implementation` and use the constraint file ``fbd-a7.xdc``.
Select the following device in Vivado.

.. _tab_FPGA_FBD-A7:
.. table:: FPGA Details of FBD-Cy10-025
    :align:   center

    +--------------+-------------------+
    | Family       | Cyclone 10LP      |
    +--------------+-------------------+
    | Package      | U256              |
    +--------------+-------------------+
    | Voltage      | Standard (1.2V)   |
    +--------------+-------------------+
    | Speed  Grade | 7                 |
    +--------------+-------------------+
    | Temperature  | I (-40 C - 100 C) |
    +--------------+-------------------+
    | Part         | 10CL025YU256I7G   |
    +--------------+-------------------+


Programming the FBD-Cy10 DUT
----------------------------

The DUT can only be programmed through the JTAG interface as of now. 
The capability to program the DUT directly from FOBOS Control or from the SPI flash is still being developed.

Programing the DUT requires that the Intel/Altera Quartus tools are installed on the SCA workstation. The directory 
for the quartus executables must be in the search path of the Jupyter installation. To accomplish this add the path to the 
quartus binary e.g.  ``/opt/intelFPGA_lite/24.1std/quartus/bin/`` to the PATH defined
in the file ``/opt/jupyterhub/etc/systemd/jupyterhub.service``.


.. code-block:: systemd
    Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/jupyterhub/bin:/opt/intelFPGA_lite/24.1std/quartus/bin"
    
Restart the SCA workstation for this change to take effect. You can easily try if quartus_pgm is in the search path by 
opening a terminal in your jupyter notebook and issue the command ``quatus_pgm --auto``. This command should return 
the programmer and the FPGA that it found.

..
    Example host configuration for an FBD-Cy10 target to be programmed with Quartus tools

    ..code-block:: json

        {
            "hostname" : "SCAWorkstation",
            "instances" : [
                {
                    "name" : "FBDCy10",
                    "ip" : "192.168.2.99",
                    "max_time_for_one_trace" : "2",
                    "dut":{
                        "type" : "altera_jtag",
                        "jtag_position" : "1"
                    }
        
                }
            ]
        }
        


..
    You can program the DUT using the following commands in your Jupyter notebook:

    .. code-block:: py

        from foboslib.capture.ctrl.host import Host
        host = Host()
        ctrl, target = host.connect(FBD-Cy10)
        target.program(bitfile = "crypto.sof")
        host.disconnect(ctrl)

Power Measurement
-----------------

To measure the power consumption, connect an SMA cable to the *Measure VCore Current* output J9 of the FBD-A7 and the CMS VAR alternate input J23 on the FOBOS Shield. Make sure that the jumper J28 on FOBOS Shield is pulled, see :numref:`fig_power_circuit`.

.. _fig_FBD-A7_power:
.. figure::  ../figures/FBD-Cy10-power.png
   :align:   center
   :height: 300 px


   FBD-Cy10 Power Block Diagram
