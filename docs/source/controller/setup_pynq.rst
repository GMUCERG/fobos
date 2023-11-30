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


Setup Pynq to use static IP address (optional)
----------------------------------------------

    This setup is optional and only needed if you attach the Pynq board to a network that does not 
    have a *dhcp* server. Make sure you have a USB connection to the Pynq board and can connect 
    to it with a terminal program such as *minicom* (Linux) or *terra term* (Windows). 
    
    Connect to the Pynq board using the terminal application and edit ``/etc/network/interfaces.d/eth0``. 
    Replace the address with an available IP address on your network and the gateway with the IP address 
    of your internet gateway. Pick any nameserver you like, this example shows Google's nameserver.
    
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


Install Additional Packages on Pynq
-----------------------------------

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

    The creation of the Pynq Overlay file for FOBOS is completely scripted and can be accomplished in just a few steps. Make sure ``vivado`` version 2022.1 is in the search path.
    
    #. ``cd fobos/control/pynqctrl/vivado/``
    #. ``make create_project``
    #. ``make synth``
    #. Go and make yourself a cup of coffee or tea, this is going to take a while.
    #. When Vivado is done, you will have the files pynq_ctrl.bit and pynq_ctrl.hwh in the
       ``fobos/control/pynqctrl/vivado/`` directory.

Install FOBOS Firmware
----------------------

    The next step is to get the FOBOS firmware and the newly created overlay onto the Pynq Board.

    #. Copy the ``fobos/software`` directory to the ``/home/xilinx/`` directory on the Pynq board 
       using scp or sftp so that the software can be found in ``/home/xilinx/fobos/software``.
    #. Copy the files ``pynq_ctrl.bit`` and ``pynq_ctrl.hwh`` from ``fobos/control/pynqctrl/vivado/`` 
       to your Pynq board into the ``/home/xilinx/fobos/software/firmware/pynq`` directory.
    #. Use ssh to get a comand prompt on the Pynq board, change directory to the ``fobos/software/firmware/pynq`` 
       directory and run the script ``sudo ./install-pynq.sh``. 
       It will ask you several questions about your Pynq setup, install the necessary files, and 
       start the pynqserver.


Testing the Control Board
-------------------------

