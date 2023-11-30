## File : unshare.py
## Purpose : Combines Boolean-shared data file
## Author : Abubakr Abdulgadir
## Date : June 2022

import sys
import argparse

parser = argparse.ArgumentParser(description = 'Combines Boolean-shared data file')

parser.add_argument('--width', default=None, type=int, required=True, 
                    help='word width in bits')
parser.add_argument('--shares', default=None, type=int, required=True,
                    help='number of shares')
parser.add_argument('--in_file', default=None, type=str, required=True, 
                    help='word width in bits')
parser.add_argument('--out_file', default=None, type=str, required=True,
                    help='number of shares')

args = parser.parse_args()

shares = args.shares
num_chars = args.width // 4

in_file = open(args.in_file, 'r')
lines = in_file.readlines()
in_file.close()

out_file = open(args.out_file, 'w')

for line in lines:
    line = line.strip().replace(' ', '')
    split_line = [line[i:i+num_chars] for i in range(0, len(line), num_chars)]
    unshared_line = []
    for i in range(0, len(split_line), shares):
        word = split_line[i:i+shares]
        unshared_word = 0
        for j in range(shares):
            unshared_word ^= int(word[j], 16)
        unshared_line.append(hex(unshared_word)[2:].zfill(num_chars))

    out_file.write(f'{" ".join(unshared_line)}\n')

out_file.close()

