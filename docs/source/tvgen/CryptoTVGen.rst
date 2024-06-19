.. _CryptoTVGen:

============
CryptoTVGen
============

CryptoTVGen is  used to generate test vectors that comply with the 
GMU LWC Hardware API :cite:`kaps_hardware_2022`.

CyrptoTVGen is documented on its `Github Page <https://github.com/GMUCERG/LWC/blob/master/software/cryptotvgen/README.md>`_.
After installation a comprehensive help page can also be accessed through ``cli.run_cryptotvgen(['-h'])``.

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


Generating Test Vectors
-----------------------

Generate an LWC test vector. This can be a short test vector. For example to generate test vectors for Ascon (refer cryptotvgen help for more information), type this into your jupyter notebook. ::

    args = [
        '--aead', 'ascon128v12',
        '--io',   '32', '32', # PDI/DO, SDI
        #              new key, decrypt, AD_LEN, PT_LEN, hash
        '--gen_custom', 'False, False, 16, 16, False'
    ]
    cli.run_cryptotvgen(args)


Generation of FOBOS-ready TVLA test vectors 
-------------------------------------------

Convert into shared format (in this example 2 shares)::

 python3 gen_shared.py --rdi-file rdi.txt --pdi-file pdi.txt --sdi-file sdi.txt --rdi-width 384 --pdi-width 32 --sdi-width 32 --pdi-shares 2 --sdi-shares 2 --rdi-words 1000

Convert to FOBOS-ready TVLA test vectors::

 python3 lwc_2_fobos_tv.py --width 32 --shares 2 --num_vectors 10 --pdi_file pdi_shared_2.txt --sdi_file sdi_shared_2.txt --do_file do.txt

Where::

 --npub_size: size of the public message number in Bytes
 --tag_size: size of the tag in Bytes
 --aead: algorithm variant name
 --gen_custom: Randomly generate multiple test vectors, with each test vector specified using the following fields.
 --gen_custom NEW_KEY (Boolean), DECRYPT (Boolean), AD_LEN, PT_LEN or CT_LEN or HASH_LEN, HASH (Boolean)
 --rdi-width: width of the rdi port in Bits
 --rdi-words: number of random words in Bytes
 
Final output contains two files and are shown below::
 
 fvrchoicefile.txt
 dinFile.txt
 

