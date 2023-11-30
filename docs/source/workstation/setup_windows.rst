.. _fobos-windows-install:

====================
Windows Installation
====================
Below, we describe how to setup FOBOS 3.0 software and test that everything is working on Windows.


Requirements
------------
#. A PC with Windows 10 installed.
#. FOBOS 3.0 ``fobos-v3.0.zip`` file.
#. You must be able to obtain Administrator rights.

Basic Downloads
---------------

Note: The following installation procedure is not fully tested on Windows 10.

#. Download FOBOS from the `FOBOS home page <https://cryptography.gmu.edu/fobos/>`_.
#. Extract the archive into the directory of your choice


Install Python
--------------

#.  Download git for windows from https://git-scm.com/downloads
    and install with default options.

#.  Download WinPython 3.8 from https://winpython.github.io/
    and install (uncompress) it on the PC into ``C:\Users\username\WinPython``.

#.  Execute the program ``WinPython Control Panel`` and 
    select *Advanced->Register distribution* from the menu.
    However, you still have to manually add the path to where the python executable is to the system path.
    Check online on how to do this for your windows version.

#.  Configure your *git bash* to find python by adding its location to a ``.bashrc`` file. Start *git bash* 
    and enter:

    .. code-block:: bash

        alias python='winpty /c/Users/username/winPython/pypy3.8-v7.3.9-win64/python.exe    

    Please replace **username** with your username and **pypy3.8-v7.3.9-win64** with the directory name in your installation.

#.  Reboot Windows.

Install FOBOS
-------------

#.  Extract ``fobos-v3.0.zip`` into ``C:\Users\username\``.

#.  Open the command shell ``cmd`` as Administrator. In windows only an Administrator can set symbolic links.
    Execute the following commands.

    .. code-block:: cmd

        cd C:\Users\username
        cd fobos\software\notebooks
        del foboslib
        mklink /D foboslib ..\foboslib
        
        cd sca_labs
        del foboslib
        mklink /D foboslib ..\..\foboslib
        
        cd C:\Users\username\WinPython\notebooks
        mklink /D fobos ..\..\fobos\software\notebooks

#.  Now you should be able to execute ``Jupyter Lab.exe`` from your ``C:\Users\username\WinPython``
    directory. Be patient, it will take a while to fully start up. It will open your default web browser with the 
    JupyterLab Launcher. In the folder browser on the left will be a ``fobos`` folder containing the FOBOS 
    Jupyter notebooks.


Install DUT Support
-------------------

To be described
