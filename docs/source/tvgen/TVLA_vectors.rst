.. _TVLA_vectors:

===========================================
Generation of FOBOS-ready TVLA test vectors 
===========================================



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
 

