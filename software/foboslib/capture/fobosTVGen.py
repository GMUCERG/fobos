 #############################################################################
# FOBOS Block Cipher TV generator
# Generates random test vector for block ciphers 
# Author : Abubakr Abdulgadir
# March 2021   
#Generate TV for data acquisition module
import numpy as np

class FobosTVGen():
    ############user defined settings
    def __init__(self, traceNum, blockSize, keySize, cipherSize, adSize = 0, nonceSize = 0,
                 dinFile='dinFile.txt', plaintextFile ='plaintext.txt', associateDataFile="ad.txt", nonceFile="nonce.txt", keyFile='key.txt'):
        self.traceNum = traceNum                          # Number of traces
        self.pdiLength = blockSize                           # In byets
        self.sdiLength = keySize                            # In bytes
        self.adLength = adSize
        self.nonceLength = nonceSize
        self.expectedOutLen = cipherSize                         # Expected output in bytes
        self.dinFile = dinFile                   # Desitination file name
        self.plaintextFile = plaintextFile           # Desitination file name
        self.keyFile = keyFile
        self.associateDataFile = associateDataFile           # Desitination file name
        self.nonceFile = nonceFile           # Desitination file name
        fKey = open(keyFile, 'r')
        key = fKey.readline()
        #print(key)
        key = key.split(' ') # remove spaces
        self.key = ''.join(key).strip().upper() 
        ####header data - See Fobos protocol
        self.PDI_HEADER = '00C0'
        self.SDI_HEADER = '00C1'
        self.AD_HEADER = '00C2'
        self.NONCE_HEADER = '00C3'
        self.CMD = '0080'
        self.START = '0001'
        self.expectedOutLen_CMD = '0081'
        ###########################################################

        self.pdiLengthStr = format(self.pdiLength, '04x').upper() ##format into 4 hex digits
        self.sdiLengthStr = format(self.sdiLength, '04x').upper()
        self.adLengthStr = format(self.adLength, '04x').upper()
        self.nonceLengthStr = format(self.nonceLength, '04x').upper()
        self.expectedOutStr = format(self.expectedOutLen, '04x').upper()

    def getRandData(self, numBytes):
        data = np.random.bytes(numBytes).hex()
        return data.upper()

    def generateTVs(self):
        print(f'Generating {self.traceNum} test vectors...')
        print(f'    KeyFile = {self.keyFile}')
        print(f'    PlaintextFile = {self.plaintextFile}')
        print(f'    Block Size (bytes) = {self.pdiLength}')
        if(self.adLength):
            print(f'    Associate Data Size (bytes) = {self.adLength}')
        if(self.nonceLength):
            print(f'    Nonce Size (bytes) = {self.nonceLength}')
        print(f'    Ciphertext Size (bytes) = {self.expectedOutLen}')
        print(f'    Key Size (bytes)= {self.sdiLength}')
        np.random.seed(0)
        fDin = open(self.dinFile,'w')
        fPlain = open(self.plaintextFile,'w')
        if(self.adLength):
            fAd = open(self.associateDataFile,'w')
        if(self.nonceLength):
            fNonce = open(self.nonceFile,'w')
        for pdi in range(0,self.traceNum):
            pdi = self.getRandData(self.pdiLength)
            sdi = self.key
            data = self.PDI_HEADER + self.pdiLengthStr + pdi
            if(self.adLength):
                ad = self.getRandData(self.adLength)
                data = data + self.AD_HEADER + self.adLengthStr + ad
                res = ' '.join(ad[i:i+2] for i in range(0, len(ad), 2))
                fAd.write(res + '\n')
            if(self.nonceLength):
                nonce = self.getRandData(self.nonceLength)
                data = data + self.NONCE_HEADER + self.nonceLengthStr + nonce
                res = ' '.join(nonce[i:i+2] for i in range(0, len(nonce), 2))
                fNonce.write(res + '\n')
            data = data  + self.SDI_HEADER + self.sdiLengthStr + sdi  + self.expectedOutLen_CMD + self.expectedOutStr + self.CMD + self.START + '\n'
            res = ' '.join(pdi[i:i+2] for i in range(0, len(pdi), 2))
            fDin.write(data)
            fPlain.write(res + '\n')

        fDin.close()
        fPlain.close()
        if(self.adLength):
            fAd.close()
        if(self.nonceLength):
            fNonce.close()
        print('Done.')

if __name__ == '__main__':
    d = FobosTVGen(traceNum=2, blockSize=16, keySize=16, cipherSize=16, adSize=0, nonceSize=0,
                   dinFile='dinFile.txt', plainTextFile ='plaintext.txt', associateDataFile="ad.txt", nonceFile="nonce.txt",
                   keyFile='key.txt')
    d.generateTVs()
