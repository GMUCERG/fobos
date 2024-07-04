FOBOS-Software
==============

  * `foboslib` contains all common FOBOS functions.
  * `notebooks` contains Jupyter notebooks that run within Jupyter Lab on the SCA workstation.
  * `lwc_tools` contains tools to make the GMU LWC Hardware API compatible with FOBOS.
  * `firmware` contains software that runs on FOBOS Control.

Installation on Pynq Board
--------------------------

Copy this `software` directory to the Pynq board via scp or sftp. Then go into the `firmware/pynq/` folder on Pynq and run the script `sudo ./install-pynq.sh`.

Installation on the SCA Workstation
-----------------------------------

Follow the instructions in the documentation.
It describes the installation on a Linux system. This can be used for a multi-user, remote accessible, installation. The documentation does not describe how to secure this installation and how to install SSL certificates. Please read the JupyterLab and JupyterHub documentation.

