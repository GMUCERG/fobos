.. _tvgen-label:

Test Vector Generation
**********************

The user must prepare test vectors before running data acquisition. User defined scripts or scripts provided with FOBOS can be used.
The data acquisition scripts will send the test vectors one at a time and collect traces from the oscilloscope.

Cryptographic hardware interfaces typically use multiple data types as input to cryptographic cores. 
For example, some algorithms might need plaintext/ciphertext, cryptographic keys, and random data. 
We provide a simple wrapper to split data provided by the control board to separate streams. 
This wrapper is directly compatible with CAESAR Hardware API interface and is expected to be directly compatible with a future Hardware API for Lightweight Cryptography (LWC API). 
We developed a simple, yet versatile protocol to enable the wrapper to split the data types. 
The wrapper receives data from the control board and distributes it into three FIFOs:

1. The Public Data Input (PDI) FIFO (i.e. plaintext) 
2. The Secret Data Input (SDI) FIFO (i.e. key) 
3. The Random Data Input (RDI) FIFO which stores random data which can be used for protected implementations that use masking schemes.

Once the wrapper prepares the data for the function core, it starts the core which consumes the data in the input FIFOs and produces output. 
The wrapper accumulates the output into a fourth FIFO called the Data Out (DO) FIFO until the expected number of bytes are stored. 
Then, the wrapper returns the data to the control board which forwards it back to the PC.

.. figure::  ../figures/fobos3-block.png
   :align:   center
   :height: 300 px

   FOBOS2 block diagram


.. toctree::
   :maxdepth: 1

   dut_protocol



Using FobosTVGen
====================================
The blockCipherTVGen.py can be used to generate test vectors to be used by block ciphers. The script is located at fobos/software/tvgen/
There are two steps to use it:

1. Set user defined parameters.
2. Run the script. It will generate the test vector file and plaintext file (not required for acquisition).

Load the library of FobosTVGen

.. code-block:: python
    
    from foboslib.capture.fobosTVGen import FobosTVGen

FobosTvGen requires that a file with the key does already exist. The code below creates such a file.

.. code-block:: python

    # create key file in the workspace directory
    KEY = "01 23 45 67 89 ab cd ef 00 11 22 33 44 55 66 77"
    keyFileName = "KAT/keyfile.txt"
    keyFile = open(keyFileName, "w")
    keyFile.write(KEY )
    keyFile.close()

The following code is the invocation of FobosTVGen. It creates 10 test vectors for AES. It requires 
the key file and will produce all other required files. In the case of AES, we don't need associated 
data and the nonce.

.. code-block:: python

    # Generate test vectors
    tvGen = FobosTVGen(traceNum=10,                           # number of text vectors
                       blockSize=16,                          # bytes of plaintext per block
                       #adSize=16,                            # bytes of associated data per block
                       #nonceSize=2,                          # bytes of nonce for each encryption
                       keySize=16,                            # key size in bytes
                       cipherSize=16,                         # cipher output block size in bytes
                       dinFile= "KAT/dinFile.txt",            # file name for the FOBOS test vector file
                       plaintextFile= "KAT/plaintext.txt",    # file name for the plaintext 
                       #associateDataFile= "KAT/ad.txt",      # file name for the associated data
                       #nonceFile= "KAT/nonce.txt",           # file name for the nonce
                       keyFile="KAT/keyfile.txt"              # file name of the key file
                       )
    tvGen.generateTVs()




Here is how the generated dinFile.txt looks like.::

    00C000103AD5305EBD0C99C7482263E2D7ECEAED00C1001012345...0081001000800001
    00C000105C09504D713BF9B5925601E671EA257800C1001012345...0081001000800001
    00C00010A6D6DE2548E4CCF446ECA8E620E4E55500C1001012345...0081001000800001
    00C00010E0792CDE9AFDA7EAC33A8D0EADE524CB00C1001012345...0081001000800001
    00C000104A09A00A4C4268F0B6F4FCE4F514A6BB00C1001012345...0081001000800001

This file can now be used in FOBOS as a test vector file.

A plaintext.txt file is also generated, it includes only the PDI portion dinFile.txt::

    3A D5 30 5E BD 0C 99 C7 48 22 63 E2 D7 EC EA ED
    5C 09 50 4D 71 3B F9 B5 92 56 01 E6 71 EA 25 78
    A6 D6 DE 25 48 E4 CC F4 46 EC A8 E6 20 E4 E5 55
    E0 79 2C DE 9A FD A7 EA C3 3A 8D 0E AD E5 24 CB
    4A 09 A0 0A 4C 42 68 F0 B6 F4 FC E4 F5 14 A6 BB


Manually Generation of FOBOS-ready TVLA test vectors 
====================================================

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
 



