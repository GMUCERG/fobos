#############################################################################
# FOBOS Block Cipher Fixed-vs-Random test vector generator
# Generates random test vector for block ciphers 
# Author : Abubakr Abdulgadir
# April 2021   
#Generate TV for data acquisition module
import numpy as np

class FvrTVGen():
    ############user defined settings
    def __init__(self, traceNum, blockSize, keySize, cipherSize, fixedKey, fixedPlaintext,
                 dinFile='dinFile.txt', fvrFile ='fvrchoicefile.txt'):
        self.traceNum = traceNum                          # Number of traces
        self.pdiLength = blockSize                           # In byets
        self.sdiLength = keySize                            # In bytes
        self.expectedOutLen = cipherSize                         # Expected output in bytes
        self.dinFile = dinFile                   # Desitination file name
        self.fvrfile = fvrFile
        self.fixedKey = fixedKey
        self.fixedPlaintext =fixedPlaintext
        ####header data - See Fobos protocol
        self.PDI_HEADER = '00C0'
        self.SDI_HEADER = '00C1'
        self.CMD = '0080'
        self.START = '0001'
        self.expectedOutLen_CMD = '0081'
        ###########################################################

        self.pdiLengthStr = format(self.pdiLength, '04x').upper() ##format into 4 hex digits
        self.sdiLengthStr = format(self.sdiLength, '04x').upper()
        self.expectedOutStr = format(self.expectedOutLen, '04x').upper()

    def getRandData(self, numBytes):
        data = np.random.bytes(numBytes).hex()
        return data.upper()

    def gen_fvr(self):
        print(f'Generating {self.traceNum} fixed-vs-random test vectors for unprotected block cipher ...')
        print(f'    Block Size (bytes)      = {self.pdiLength}')
        print(f'    Ciphertext Size (bytes) = {self.expectedOutLen}')
        print(f'    Key Size (bytes)        = {self.sdiLength}')
        np.random.seed(0)
        fDin = open(self.dinFile,'w')
        fvrFile = open(self.fvrfile, 'w')
        for i in range(0,self.traceNum):
            sdi = self.fixedKey
            if np.random.randint(0,2)==1:
                #print('rand')
                fvrFile.write("1")
                pdi = self.getRandData(self.pdiLength)
            else:
                #print('fixed')
                fvrFile.write("0")
                pdi = self.fixedPlaintext

            data = self.PDI_HEADER + self.pdiLengthStr + pdi + self.SDI_HEADER + self.sdiLengthStr + sdi  + self.expectedOutLen_CMD + self.expectedOutStr + self.CMD + self.START + '\n'
            res = ' '.join(pdi[i:i+2] for i in range(0, len(pdi), 2))
            fDin.write(data)

        fDin.close()
        fvrFile.close()
        print('Done.')

if __name__ == '__main__':
    d = FvrTVGen(traceNum=10, blockSize=16, keySize=16, cipherSize=16,
                   fixedKey="00112233445566778899AABBCCDDEEFF",
                   fixedPlaintext="55555555555555555555555555555555",
                   dinFile='dinFile.txt',
                   fvrFile='fvrchoicefile.txt'
                   )
    d.gen_fvr()
