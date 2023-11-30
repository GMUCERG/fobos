# Generation of FOBOS-ready TVLA test vectors

1. Generate an LWC test vector. This can be a short test vector. For example to generate test vectors for Xoodyak:

    ```cryptotvgen --npub_size 128 --tag_size 128 --aead xoodyakv1 --gen_custom False,False,16,16,False
    ```
2. Convert into shared format.

    ```python gen_shared.py --rdi-file rdi.txt --pdi-file pdi.txt --sdi-file sdi.txt --rdi-width 384 --pdi-width 32 --sdi-width 32 --pdi-shares 2 --sdi-shares 2 --rdi-words 1000
    ```
3. Convert to FOBOS-ready TVLA test vectors.

    ```python lwc_2_fobos_tv.py --width 32 --shares 2 --num_vectors 10 --pdi_file pdi_shared_2.txt --sdi_file sdi_shared_2.txt --do_file do.txt
    ```
