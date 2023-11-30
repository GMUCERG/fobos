 #############################################################################
# FOBOS Block Cipher TV generator
# Generates random test vector for block ciphers 
# Author : Abubakr Abdulgadir
# March 2021   
#Generate TV for data acquisition module
import numpy as np

class FobosTVGen():
    ############user defined settings
    def __init__(self, traceNum, blockSize, keySize, cipherSize, 
                 dinFile='dinFile.txt', plaintextFile ='plaintext.txt', keyFile='key.txt'):
        self.traceNum = traceNum                          # Number of traces
        self.pdiLength = blockSize                           # In byets
        self.sdiLength = keySize                            # In bytes
        self.expectedOutLen = cipherSize                         # Expected output in bytes
        self.dinFile = dinFile                   # Desitination file name
        self.plaintextFile = plaintextFile           # Desitination file name
        self.keyFile = keyFile
        fKey = open(keyFile, 'r')
        key = fKey.readline()
        #print(key)
        key = key.split(' ') # remove spaces
        self.key = ''.join(key).strip().upper() 
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

    def generateTVs(self):
        print(f'Generating {self.traceNum} test vectors...')
        print(f'    KeyFile = {self.keyFile}')
        print(f'    PlaintextFile = {self.plaintextFile}')
        print(f'    Block Size (bytes) = {self.pdiLength}')
        print(f'    Ciphertext Size (bytes) = {self.expectedOutLen}')
        print(f'    Key Size (bytes)= {self.sdiLength}')
        np.random.seed(0)
        fDin = open(self.dinFile,'w')
        fPlain = open(self.plaintextFile,'w')
        for pdi in range(0,self.traceNum):
            pdi = self.getRandData(self.pdiLength)
            sdi = self.key
            data = self.PDI_HEADER + self.pdiLengthStr + pdi + self.SDI_HEADER + self.sdiLengthStr + sdi  + self.expectedOutLen_CMD + self.expectedOutStr + self.CMD + self.START + '\n'
            res = ' '.join(pdi[i:i+2] for i in range(0, len(pdi), 2))
            fDin.write(data)
            fPlain.write(res + '\n')

        fDin.close()
        fPlain.close()
        print('Done.')

if __name__ == '__main__':
    d = FobosTVGen(traceNum=2, blockSize=16, keySize=16, cipherSize=16,
                   dinFile='dinFile.txt', plainTextFile ='plaintext.txt',
                   keyFile='key.txt')
    d.generateTVs()
