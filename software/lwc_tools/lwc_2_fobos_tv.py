import os
import argparse
import lwc_2_fobos

def main():
    # ------------------------------------------------------------------
    parser = argparse.ArgumentParser(description = 'Convert shared LWC test vectors to FOBOS-ready')

    parser.add_argument('--tv_type', default=None, type=str, required=True, 
                        help='tvla or random')
    parser.add_argument('--width', default=None, type=int, required=True, 
                        help='word width in bits')
    parser.add_argument('--shares', default=None, type=int, required=True,
                        help='number of shares')
    parser.add_argument('--num_vectors', default=None, type=int, required=True, 
                        help='number of fixed-vs-random test vectors')

    parser.add_argument('--pdi_file', default=None, type=str, required=True, 
                        help='LWC PDI file name')
    parser.add_argument('--sdi_file', default=None, type=str, required=True, 
                        help='LWC SDI file name')
    parser.add_argument('--do_file', default=None, type=str, required=True, 
                        help='LWC DO file name')

    parser.add_argument('--fobos_din_file', default='dinFile.txt', type=str,
                        help='FOBOS-ready test vector file')
    parser.add_argument('--fobos_fvr_file', default='fvrchoicefile.txt', type=str,
                        help='FOBOS-ready fixed-vs-random map file')

    parser.add_argument('--data_dir', default='.', type=str,
                        help='The directory where data files are stored')

    args = parser.parse_args()

    #-----------------------------------------------------------------------

    lwc_2_fobos.gen_test_vectors(args.tv_type,
                                 args.num_vectors,
                                 args.width, 
                                 args.shares, 
                                 os.path.join(args.data_dir, args.pdi_file),
                                 os.path.join(args.data_dir, args.sdi_file),
                                 os.path.join(args.data_dir, args.do_file),
                                 os.path.join(args.data_dir, args.fobos_din_file),
                                 os.path.join(args.data_dir, args.fobos_fvr_file))

main()
