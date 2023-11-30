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

import numpy as np
import os
import argparse
import matplotlib.pyplot as plt
#from console_progressbar import ProgressBar  # produces error

class Ttest():

    def __init__(self):
        pass

    def calcTValue(self,traces0, traces1):
        mean0 = np.mean(traces0, axis=0)
        mean1 = np.mean(traces1, axis=0)
        var0 = np.var(traces0, axis=0)
        var1 = np.var(traces1, axis=0)
        numTraces = traces0.shape[0]
        
        return np.divide((mean0 - mean1), np.sqrt(((var0/numTraces) + (var1/(numTraces)))))

    def doTtest(self, traceFile0, traceFile1, numTraces, step, analysisDir):
        #pb = ProgressBar(total=100,prefix='Progress:', suffix='', decimals=2, length=50, fill='=', zfill='.')
        traces0 = np.load(traceFile0, mmap_mode='r')
        traces1 = np.load(traceFile1, mmap_mode='r')

        samplesPerTrace = traces0.shape[1]
        if numTraces == 'All':
            numTraces = min(traces0.shape[0], traces1.shape[1])
        else:
            numTraces = int(numTraces)
        if step == 'auto':
            step = self.calculateStep(numTraces, samplesPerTrace)
        else:
            step = int(step)
        print("numTraces = {}, samplesPerTrace = {}, step = {}".format(numTraces, samplesPerTrace, step))
        done =False
        start = 0
        t = np.array([])
        i = 0
        #pb.print_progress_bar(0)
        while not done:
            end = start + step
            if end > samplesPerTrace:
                end = samplesPerTrace
                done = True
            # print('i={}, start= {}, end = {}'.format(i, start, end))
            chunk0 = traces0[0:numTraces,start:end]
            chunk1 = traces1[0:numTraces,start:end]
            t = np.append(t,self.calcTValue(chunk0, chunk1))
            #pb.print_progress_bar(float(i * step) / samplesPerTrace * 100)
            #print(t)
            start = end
            i += 1
        # pb.print_progress_bar(100)
        return t

    def plotTValues(self, t, startXlim, endXlim, startYlim, endYlim, analysisDir,
                    traceNum=None, plotSize=(10,8), plotFontSize=18):
        #%matplotlib inline
        plt.figure(figsize=plotSize)
        plt.rcParams.update({'font.size':plotFontSize})
        if endXlim == 'All':
            endXlim  = t.shape[0]
            print('endXlim={}'.format(endXlim))
        threshold = [4.5] * (int(endXlim) - int(startXlim))
        minusThreshold = [-4.5] * (int(endXlim) - int(startXlim))
        plt.plot(threshold, color='b')
        plt.plot(minusThreshold, color='b')

        plt.ylim(int(startYlim), int(endYlim))
        plt.xlim(int(startXlim), int(endXlim))
        plt.xlabel("Sample No.")
        plt.ylabel("t-value")
        if traceNum is not None:
            plt.title(f't-values - {traceNum} traces')
        else:
            plt.title(f't-values')
        plt.plot(t, color='r')
        
        # plt.plot(t)
        #plt.show()
        if traceNum is not None:
            plt.savefig(os.path.join(analysisDir, f't-test-result-{traceNum}-traces.png'))
        else:
            plt.savefig(os.path.join(analysisDir, f't-test-result.png'))

    def calculateStep(self, numTraces, samplesPerTrace):
        step = int(samplesPerTrace / 50)
        if step < 10:
            step = 10
        return step
    
    ######################################################### splitter code
    def countZerosOnes(self, fileName, numTraces):
        #calculate the number of ones in the fvrchoicefile.txt
        f = open(fileName, 'r')
        content = f.read()
        f.close()
        #print content
        numOnes = 0
        for i in range(0, numTraces):
            if content[i] == '1':
                numOnes+=1
        numZeros = numTraces - numOnes
        return numZeros,numOnes
    
    def split(self, traces, fvrFile, numTraces, analysisDir):
        pb = ProgressBar(total=100,prefix='Progress:', suffix='', decimals=2, length=50, fill='=', zfill='.')
        numZeros, numOnes =  self.countZerosOnes(fvrFile, numTraces)
        print("Splitter routine:")
        print(f'Using fvr file at {fvrFile}')
        #print numZeros, numOnes
        ##create arrays
        print("Reading traces file. Please wait ...")
        # traces = np.load(cleanTraceFile)
        print("Reading trace file done.")
        #print full_traces.shape
        samplesPerTrace = traces.shape[1]
        traces0 = np.empty((numZeros,samplesPerTrace))
        traces1 = np.empty((numOnes, samplesPerTrace))
        i=0
        fullTraceIndex = 0
        traceCount0 = 0 
        traceCount1 = 0
        with  open(fvrFile) as f:
            while i < numTraces:
                c = f.read(1)
                if not c:
                    print("End of file")
                    break
                # print("index=",fullTraceIndex)
                #print c
                temp = traces[fullTraceIndex,:]
                fullTraceIndex += 1
                if c == '0':
                    #print "Q0"
                    traces0[traceCount0,:] = temp
                    traceCount0 += 1
                else:
                    #print "Q1"
                    traces1[traceCount1,:] = temp
                    traceCount1 += 1
                i +=1
                pb.print_progress_bar(float(i) / numTraces * 100)

        print("Done splitting")
        print("   Q0 shape:" , traces0.shape)
        print("   Q1 shape:" , traces1.shape)
        print("Saving files. Please wait ...")
        traces0File = os.path.join(analysisDir, 'trace_set0.npy')
        traces1File = os.path.join(analysisDir, 'trace_set1.npy')
        np.save(traces0File, traces0)
        np.save(traces1File, traces1)
        print(f'Saved split trace files at :')
        print(f'    {traces0File}')
        print(f'    {traces1File}')
        print("Done")


def main():
    startYlim = -10
    endYlim = 10
    numTraces = None
    step = 1000
    #tracesFile0 = '/home/aabdulga/fobosworkspace/acorn_1bit_unprotected/capture/leakage-assessment/traces0.npy'
    #tracesFile1 = '/home/aabdulga/fobosworkspace/acorn_1bit_unprotected/capture/leakage-assessment/traces1.npy'
    #t = doTtest(tracesFile0, tracesFile1, numTraces, step)
    #print(t.shape)
    #plotTValues(t, 0, len(t), startYlim, endYlim)
    
    parser = argparse.ArgumentParser()
    parser.add_argument("-traces0", dest='traces0', default="traces0.npy", help=".npy file that store traces as MxN Nupmy array. Default is 'traces0.npy'", type=str)
    parser.add_argument("-traces1", dest='traces1', default="traces1.npy", help=".npy file that store traces as MxN Nupmy array. Default is 'traces0.npy", type=str)
    parser.add_argument("-num_traces", dest='numTraces', default="All", help="Integer. Number of traces to use for t-value calculation. Default is to use all traces.", type=str)
    parser.add_argument("-xlim_start", dest='startXLim', default="0", help="start of plot xlim. Default is 0.", type=str)
    parser.add_argument("-xlim_end", dest='endXLim', default="All", help="end of plot xlim. Default is all samples", type=str)
    parser.add_argument("-ylim_start", dest='startYLim', default="-10", help="start of plot ylim. Default is -10.", type=str)
    parser.add_argument("-ylim_end", dest='endYLim', default="10", help="end of plot ylim. Default is 10. ", type=str)
    parser.add_argument("-plot_file", dest='plotFile', default='t-test-result.png', help="File name to store the output figure. Default is 't-test-result.png", type=str)
    parser.add_argument("-t_values_file", dest='tValuesFile', default='t-test-result.npy', help="File name to store the output t-values. Default is 't-test-result.npy", type=str)
    parser.add_argument("-step", dest='step', default= 'auto', help="The number of samples to load each time to calculate t-values. Default is 10000.", type=str)
    args = parser.parse_args()
    tracesFile0 = args.traces0
    tracesFile1 = args.traces1
    numTraces = args.numTraces
    startXLim = args.startXLim
    endXLim = args.endXLim
    startYLim = args.startYLim
    endYLim = args.endYLim
    plotFile = args.plotFile
    tValuesFile = args.tValuesFile
    step = args.step
    print("The following settings will be used to calculate the t-test:")
    print('traces0 = {}'.format(tracesFile0))   
    print('traces1 = {}'.format(tracesFile1))   
    print('num_traces = {}'.format(numTraces))   
    print('xlim_start = {}'.format(startXLim))   
    print('xlim_end = {}'.format(endXLim))   
    print('ylim_start = {}'.format(startYLim))   
    print('ylim_end = {}'.format(endYLim))   
    print('plot_file = {}'.format(plotFile))
    print('t_values_file = {}'.format(tValuesFile))
    print('step = {}'.format(step))
    print('\nCalculating t-values ...')
    t = doTtest(tracesFile0, tracesFile1, numTraces, step)
    np.save(tValuesFile, t)
    plotTValues(t, startXLim, endXLim, startYLim, endYLim, plotFile)

if __name__ == '__main__':
    main()
