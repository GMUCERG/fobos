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

#reshape is faster than shape.


import os
import json
import numpy as np
import scipy.stats.stats as statModule
#scipy.stats.stats is deprecated

# import postprocess
# import traceset


class CPA():
    """
    A class to perform tasks related to CPA. These include
    1- running correlation e.g pearson's r on the traces matrix T and
    hypothetical power matrix H to obtain the correlation matrix R
    2- Generate MTD graph
    3- Visualize the correlation Matrix R in various ways.
    4- Generate plots.
    """

    def correlation_pearson(self, measuredData, modeledData):
        corrMatrix = np.zeros(0) 
        #Use reshape instead of empty, 
        corrMatrix = np.empty((modeledData.shape[1], measuredData.shape[1]))
        #Dumps matrix with dimensions: (number of model data columns) X (number of measured data columns) into zeros matrix
        
        # print("measured data:\n {}  modelData:\n {} correlation Matrix:\n {}".format(measuredData, modeledData, corrMatrix))
        print("shape of Measured data: {}".format(np.shape(measuredData)))
        # print("shape of Model data: {}".format(np.shape(modelData)))
        
        for i in range(modeledData.shape[1]):
            # for num of columns in modeled data:
            colH = modeledData[:, i] # turns modeled data columns into rows
            for j in range(measuredData.shape[1]):
                colM = measuredData[:, j] #turns measured data columns into rows
                c, p = statModule.pearsonr(colH, colM)
                #compares each row 
                corrMatrix[i, j] = c
        return corrMatrix #returns correlation matrix with of dimensions: (number of model data columns) X (number of measured data columns) using pearsons equation when comparing each column of the origional correlation matrix

            # x = np.array([[1,2,3,4],
                           #[9,8,7,6]])
            # y = np.array([[5,6,7,8],
                          #[12,13,800,15]])
    
            # corrMatrix = np.empty((x.shape[1], y.shape[1]))
            # print(x)
            # for i in range(x.shape[1]):
            #     print(x[:,i])
                
            # for i in range(x.shape[1]):
            #     # for num of columns in modeled data:
            #     colH = x[:, i] # turns modeled data columns into rows
            #     print("Col H:\n",colH)
            #     for j in range(y.shape[1]):
            #         colM = y[:, j] #turns measured data columns into rows
            #         print("Col M:\n",colM)
            
            #         c, p = statModule.pearsonr(colH, colM)
            #         #compares each row 
            #         corrMatrix[i, j] = c
            #         print(c)    

    def plotCorr(self, C, correctIndex, fileName=None, show='no', plotSize=(10,8),
                 plotFontSize=18):
        print("    plotting correlation graph.")
        import matplotlib.pyplot as plt
        fig = plt.figure()
        fig.patch.set_facecolor('white')
        plt.figure(figsize=plotSize)
        plt.rcParams.update({'font.size':plotFontSize})
        plt.clf()
        plt.margins(0)
        for i in range(C.shape[0]):
            row = C[i, :]
            plt.plot(row, '#aaaaaa', linewidth=0.5)
        plt.plot(C[correctIndex, :], 'k', linewidth=0.5)
        plt.xlabel("Sample No.")
        plt.ylabel("Correlation (Pearson's r)")
        if fileName is not None:
            plt.savefig(fileName,facecolor=fig.get_facecolor())
        if show == 'yes':
            plt.show()
        plt.close('all')

# def plotCorr(self, C, correctIndex, fileName=None, show='no', plotSize=(10,8),
#              plotFontSize=18):
#     import matplotlib.pyplot as plt
#     print("    plotting correlation graph.")
#     fig = plt.figure()
#     # Setting the face color of the figure to white
#     fig.patch.set_facecolor('white')
#     plt.figure(figsize=plotSize)
#     # Updating the font size for the plot
#     plt.rcParams.update({'font.size': plotFontSize})
#     plt.clf()
#     plt.margins(0)
#     # Plotting each row of the correlation matrix with a light gray
#     for i in range(C.shape[0]):
#         row = C[i, :]
#         plt.plot(row, '#aaaaaa', linewidth=0.5)
    
#     # Plotting the row specified by correctIndex with a black 
#     plt.plot(C[correctIndex, :], 'k', linewidth=0.5)
#     plt.xlabel("Sample No.")
#     plt.ylabel("Correlation (Pearson's r)")
#     if fileName is not None:
#         plt.savefig(fileName, facecolor=fig.get_facecolor())
#     # If show is set to 'yes', displaying the plot
#     if show == 'yes':
#         plt.show()
    
#     plt.close('all')

    

    import numpy as np

    def findCorrectKey(self, C):
        #  absolute values of the correlation matrix 
        C = np.abs(C)
        # Calculating the maximum correlation for each key (column) by finding the maximum value along each column
        maxCorrs = np.amax(C, 0)
        # Finding the index (key) corresponding to the maximum correlation for each key
        maxKeyIndexes = np.argmax(C, 0)
        # Identifying the key with the maximum correlation across all keys
        maxKeyIndex = maxKeyIndexes[np.argmax(maxCorrs)]
        # Determining the highest correlation value
        maxCorr = np.max(maxCorrs)
        # Finding the corresponding time index associated with the highest correlation value
        maxCorrTime = np.argmax(maxCorrs)
        return maxKeyIndex, maxCorr, maxCorrTime

    # def findCorrectKeyTest(C = np.array([[0.1, 0.2, 0.3, 0.4,0.98], 
    #                           [-0.3,-0.5, -0.4,0.5,0.88]])):
    # C = np.abs(C)
    # maxCorrs = np.amax(C, 0)
    # maxKeyIndexes = np.argmax(C, 0)
    # maxKeyIndex = maxKeyIndexes[np.argmax(maxCorrs)]
    # maxCorr = np.max(maxCorrs)
    # maxCorrTime = np.argmax(maxCorrs)
    # print("Max Key Index: {} maxCorr: {}  maxCorrTime: {}".format (maxKeyIndex, maxCorr, maxCorrTime))
    
    #small sample returns: Max Key index (the row # in C this case 0), maxCorr (the highest correlation - .98), maxCorrtime (the index of the highest correlation value in the key guess row - 4)


    def plotMTDGraph(self, correctTime, correctKeyIndex, measuredPower,
                     hypotheticalPower, numTraces=None, stride=1,
                     fileName=None, show='no'):
        if numTraces is None:
            numTraces = measuredPower.shape[0]
        numKeys = hypotheticalPower.shape[1]
        dataToPlot = np.empty((numKeys, numTraces / stride))
        interestingPower = measuredPower[:, correctTime].reshape(measuredPower.shape[0], 1)
        index = 0
        for i in range(0, numTraces, stride):
            if i % 100 == 0:
                print("MDT step={}".format(i))
            C = self.correlation_pearson(interestingPower[0:i, :], hypotheticalPower[0:i, :])
            # print(C.shape)
            dataToPlot[:, index] = C.reshape(numKeys)
            index += 1
        import matplotlib.pyplot as plt
        plt.clf()
        plt.margins(0)
        for i in range(dataToPlot.shape[0]):
            row = dataToPlot[i, :]
            plt.plot(row, '#aaaaaa', linewidth=0.5)
        plt.plot(dataToPlot[correctKeyIndex, :], 'k', linewidth=0.5)
        if stride != 1:
            plt.xlabel("Trace No. ({} traces)".format(stride))
        else:
            plt.xlabel("Trace No.")
        plt.ylabel("Correlation (Pearson's r)")
        if fileName is not None:
            plt.savefig(fileName)
        if show == 'yes':
            plt.show()


    # def plotMTDGraph2(self, correctTime, correctKeyIndex, measuredPower,
    #                   hypotheticalPower, numTraces=None, stride=1,
    #                   fileName=None, show='no', plotSize=(10,8), plotFontSize=18):
    #     print('    Plotting MTD graph.')
    #     if numTraces is None:
    #         numTraces = measuredPower.shape[0]
    #     numKeys = hypotheticalPower.shape[1]
    #     corrData = np.zeros((numKeys, int(numTraces / stride)))
    #     interestingPower = measuredPower[:, correctTime].reshape(measuredPower.shape[0], 1)
    #     index = 0
    #     for i in range(stride, numTraces, stride):
    #         # if i % 100 == 0:
    #         # print("    Plotting MDT. step={}".format(i))
    #         C = self.correlation_pearson(interestingPower[0:i, :], hypotheticalPower[0:i, :])
    #         # print(C.shape)
    #         corrData[:, index] = C.reshape(numKeys)
    #         index += 1
    #     # get only highest and lowest values
    #     # print(corrData.shape)
    #     # print(corrData)
    #     import matplotlib.pyplot as plt
    #     fig = plt.figure()
    #     fig.patch.set_facecolor('white')
    #     plt.figure(figsize=plotSize)
    #     plt.rcParams.update({'font.size':plotFontSize})
    #     plt.clf()
    #     plt.margins(0)
    #     # plot this first
    #     plt.plot(corrData[correctKeyIndex, :-1], 'r', linewidth=0.5) # remove last element(to fix a bug)
    #     # remove the correct key
    #     corrData[correctKeyIndex, :] = 0  # zero all elements in row so they are
    #     # min nor max
    #     # for i in range(dataToPlot.shape[0]):
    #     #     row = dataToPlot[i,:]
    #     #     plt.plot(row, '#aaaaaa', linewidth = 0.5)
    #     highVals = np.nanmax(corrData, axis=0)
    #     lowVals = np.nanmin(corrData, axis=0)
    #     # print(highVals.shape)
    #     # print(highVals)
    #     plt.plot(highVals[:-1], 'b', linewidth=0.5)
    #     plt.plot(lowVals[:-1], 'g', linewidth=0.5)

    #     if stride != 1:
    #         plt.xlabel("Trace No. x {}".format(stride))
    #     else:
    #         plt.xlabel("Trace No.")
    #     plt.ylabel("Correlation (Pearson's r)")
    #     if fileName is not None:
    #         plt.savefig(fileName,facecolor=fig.get_facecolor())
    #     if show == 'yes':
    #         plt.show()
    #     plt.close('all')
        
    # def plotMTDGraph2Test(self, correctTime, correctKeyIndex, measuredPower,
    #               hypotheticalPower, numTraces=None, stride=1,
    #               fileName=None, show='no', plotSize=(10,8), plotFontSize=18):
    #     print('    Plotting MTD graph.')
    #     if numTraces is None:
    #         numTraces = measuredPower.shape[0]
    #     numKeys = hypotheticalPower.shape[1]
    #     corrData = np.zeros((numKeys, int(numTraces / stride)))
    #     interestingPower = measuredPower[:, correctTime].reshape(measuredPower.shape[0], 1)
    #     index = 0
        
    #     last_intersection = []  # Empty list for last intersection point 
        
    #     for i in range(stride, numTraces, stride):
    #         # Pearson correlation coefficient
    #         C = self.correlation_pearson(interestingPower[0:i, :], hypotheticalPower[0:i, :])
    #         # Reshape correlation data and store in corrData array
    #         corrData[:, index] = C.reshape(numKeys)
    #         index += 1
            
    #     import matplotlib.pyplot as plt

    #     fig = plt.figure()
    #     fig.patch.set_facecolor('white')
    #     plt.figure(figsize=plotSize)
    #     plt.rcParams.update({'font.size': plotFontSize})
    #     plt.clf()
    #     plt.margins(0)
    #     # Plot the red line first
    #     red_line = plt.plot(corrData[correctKeyIndex, :-1], 'r', linewidth=0.5)
        
    #     # copy corrVals since corrData converts same data in memory to all 0s
    #     corrVals= corrData[correctKeyIndex, : -1].copy()
        
    #     # Zero out the correct key in corrData to avoid problems
    #     corrData[correctKeyIndex, :] = 0
           
    #     highVals = np.nanmax(corrData, axis=0)
    #     lowVals = np.nanmin(corrData, axis=0)
    #     blue_line = plt.plot(highVals[:-1], 'b', linewidth=0.5)
    #     green_line = plt.plot(lowVals[:-1], 'g', linewidth=0.5) # still remove last elements due to bug
        
    #     # loop through points of red line and see if intersections with blue or green
    #     for i in range(len(corrData[correctKeyIndex, :-1]) - 1):
    #         # Check red line intersect blue line (high vals)  # Check red line intersect green line (low vals)
    #         # print(i, corrVals[i+1], highVals[i+1], lowVals[i+1])
    #         if (corrVals[i+1] > highVals[i+1] and corrVals[i] < highVals[i]) or \
    #            (corrVals[i+1] < lowVals[i+1] and corrVals[i] > lowVals[i]):
    #             print("Intersection found", i, corrVals[i+1], highVals[i+1], lowVals[i+1])
                
    #             # last_intersection.append((round(corrVals[i],4), round(corrVals[i+1],4)))

    #             # Collects last intersection as the trace x 100 and the correct key value rounded to 4 dec places
    #             last_intersection.append((i+1)*stride)
                
    #     intersection = last_intersection[-1]
        
    #     if stride != 1:
    #         # Collects last x,y tuple from intersection list and puts in in title of MTD graph 
    #         plt.xlabel("Trace No. x {} \n Intersection is {}".format(stride, last_intersection[-1]))
    #     else:
    #         plt.xlabel("Trace No.")
    #     plt.ylabel("Correlation (Pearson's r)")
    #     if fileName is not None:
    #         plt.savefig(fileName, facecolor=fig.get_facecolor())
    #     if show == 'yes':
    #         plt.show()
    #     plt.close('all')
    #     with open('intersections.txt', 'w') as f:
    #         f.write(str(intersection)+',')
    #     return last_intersection # Return the last intersection found


    def plotMTDGraph2Test(self, correctTime, correctKeyIndex, measuredPower,
                  hypotheticalPower, numTraces=None, stride=1,
                  fileName=None, show='no'):
        print('  NOT  Plotting MTD graph.')
        if numTraces is None:
            numTraces = measuredPower.shape[0]
        numKeys = hypotheticalPower.shape[1]
        corrData = np.zeros((numKeys, int(numTraces / stride)))
        interestingPower = measuredPower[:, correctTime].reshape(measuredPower.shape[0], 1)
        index = 0
        
        last_intersection = []  # Empty list for intersections 
        
        for i in range(stride, numTraces, stride):
            # Pearson correlation coefficient
            C = self.correlation_pearson(interestingPower[0:i, :], hypotheticalPower[0:i, :])
            # Reshape correlation data and store in corrData array
            corrData[:, index] = C.reshape(numKeys)
            index += 1
        
        # copy corrVals since corrData converts same data in memory to all 0s
        corrVals= corrData[correctKeyIndex, : -1].copy()
        
        # Zero out the correct key in corrData to avoid problems
        corrData[correctKeyIndex, :] = 0
           
        highVals = np.nanmax(corrData, axis=0)
        lowVals = np.nanmin(corrData, axis=0)
        
        # loop through points of red line and see if intersections with blue or green
        for i in range(len(corrData[correctKeyIndex, :-1]) - 1):
            # Check red line intersect blue line (high vals)  # Check red line intersect green line (low vals)
            # print(i, corrVals[i+1], highVals[i+1], lowVals[i+1])
            if (corrVals[i+1] > highVals[i+1] and corrVals[i] < highVals[i]) or \
               (corrVals[i+1] < lowVals[i+1] and corrVals[i] > lowVals[i]):
               # print("Intersection found", i, corrVals[i+1], highVals[i+1], lowVals[i+1])
                
                # Collects last intersection as the trace x stride 
                last_intersection.append((i+1)*stride)
                
        intersection = last_intersection[-1]
        
        with open('intersections.txt', 'a') as f:
            f.write(str(intersection)+',')
        return intersection # Return the last intersection found


    
    def doCPA(self, measuredPower, hypotheticalPower, numTraces,
              analysisDir, MTDStride, numKeys=16, plot=True, plotSize=(10,8),
              plotFontSize=18):
        # print(measuredPower.shape)
        print("Running CPA attack. Please wait ...")
        correctKey = []
        for byteNum in range(numKeys):
            C =  self.correlation_pearson(measuredPower[0:numTraces,:], hypotheticalPower[byteNum][0:numTraces,:])
            # print("C=")
            # print(C.shape)
            # self.printHexMatrix(C, dtype='float')
            
            # three lines above is commented originally
            maxKeyIndex, maxCorr, maxCorrTime = self.findCorrectKey(C)
            corrFile = os.path.join(analysisDir, 'correlation' +f'{byteNum:02d}')
            mtdFile = os.path.join(analysisDir, 'MTD' + f'{byteNum:02d}')
          
            print("subkey number = {}, subkey value = {}, correlation = {}, at sample = {}".format(byteNum, hex(maxKeyIndex), maxCorr, maxCorrTime))
            if plot: #do this, if plot mtd do this
                self.plotCorr(C, maxKeyIndex, fileName=corrFile, plotSize=plotSize,
                              plotFontSize=plotFontSize)
                # self.plotMTDGraph2Test(maxCorrTime, maxKeyIndex, measuredPower,
                #                 hypotheticalPower[byteNum],
                #                 stride=MTDStride, fileName=mtdFile, show='no',
                #                 plotSize=plotSize, plotFontSize=plotFontSize)
                self.plotMTDGraph2Test(maxCorrTime, maxKeyIndex, measuredPower,
                                hypotheticalPower[byteNum],
                                stride=MTDStride, fileName=mtdFile, show='no')
                                # plotSize=plotSize, plotFontSize=plotFontSize)
                #changed plotMTDGraph2 to Test above
                # self.gatherpointsTest()
            correctKey.append(format(maxKeyIndex, '02x'))
            topKeysFile = os.path.join(analysisDir, 'topKeys-' + f'{byteNum:02d}' + '.json')
            self.getTopNKeys(C, fileName=topKeysFile)
        print('Highest correlation at key = {}'.format(' '.join(correctKey)))
        return C

    def printHexMatrix(self, A, printAll=False, dtype='int'):
        import sys
        lim = 10
        if (printAll is True or A.shape[0] < 10):
            lim = A.shape[0]
        for i in range(lim):
            for j in range(A.shape[1]):
                if dtype == 'float':
                    sys.stdout.write(str(A[i, j]) + "\t")
                else:
                    sys.stdout.write("0x" + format(int(A[i, j]), '02x') + "\t")
            sys.stdout.write("\n")

## Plot mtd graph needs to just return that just returns the high, low, and corrvals, and returns it to a 
    ##comment out plotmtd graph 2 test functions and see if faster, if not then we do someehting likntionse copying out the plot fuc. ## comment out corrplot and see MTD with or without plotting and see if there is a difference. make a normal tetx file and output the mtd values to it
    
    def loadTextMatrix(self, fileName, numCols=16):
            """
            file format: hex values delimited by spaces
            MAKE sure that there is no space at the end of line
            """
            return np.loadtxt(
                fileName, dtype='uint8', delimiter=' ',
                converters={_: lambda s: int(s, 16) for _ in range(numCols)})

    def getTopNKeys(self, C, n=5, fileName=None):
        # print(C.shape)
        absC = np.abs(C)
        # print(f'a = {a}')
        corrVal = np.flip(np.sort(np.max(absC, axis=1))[-n:]).reshape(n)#max corr
        # print(corrVal)
        # print(f'corr= {corrVal}')
        keyIndex = np.flip(np.argsort(np.max(absC, axis=1))[-n:]).reshape(n) # keys
        # print(f'ki= {keyIndex}')
        #sort times
        # print(keyIndex)
        timesOfMax = np.argsort(absC, axis=1)[:,-1].transpose()
        # print(timesOfMax.shape)
        # print(f'ti = {timesOfMax}')
        maxKeyTimes = timesOfMax[keyIndex].reshape(n)
        # print('maxKeyTimes')
        # print(maxKeyTimes)
        l = []
        for i in range(n):
            t = maxKeyTimes[i]
            c = corrVal[i]
            k = keyIndex[i]
            #Changed from hex to int
            l.append({'key' : int(k) , 'correlation_absolute' : c, 'time' : int(t)})
        if fileName is not None:
            f = open(fileName, 'w')
            # print(l)
            f.write(json.dumps(l, indent=4))
            f.close()
        return l

def main():
    BASE_DIR = "/home/aabdulga/fobosworkspace/zybo_aes/capture/zybo_aes_basys3_1mhz_dut_625_cpu_clk"
    TRACES_FILE = os.path.join(BASE_DIR, 'powerTraces.npy')
    ANALYSIS_DIR = os.path.join(BASE_DIR, 'analysis')
    HYPO_FILE = os.path.join(BASE_DIR, "hypotheticalPower.npy")

    # CROP_START = 350 worked for 2000 traces
    # CROP_END = 450
    CROP_START = 1500
    CROP_END = 3000
    NUM_TRACES = 100
    MTD_STRIDE = 10

    traceSet = traceset.TraceSet(traceNum=NUM_TRACES,
                                 fileName=TRACES_FILE,
                                 cropStart=CROP_START,
                                 cropEnd=CROP_END)
    measuredPower = traceSet.traces
    compressedPower = postprocess.compressData(measuredPower, 'MEAN', 10)
    np.save(os.path.join(ANALYSIS_DIR, "compressedPower.npy"), compressedPower)
    print("Compression Done!")
    print(compressedPower.shape)
    hypotheticalPower = np.load(HYPO_FILE)
    cpa = CPA()
    C = cpa.doCPA(measuredPower=compressedPower,
                  hypotheticalPower=hypotheticalPower,
                  numTraces=NUM_TRACES,
                  analysisDir=ANALYSIS_DIR,
                  MTDStride=MTD_STRIDE)

    
    np.savetxt("C.txt", C)


if __name__ == '__main__':
    main()
