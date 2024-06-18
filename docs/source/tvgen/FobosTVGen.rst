.. _FobosTVGen:

==========
FobosTVGen
==========

FobosTVGen, provided with FOBOS,  generates test vectors for cryptographic functions using the simple 
FOBOS DUT Protocol described in :numref:`dut-protocol`.


Generating Test Vectors for SCA
-------------------------------

The library of FobosTVGen can be loaded into your Jupyter notebook with:

.. code-block:: python
    
    from foboslib.capture.fobosTVGen import FobosTVGen

FobosTvGen requires that a file with the key already exists. The code below defines a key and creates such a file.

.. code-block:: python
    :caption: Python code to run in Jupyter Notebook for defining a key for AES

    # create key file in the workspace directory
    KEY = "01 23 45 67 89 ab cd ef 00 11 22 33 44 55 66 77"
    keyFileName = "keyfile.txt"
    keyFile = open(keyFileName, "w")
    keyFile.write(KEY )
    keyFile.close()

The following code is the invocation of FobosTVGen. It creates 10 test vectors for AES. It requires 
the key file and will produce all other required files. The file names can contain path information. 
Associated data and the nonce are optional files and won't be generated when commented out as shown 
below. 

.. code-block:: python
    :caption: FobosTVGen parameters for AES

    # Generate test vectors
    tvGen = FobosTVGen(traceNum=10,                       # number of text vectors
                       blockSize=16,                      # bytes of plaintext per block
                       #adSize=16,                        # bytes of associated data per block
                       #nonceSize=2,                      # bytes of nonce for each encryption
                       keySize=16,                        # key size in bytes
                       cipherSize=16,                     # cipher output block size in bytes
                       dinFile= "dinFile.txt",            # file name for the FOBOS test vector file
                       plaintextFile= "plaintext.txt",    # file name for the plaintext 
                       #associateDataFile= "ad.txt",      # file name for the associated data
                       #nonceFile= "nonce.txt",           # file name for the nonce
                       keyFile="keyfile.txt"              # file name of the key file
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

Generating Test Vectors for TVLA 
--------------------------------

