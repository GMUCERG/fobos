# Example for Generation of FOBOS-ready TVLA test vectors for protected implementation

1. Generate an LWC test vector. This can be a short test vector and it will be used as a template. Specifcially, headers will be used as is and pdi data will be replaced by random data or fixed data while the sdi will be kept as is. The data will be reshared in every test vector.

    ```cryptotvgen --npub_size 128 --tag_size 128 --aead xoodyakv1 --gen_custom False,False,16,16,False
    ```
2. Convert into shared format.

    ```python gen_shared.py --rdi-file rdi.txt --pdi-file pdi.txt --sdi-file sdi.txt --rdi-width 1152 --pdi-width 32 --sdi-width 32 --pdi-shares 2 --sdi-shares 2 --rdi-words 1000
    ```
3. Convert to FOBOS-ready TVLA test vectors
    python lwc_2_fobos_tv.py --tv_type tvla --width 32 --shares 2 --num_vectors 10 --pdi_file pdi_shared_2.txt --sdi_file sdi_shared_2.txt --do_file do.txt --fobos_din_file dinFile3.txt --fobos_fvr_file fvrchoicefile3.txt --data_dir example/


# Example for Generation of FOBOS-ready test vectors for DPA for unprotected implementation

1. Generate an LWC test vector. This can be a short test vector and it will be used as a template. Specifcially, headers will be used as is and pdi data will be replaced by random data.

    ```cryptotvgen --npub_size 128 --tag_size 128 --aead xoodyakv1 --gen_custom False,False,16,16,False
    ```

2. Convert to FOBOS-ready test vectors
    python lwc_2_fobos_tv.py --tv_type random --width 32 --shares 1 --num_vectors 10 --pdi_file pdi_shared_2.txt --sdi_file sdi_shared_2.txt --do_file do.txt --fobos_din_file dinFile3.txt --fobos_fvr_file fvrchoicefile3.txt --data_dir example/



# Example for calling lwc test vector gernator from python

Instead of using the terminal, one can call lwc_2_fobos test vector generator as follows:

    import lwc_2_fobos

    lwc_2_fobos.gen_test_vectors(tv_type        = 'tvla', # 'tvla' or 'random'
                                 num_vectors    = 10
                                 width          = 32,     # in bits
                                 shares         = 2,
                                 pdi_file       = 'pdi_shared_2.txt',
                                 sdi_file       = 'sdi_shared_2.txt',
                                 do_file        = 'do.txt',
                                 fobos_din_file = 'dinFile.txt',
                                 fobos_fvr_file = 'fvrchoicefile3.txt',
                                 --data_dir     = 'example/'
    )