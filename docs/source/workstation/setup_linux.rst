.. _fobos-linux-install:

==================
Linux Installation
==================
Below, we describe how to setup FOBOS 3.0 software and test that everything is working on Linux.


Requirements
------------
#. A PC with Ubuntu 22.04 installed.
#. FOBOS 3.0 ``fobos-v3.0.tgz`` file.
#. You must have ``sudo`` rights.

Setup Network Sharing (Optional)
--------------------------------

If your computer has two network interfaces, you can configure one to access the Internet and the other to connect to the Pynq board and maybe other instruments using a non routable IP address range. We describe here how to do this with Ubuntu 22.04.
In the example below, the network interface for the *instruments* network is ``enp2s0`` and the IP address range is ``192.168.2.1 - 192.168.255``.  You can find the names and the network information of your PC with the ``ip a show`` command. 

Create the file ``etc/netplan/20-instruments.yaml`` with the following contents and adjust the interface name and the IP address range to your requirements.

   .. code-block:: yaml
   
    network:
      ethernets:
        enp2s0:
          dhcp4: false
          addresses: [192.168.2.1/24]
      version: 2

Then apply these changes with ``sudo netplan apply``.

Edit the file ``/etc/sysclt.conf`` and uncomment ``net.ipv4.ip_forward=1`` to allow forwarding of packets between interfaces. Now apply these changes with 

   .. code-block:: bash
   
    sudo sysctl -p /etc/sysctl.conf
    sudo /etc/init.d/procps restart

Then configure iptables. Adjust the IP address range to match what you used above.

   .. code-block:: bash

    sudo iptables -A FORWARD -j ACCEPT
    sudo iptables -t nat -s 192.168.2.0/24 -A POSTROUTING -j MASQUERADE
    sudo apt-get install iptables-persistent

The last command will ask whether to apply the new rules, answer yes and then check if they are contained in the file ``/etc/iptables/rules.v4``.

Basic Downloads
---------------

Note: The following installation procedure was tested on Linux Ubuntu 22.04.

#. Download FOBOS from the `FOBOS home page <https://cryptography.gmu.edu/fobos/>`_.
#. Extract the archive into a directory of your choice

   .. code-block:: bash
   
       tar xvfz fobos-v3.0.tgz
    
   .. note::
       You can also clone FOBOS from `Github <https://github.com/GMUCERG/fobos>`_.
       Then you would skip steps 1 and 2 from above.

#. Use the following commands to install *pip* and *make*:

   .. code-block:: bash
   
       sudo apt-get install python3-pip
       sudo apt install make 

#. Enter the fobos directory and install the few necessary Python packages:

   .. code-block:: bash

       cd fobos
       sudo pip3 install -r requirements.txt


JupyterLab Installation
-----------------------

These installation instructions are based on 
`Install JupyterLab the Hard Way <https://github.com/jupyterhub/jupyterhub-the-hard-way/blob/HEAD/docs/installation-guide-hard.md>`_.

**Install JupyterHub and JupyterLab into a virtual environment**

#.  Install Python support for virtual environments.
    
    .. code-block:: bash

        sudo apt-get install python3-venv
    
#.  Create a virtual environment for JupyterHub and JupyterLab.
    
    .. code-block:: bash

        sudo python3 -m venv /opt/jupyterhub/
    
#.  Install JupyterHub and JupyterLab into this virtual environment.
    
    .. code-block:: bash

        sudo /opt/jupyterhub/bin/python3 -m pip install wheel
        sudo /opt/jupyterhub/bin/python3 -m pip install jupyterhub jupyterlab
        sudo /opt/jupyterhub/bin/python3 -m pip install ipywidgets
    
#.  Then install ``nodejs`` and ``npm`` to support the ``configurable-http-proxy`` that JupyterHub needs.
    
    .. code-block:: bash

        sudo apt install nodejs npm
        sudo npm install -g configurable-http-proxy

**Create JupyterHub configuration**

#.  Create a directory for the configuration files and generate the JupyterHub configuration file.

    .. code-block:: bash

        sudo mkdir -p /opt/jupyterhub/etc/jupyterhub/
        cd /opt/jupyterhub/etc/jupyterhub/
        sudo /opt/jupyterhub/bin/jupyterhub --generate-config

#.  Edit the config file we just created as root ``jupyterhub_config.py``
    and change the following settings.

    .. code-block:: python

        c.Spawner.notebook_dir = '~/notebooks/'     
        c.Spawner.default_url = '/lab'              

**Configure Systemd to automatically start JupyterHub**

#.  Create a folder for the systemd file

    .. code-block:: bash

        sudo mkdir -p /opt/jupyterhub/etc/systemd

#.  Then create as root the file ``/opt/jupyterhub/etc/systemd/jupyterhub.service``
    and past the following instructions into the file:

    .. code-block:: bash

       [Unit]
       Description=JupyterHub
       After=syslog.target network.target
       
       [Service]
       User=root
       Environment="PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/jupyterhub/bin"
       ExecStart=/opt/jupyterhub/bin/jupyterhub -f /opt/jupyterhub/etc/jupyterhub/jupyterhub_config.py
       
       [Install]
       WantedBy=multi-user.target

#.  Link this file to the Systemd's directory

    .. code-block:: bash

        sudo ln -s /opt/jupyterhub/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service

#.  Have systemd reload the configuration file

    .. code-block:: bash

        sudo systemctl daemon-reload

#.  Enable this service

    .. code-block:: bash

        sudo systemctl enable jupyterhub.service

#.  And finally start JupyterHub

    .. code-block:: bash

        sudo systemctl start jupyterhub.service

#.  You can always check if its running:

    .. code-block:: bash

        sudo systemctl status jupyterhub.service

    You can quit this status display by pressing ``q`` on the keyboard.

Conda Installation
------------------

These installation instructions are based on 
`Install JupyterLab the Hard Way <https://github.com/jupyterhub/jupyterhub-the-hard-way/blob/HEAD/docs/installation-guide-hard.md>`_.
We will use ``conda`` to manage the Python environments.

#.  Get the Anaconda public GPG key

    .. code-block:: bash

        cd 
        curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg
        sudo install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/
        rm conda.gpg

#.  Add Debian repository

    .. code-block:: bash

        echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" | sudo tee /etc/apt/sources.list.d/conda.list

#.  Install conda

    .. code-block:: bash

        sudo apt update
        sudo apt install conda

#.  Make conda easily available by running the setup script on login.

    .. code-block:: bash

        sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

#.  Install a default conda environment for all users. 
    But first check your version of python by issuing ``python3 --version`` on the command line.
    If necessary edit the version in the code below.

    .. code-block:: bash

        sudo mkdir /opt/conda/envs/
        sudo /opt/conda/bin/conda create --prefix /opt/conda/envs/python python=3.10 ipykernel
        sudo /opt/conda/envs/python/bin/python -m ipykernel install --prefix=/opt/jupyterhub/ --name 'python' --display-name "Python (default)"

FOBOS Software Installation
---------------------------

Finally we get to install FOBOS to run in the JupyterLab we just created.

#.  Install required packages

    .. code-block:: bash

        sudo /opt/jupyterhub/bin/python3 -m pip install numpy
        sudo /opt/jupyterhub/bin/python3 -m pip install matplotlib
        sudo /opt/jupyterhub/bin/python3 -m pip install scipy
        sudo /opt/jupyterhub/bin/python3 -m pip install console-progressbar

#.  Install packages required for PDF export of Jupyter notebooks

    .. code-block:: bash

        sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended 

#.  Install FOBOS into ``/opt/fobos`` by simply moving the whole directory tree.

    .. code-block:: bash

        sudo mv fobos /opt/


#.  Create notebooks folders in all users home directories and 
    copy fobos notebooks into the users notebook directories   

    .. code-block:: bash

        cd /home/username/
        mkdir -p notebooks/fobos
        cd notebooks/fobos
        cp -a /opt/fobos/software/notebooks/* .


Install DUT Support
-------------------

#.  **Chipwhisperer DUTs**

    These installation instructions are based on 
    `ChipWhisperer Linux Installation <https://chipwhisperer.readthedocs.io/en/latest/linux-install.html>`_.
    As we only want to program the DUTs we won't install everything.
    
    Create a directory for ChipWhisperer and clone it from git into this location

    .. code-block:: bash

        sudo mkdir /opt/chipwhisperer
        sudo chown $USER /opt/chipwhisperer
        cd /opt
        git clone https://github.com/newaetech/chipwhisperer

    Set the udev rules and make all users members of the corresponding groups so that they 
    can access the Chipwhisperer boards

    .. code-block:: bash

        sudo cp chipwhisperer/hardware/50-newae.rules /etc/udev/rules.d/
        sudo udevadm control --reload-rules
        sudo usermod -aG dialout $USER
        sudo usermod -aG plugdev $USER

    Repeat the last two lines for all users that have to access target boards.

    .. warning::

       If you don't have or want a *chipshisperer* group, replace *chipwhisperer* with *plugdev*
       in the file ``50-newae.rules``. Then don't add the user to the *chipwhisperer* group.


    Optional: Add the all users to the chipwhisperer group

    .. code-block:: bash

        sudo usermod -aG chipwhisperer $USER

    Add ChipWhisperer to our JupyterHub package directory and install require packages.

    .. code-block:: bash

        sudo ln -s /opt/chipwhisperer/software/chipwhisperer/ /opt/jupyterhub/lib/python3.10/site-packages/
    
    Install the additional software packages that ChipWhisperer needs

    .. code-block:: bash

        sudo /opt/jupyterhub/bin/python3 -m pip install pyusb
        sudo /opt/jupyterhub/bin/python3 -m pip install libusb1
        sudo /opt/jupyterhub/bin/python3 -m pip install pyserial
        sudo /opt/jupyterhub/bin/python3 -m pip install tqdm
        sudo /opt/jupyterhub/bin/python3 -m pip install ECPy
        sudo /opt/jupyterhub/bin/python3 -m pip install configobj

#.  **Digilent DUTs**

    FPGA boards from Digilent Inc. require the Digilent Adept tools. Download the 
    latest versions of the following packages for Linux from
    `Digilent Adept Website <https://digilent.com/shop/software/digilent-adept/>`_ 
    and install them.
    
    - Adept for Linux Runtime 
    - Adept Utilities 

    Make sure that all users are members of the correct groups.

    .. code-block:: bash

        sudo usermod -aG dialout $USER
        sudo usermod -aG plugdev $USER


Install Oscilloscope Support
----------------------------

**PicoScope**

Go to the `Pico Tech Download page <https://www.picotech.com/downloads>`_ and select the 
latest version of PicoScope for your operating system. Follow the instructions on their 
webpage to install it.

In order for FOBOS to use a PicoSope you also have to install they Pico SDK.   
Create a directory ``sdk`` in your ``/opt/picoscope`` directory and give it your user 
rights.

.. code-block:: bash

    sudo mkdir /opt/picoscope/sdk
    sudo chown $USER /opt/picoscope/sdk
    cd !$

Clone the Pico SDK into this directory and install it.

.. code-block:: bash

    git clone https://github.com/picotech/picosdk-python-wrappers.git
    cd picosdk-python-wrappers
    sudo /opt/jupyterhub/bin/python3 -m pip install .




Now the SCA Workstation should be ready.
