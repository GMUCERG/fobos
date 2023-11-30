#!/usr/bin/env python
# coding: utf-8

## File : lwc_2_fobos_tv.py
## Purpose : Convert shared LWC test vectors to FOBOS-ready
## Author : Abubakr Abdulgadir
## Date : June 2022

import sys
import argparse
import random
import numpy as np
random.seed(0)
np.random.seed(0)


def get_pdi_str(pdi, rand):
    # get sdi strig form list
    pdi_str = ''
    # fixed/ranom public data to simulate DPA
    for item in pdi:
        label = item[0].strip()
        data = item[1].strip()
        if label == 'INS' or label == 'HDR':
            pdi_str += data
        elif label == 'DAT':
            if rand:
                pdi_str += gen_rand_str(len(data)//2)
            else:
                pdi_str += reshare(data, shares, width)
        else:
            print('Unexpected label. Must be in (INS, HDR, DAT)')
            exit()
    
    return pdi_str

def get_sdi_str(sdi):
    # get sdi strig form list
    sdi_str = ''
    for item in sdi:
        label = item[0].strip()
        data = item[1].strip()
        if label == 'INS' or label == 'HDR':
            sdi_str += data
        elif label == 'DAT':
            sdi_str += data
        else:
            print('Unexpected label. Must be in (INS, HDR, DAT)')
            exit()
    
    return sdi_str

def read_test_vectors(lines):
    tv = []
    tv_len = 0
    for line in lines:
        if "INS" in line or "HDR" in line or "DAT" in line or 'STT' in line:
            data = line.strip().split("=")
            tv_len += len(data[1].strip())//2
            tv.append(data)
        else:
            continue
            
    return tv, tv_len

def gen_rand_str(n_bytes):
    rnd_bytes = np.random.bytes(n_bytes)
    byte_str = [hex(rnd_bytes[i])[2:].zfill(2) for i in range(len(rnd_bytes))]
    byte_str = ''.join(byte_str)
    return byte_str.upper()

## resharing

def gen_rnd(n):
    # gen uniform rand in [0,n-1]
    return np.random.randint(0, n)
    
def int_list_to_str(int_list, width):
    num_chars = width // 4
    s = [hex(item)[2:].zfill(num_chars) for item in int_list]
    return ''.join(s).upper()

def unshare(s, shares, width):
    num_chars = width // 4 # number of hex chars in word
    words = [s[i:i+num_chars] for i in range(0, len(s), num_chars)] # list of all words
    unshared_words = []
    for i in range(0, len(words), shares):
        shared_word = words[i:i+shares]
        unshared_word = 0
        for j in range(shares):
            unshared_word ^= int(shared_word[j], 16)
        unshared_words.append(unshared_word)
    return unshared_words

def share(unshared_words, shares, width):
    shared_words = []
    for unshared_word in unshared_words:
        sum_rnd = 0
        for i in range(shares-1):
            rnd = gen_rnd(2**width)
            sum_rnd ^= rnd
            shared_words.append(rnd)
        shared_words.append(sum_rnd^unshared_word)
    return shared_words

def reshare(in_str, shares, width):
    unshared_words = unshare(in_str, shares, width)
    reshared_words = share(unshared_words, shares, width)
    return int_list_to_str(reshared_words, width)


#########################################################
parser = argparse.ArgumentParser(description = 'Convert shared LWC test vectors to FOBOS-ready')

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

args = parser.parse_args()

#########################################################
FIFO0_LABEL   = '00C0'
FIFO1_LABEL   = '00C1'
EXP_OUT_LABEL = '0081'
START_LABEL   = '0080'
START_CMD     = '0001'
#########################################################
width = args.width
shares = args.shares
num_vectors = args.num_vectors

pdi_file = open(args.pdi_file, 'r')
sdi_file = open(args.sdi_file, 'r')
do_file = open(args.do_file, 'r')

pdi_lines = pdi_file.readlines()
sdi_lines = sdi_file.readlines()
do_lines = do_file.readlines()

pdi_file.close()
sdi_file.close()
do_file.close

pdi, pdi_len = read_test_vectors(pdi_lines)
sdi, sdi_len = read_test_vectors(sdi_lines)
_, do_len = read_test_vectors(do_lines)

shared_do_len = do_len * shares # do.txt is not share but output is

din_file = open(args.fobos_din_file, 'w')
fvr_file = open(args.fobos_fvr_file, 'w')

pdi_len = hex(pdi_len)[2:].zfill(4)
sdi_len = hex(sdi_len)[2:].zfill(4)
shared_do_len = hex(shared_do_len)[2:].zfill(4)

sdi_str = get_sdi_str(sdi) # same sdi for all test vectors

for i in range(num_vectors):
    coin = random.randint(0,1)
    if coin==1:
        # random
        pdi_str = get_pdi_str(pdi, True)
        fvr_file.write('1')
    else:
        # fixed
        pdi_str = get_pdi_str(pdi, False)
        fvr_file.write('0')
        
    tv = FIFO0_LABEL + pdi_len + pdi_str + FIFO1_LABEL + sdi_len + sdi_str + EXP_OUT_LABEL + shared_do_len + START_LABEL + START_CMD
        
    din_file.write(tv + '\n')

din_file.close()
fvr_file.close()