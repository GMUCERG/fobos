#############################################################################
#                                                                           #
#   Copyright 2019 CERG                                                     #
#                                                                           #
#   Licensed under the Apache License, Version 2.0 (the "License");         #
#   you may not use this file except in compliance with the License.        #
#   You may obtain a copy of the License at                                 #
#                                                                           #
#       http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                           #
#   Unless required by applicable law or agreed to in writing, software     #
#   distributed under the License is distributed on an "AS IS" BASIS,       #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.#
#   See the License for the specific language governing permissions and     #
#   limitations under the License.                                          #
#                                                                           #
#############################################################################

"""
AES-128 FirstLast power model
Generates hypothetical power for the AES design
used in FOBOS example.
the power model is
H(i,j) = HD(Sbox[CT(i-1)],  Sbox(PT(i) xor KeyGuess(j)))
This implementation is optimized using vectorization
"""
import numpy as np


def getHypotheticalPower(plaintextFile, ciphertextFile, numTraces):
    """
    AES-128 FirstLast power model
    Generates hypothetical power for the AES design
    used in FOBOS example
    the power model is
    H(i,j) = HD(Sbox[CT(i-1)],  Sbox(PT(i) xor KeyGuess(j)))
    This implementation is optimized using vectorization

    parameters:
    -------
    plaintextFile: string
        Plain text file name. The file contains plaintext in Hex format
        with space seperating bytes. The file will be loaded using
        np.loadtxt
    ciphertextFile: string
        Cipher text file name. The file contains ciphertext in Hex format
        with space seperating bytes The file will be loaded using
        np.loadtxt
    numTraces:
        The number of encryption operations performed.

    """
    print('---- Loading powermodel input data:')
    plaintext = loadTextMatrix(plaintextFile)
    print("Plaintext :")
    printMatrix(plaintext, format='hex')
    ciphertext = loadTextMatrix(ciphertextFile)
    plaintext = plaintext[0:numTraces, :]
    ciphertext = ciphertext[0:numTraces, :]
    print("Ciphertext :")
    printMatrix(ciphertext, format='hex')
    print('---- Loading powermodel input data complete.')
    print('---- Calculating hypothetical power for all subkeys:')
    hypotheticalPower = []
    for byteNum in range(16):
        sbox_pt_key = vectAESSboxOutFirstRound(plaintext[:, byteNum].reshape(numTraces, 1))
        # res =  firstRound(plaintext[:,0], 0)
        # print("sbox_pt_key=")
        # printHexMatrix(sbox_pt_key[:, 0:1])
        #####
        sbox_ct = vectAESSboxOut(ciphertext[:, byteNum].reshape(numTraces, 1))
        # res =  firstRound(plaintext[:,0], 0)
        # print("sbox_ct=")
        # printHexMatrix(sbox_ct[:, 0:1])
        #####
        oneBytePower = vectGetHD(sbox_ct, sbox_pt_key)
        hypotheticalPower.append(oneBytePower)
        # print(f"Hypothetical power matrix for subkey {byteNum}:")
        # printMatrix(oneBytePower, format='int')
    print('---- Hypothetical power calculation done.')

    return hypotheticalPower


sbox = [0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67,
        0x2b, 0xfe, 0xd7, 0xab, 0x76, 0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59,
        0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0, 0xb7,
        0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1,
        0x71, 0xd8, 0x31, 0x15, 0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05,
        0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75, 0x09, 0x83,
        0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29,
        0xe3, 0x2f, 0x84, 0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b,
        0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf, 0xd0, 0xef, 0xaa,
        0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c,
        0x9f, 0xa8, 0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc,
        0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2, 0xcd, 0x0c, 0x13, 0xec,
        0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19,
        0x73, 0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee,
        0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb, 0xe0, 0x32, 0x3a, 0x0a, 0x49,
        0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
        0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4,
        0xea, 0x65, 0x7a, 0xae, 0x08, 0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6,
        0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a, 0x70,
        0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9,
        0x86, 0xc1, 0x1d, 0x9e, 0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e,
        0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf, 0x8c, 0xa1,
        0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0,
        0x54, 0xbb, 0x16]

# Functions to be vectorized


def getSbox(p):
    return sbox[p]


def firstRound(p, k):
    return sbox[p ^ k]


def vectGetHD(D1, D2):
    """
    Vectorized function to calculate Hamming Distance
    parameters
    -------
    D1: Nx M nmupy array
        Each element is the value of the register
    D2: Nx M nmupy array
        Each element is the value of the register
    """
    HW = np.array([0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3,
                   2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4,
                   2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5,
                   4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
                   2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4,
                   3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6,
                   4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4,
                   3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
                   2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5,
                   4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5,
                   3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6,
                   5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
                   4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8],
                  dtype=np.uint8)

    numPlainTexts = D1.shape[0]
    z = np.zeros((1, D1.shape[1]), dtype=np.uint8)
    tmp = np.vstack((z, D1))
    D1 = tmp[0:numPlainTexts, :]
    result = np.empty(D2.shape, dtype=np.uint8)
    for k in range(D2.shape[1]):
        result[:, k] = HW[D1[:, k] ^ D2[:, k]]
    return result


def vectAESSboxOut(P):
    """
    calculates one byte of the AES sbox output
    parameters:
    P : a colomn vector of the sbox input.
    returns:
    The output of the sbox in round 1
    """
    vectFirstRound = np.vectorize(getSbox)
    numKeyHypotheses = 256
    # print(P)
    numPlainTexts = P.shape[0]
    result = np.empty((numPlainTexts, numKeyHypotheses), dtype=np.uint8)
    for k in range(numKeyHypotheses):
        result[:, k] = vectFirstRound(P.reshape(numPlainTexts,))
    return result

#################################################################


def vectAESSboxOutFirstRound(P):
    """
    calculates one byte of the AES sbox output in the first round
    parameters:
    P : a colomn vector of the plain text matrix (corresponds to the key byte
        to be guessed)
    returns:
    The output of the sbox in round 1
    """
    vectFirstRound = np.vectorize(firstRound)
    numKeyHypotheses = 256
    # print(P)
    numPlainTexts = P.shape[0]
    result = np.empty((numPlainTexts, numKeyHypotheses), dtype=np.uint8)
    for k in range(numKeyHypotheses):
        result[:, k] = vectFirstRound(P.reshape(numPlainTexts,), k)
    return result


def printMatrix(A, format='int'):
    if format == 'int':
        s = np.array2string(A)
    elif format == 'hex':
        s = np.array2string(A, formatter={'int':lambda A: hex(A)[2:]})
    else:
        s = np.array2string(A, formatter={'int':lambda A: hex(A)})
    print(f'Matrix shape is {A.shape}')
    print(s)
    print()

def loadTextMatrix(fileName, numCols=16):
    """
    file format: hex values delimited by spaces
    MAKE sure that there is no space at the end of line
    """
    return np.loadtxt(
        fileName, dtype='uint8', delimiter=' ',
        converters={_: lambda s: int(s, 16) for _ in range(numCols)})
