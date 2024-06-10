.. _CryptoTVGen

============
CryptoTVGen
============

Install CryptoTVGen
-------------------

Requirements:

OS: Tested on Linux and macOS

Dependencies:	

* Python 3.6.5 or newer	
* GNU Make 3.82	or newer
* C compiler (e.g. gcc or clang)	

Install the latest version of CryptoTVGen::

   sudo /opt/jupyterhub/bin/python3 -m pip install -U 'git+https://github.com/GMUCERG/LWC#subdirectory=software/cryptotvgen&egg=cryptotvgen'

To enable cryptotvgen in your jupyter notebook issue the command::

    from cryptotvgen import cli

To automatically download, extract, and build an LWC candidates from the latest available version of SUPERCOP::

    cli.run_cryptotvgen(['--prepare_libs', 'ascon128v12'])

 
It installs the available reference library of Ascon128v12  to the directory shown below::

    ~/.cryptotvgen/supercop


Generating test vectors
-----------------------

All the necessary python scripts can be found in the following folder::

 /fobos/software/lwc_tools

All the generated output files can be found in the following folder::

 /fobos/software/lwc_tools/KAT
 
Generate an LWC test vector. This can be a short test vector. For example to generate test vectors for Ascon (refer cryptotvgen help for more information), type this into your jupyter notebook. ::

    args = [
        '--aead', 'ascon128v12',
        '--io',   '32', '32', # PDI/DO, SDI
        #              new key, decrypt, AD_LEN, PT_LEN, hash
        '--gen_custom', 'False, False, 16, 16, False'
    ]
    cli.run_cryptotvgen(args)

