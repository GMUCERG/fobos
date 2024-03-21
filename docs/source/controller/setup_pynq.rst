.. _control-pynq-setup-label:

Pynq-Z1/Z2 Firmware Setup 
=========================
Below, we describe how to setup the Pynq-Z1/Z2 and the FOBOS 3.0 firmware on the Pynq board. 

Requirements
------------

#. A PC with Linux installed.
#. Python3 is installed.
#. Xilinx Vivado 2022.1 is in the search path.
#. FOBOS 3 is downloaded and unpacked on the PC (see :ref:`fobos-pc-install`).
#. Digilent Pynq-Z1/Z2 board (control board) with the PYNQ SD card image v3.0.1 installed from http://www.pynq.io/board.html.


Setup Pynq to use static IP address
-----------------------------------

    In order to connect to your Pynq board from the SCA workstation reliably, you have to make sure that 
    the Pynq board uses a static IP address. If you reserved a static IP address for your Pynq board in your 
    *dhcp* server, then you don't need to complete the following steps.

    Make sure you have a USB connection to the Pynq board and can connect 
    to it with a terminal program such as *minicom* (Linux) or *terra term* (Windows). 
    
    Connect to the Pynq board using the terminal application and edit ``/etc/network/interfaces.d/eth0``. 
    Replace the address with an available IP address on your network and the gateway with the IP address 
    of your internet gateway. 
    
    .. code-block:: 
   
        auto eth0
        iface eth0 inet dhcp
        
        auto eth0:1
        iface eth0:1 inet static
                address 192.168.2.99
                netmask 255.255.255.0
                gateway 192.168.2.1


    Next remove the existing ``resolv.conf`` as it is a symbolic link

    .. code-block:: bash
   
        sudo rm /etc/resolv.conf

    and create a new file ``resolv.conf`` that contains your favourite / company nameserver or Google's nameserver
    as shown below.

    .. code-block:: 

        nameserver 8.8.8.8

    Now restart the networking services to apply these changes.

    .. code-block:: bash

        sudo /etc/init.d/networking restart

    .. important::
        #. Make sure that the Pynq board and the SCA Workstation are connected via Ethernet and you can reach the Pynq board from the PC using ``ssh``.
        #. Make sure that the Pynq boad has the correct time. Check with the ``date`` command. The time will be in UTC which is in winter 5 hours ahead of EST and in summer 4 hours ahead of EDT. If not, probably the name resolution failed. Check if you can ``ping www.google.com``.


    Now you can remove the USB cable from the Pynq.

Install Additional Packages on Pynq
-----------------------------------

    #. Connect to the Pynq via ssh.

    #. Update the package list to get the latest available packages.

        .. code-block:: bash
   
            sudo apt-get update 
   
    #. (Optional) Install GNU Midnight Commander *mc*, a visual file manager that runs in full-screen text mode.

        .. code-block:: bash
  
            sudo apt install mc

    #. In order to run the calibration script for power measurements install the following python modules.

        .. code-block:: bash
        
            sudo pip install pyvisa
            sudo pip install pyvisa-py



Build the Pynq Overlay
----------------------

    The creation of the Pynq Overlay file for FOBOS is completely scripted and can be accomplished in just a few steps. Make sure ``vivado`` version 2022.1 is in the search path. Select the make option based on your Pynq board and the revision of the FOBOS shield as shown in :numref:`tab_makefile`.

    .. _tab_makefile:
    .. table:: Makefile options

       +-----------+-----------------------------+
       |           |       **FOBOS Shield**      |
       +-----------+--------------+--------------+
       | **Board** | **rev 1**    | **rev 2**    |
       +===========+==============+==============+
       | PYNQ Z1   | pynq_z1_rev1 | pynq_z1_rev2 |
       +-----------+--------------+--------------+
       | PYNQ Z2   | pynq_z2_rev1 | ---          |
       +-----------+--------------+--------------+
    
    #. ``cd fobos/control/pynqctrl/vivado/``
    #. ``make pynq_z2_rev1``
    #. ``make synth``
    #. Go and make yourself a cup of coffee or tea, this is going to take a while.
    #. When Vivado is done, you will have the files pynq_ctrl.bit and pynq_ctrl.hwh in the
       ``fobos/control/pynqctrl/vivado/`` directory.

Install FOBOS Firmware
----------------------

    The next step is to get the FOBOS firmware and the newly created overlay onto the Pynq Board.

    #. Start the Pynq board and make sure it completed its start-up procedure, i.e., the 4 user LEDs are flashing and then stay lit.
    #. Copy the ``fobos/software`` directory to the ``/home/xilinx/`` directory on the Pynq board 
       using scp or sftp so that the software can be found in ``/home/xilinx/fobos/software``.
    #. Copy the files ``pynq_ctrl.bit`` and ``pynq_ctrl.hwh`` from ``fobos/control/pynqctrl/vivado/`` 
       to your Pynq board into the ``/home/xilinx/fobos/software/firmware/pynq`` directory.
    #. Use ssh to get a command prompt on the Pynq board, change directory to the ``fobos/software/firmware/pynq`` 
       directory and run the script ``sudo ./install-pynq.sh``. 
       It will ask you several questions about your Pynq setup, install the necessary files, and 
       start the FOBOS server called ``pynqserver``.

       FOBOS stores its configuration in the file ``fobos/software/firmware/pynq/config/pynq_conf.py``. 


Trouble Shooting
----------------

FOBOS creates two log files in the ``/tmp`` directory of the Pynq board.

``fobos.log`` shows what the FOBOS server is doing including the commands it receives from the SCA Workstation and the corresponding responses. 

``fobos-watchdog.log`` shows the status of the FOBOS server. The watchdog restarts the FOBOS server when it becomes unresponsive. 

