#!/usr/bin/python
# -*- coding: utf-8 -*-

# This scripts takes raw power trace and calculates the t value for each traces sample wise
import os
import numpy as np
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt

class TVLACalc:

    def __init__(self, numSamples, start_xlim=0, end_xlim=None, start_ylim=-10, end_ylim=10, threshold=4.5):
        # Q0
        self.M1_0 = np.zeros((1, numSamples), dtype=np.float64)     #first-order raw moment
        self.n_0 = 0        #number of elements  
        self.CS2_0 = np.zeros((1, numSamples), dtype=np.float64)
        self.CS3_0 = np.zeros((1, numSamples), dtype=np.float64)
        self.CS4_0 = np.zeros((1, numSamples), dtype=np.float64)

        # Q1        
        self.M1_1 = np.zeros((1, numSamples), dtype=np.float64)     #first-order raw moment
        self.n_1 = 0        #number of elements  
        self.CS2_1 = np.zeros((1, numSamples), dtype=np.float64)
        self.CS3_1 = np.zeros((1, numSamples), dtype=np.float64)
        self.CS4_1 = np.zeros((1, numSamples), dtype=np.float64)

        self.threshold = threshold
        self.numSamples = numSamples
        self.start_xlim = start_xlim
        if end_xlim is not None:
            self.end_xlim = end_xlim
        else:
            self.end_xlim = numSamples
        self.start_ylim = start_ylim
        self.end_ylim = end_ylim

    def addTrace(self, trace, setNum):
        if setNum == 0:
            d_0 = trace - self.M1_0 # delta
            self.n_0 += 1
            n_0 = float(self.n_0)
            ###M1
            self.M1_0 = self.M1_0 + d_0/n_0
            ###CS2
            self.CS2_0 = self.CS2_0 + d_0**2*(n_0-1)/n_0
            ###CS3
            self.CS3_0 = self.CS3_0 - 3*d_0/n_0 *self.CS2_0 + d_0**3*(n_0-1)*((n_0-1)**2-1)/n_0**3
            ###CS4
            self.CS4_0 = self.CS4_0 - 4*d_0/n_0 *self.CS3_0 +  6*d_0**2/n_0**2*self.CS2_0 + d_0**4*(n_0-1) * ((n_0-1)**3+1)/n_0**4

        else:
            d_1 = trace - self.M1_1 # delta
            self.n_1 += 1
            n_1 = float(self.n_1)
            ###M1
            self.M1_1 = self.M1_1 + d_1/n_1
            ###CS2
            self.CS2_1 = self.CS2_1 + d_1**2*(n_1-1)/n_1
            ###CS3
            self.CS3_1 = self.CS3_1 - 3*d_1/n_1 *self.CS2_1 + d_1**3*(n_1-1)*((n_1-1)**2-1)/n_1**3
            ###CS4
            self.CS4_1 = self.CS4_1 - 4*d_1/n_1 *self.CS3_1 +  6*d_1**2/n_1**2*self.CS2_1 + d_1**4*(n_1-1) * ((n_1-1)**3+1)/n_1**4
    
    @property
    def CM2_0(self):
        return self.CS2_0 / self.n_0

    @property
    def CM2_1(self):
        return self.CS2_1 / self.n_1

    @property
    def CM3_0(self):
        return self.CS3_0 / self.n_0

    @property
    def CM3_1(self):
        return self.CS3_1 / self.n_1

    @property
    def CM4_0(self):
        return self.CS4_0 / self.n_0

    @property
    def CM4_1(self):
        return self.CS4_1 / self.n_1

    def calcTvalues1(self):
        epsilon = 1e-24
        m0 = self.M1_0
        m1 = self.M1_1
        var0 = self.CM2_0
        var1 = self.CM2_1
        t_array = (m0 - m1) / np.sqrt((var0+epsilon) / self.n_0 + (var1+epsilon)/ self.n_1) #div by zero issue
        passed = (t_array > self.threshold).sum() == 0
        return (t_array.reshape(t_array.shape[1]), passed)

    def plot(self, fileName):
        plt.clf()
        # plt.figure(figsize=(10,8))
        (t_array, passed) = self.calcTvalues()
        threshold = [self.threshold] * self.numSamples
        minus_threshold = [-1 * self.threshold] * self.numSamples
        plt.plot(t_array, color='r')
        plt.plot(threshold, color='b')
        plt.plot(minus_threshold, color='b')
        plt.ylim(self.start_ylim, self.end_ylim)
        plt.xlim(self.start_xlim, self.end_xlim)
        plt.xlabel('Sample No.')
        plt.ylabel('t-value')
        plt.savefig(fileName)
    
    def saveData1(self, Dir, label):
        plt.clf()
        (t_array, passed) = self.calcTvalues1()
        #print(t_array)
        np.save(os.path.join(Dir, f'1st-order-tvla-{label}.npy') , t_array)
        threshold = [self.threshold] * self.numSamples
        minus_threshold = [-1 * self.threshold] * self.numSamples
        plt.plot(t_array, color='r')
        plt.plot(threshold, color='b')
        plt.plot(minus_threshold, color='b')
        plt.ylim(self.start_ylim, self.end_ylim)
        plt.xlim(self.start_xlim, self.end_xlim)
        plt.xlabel('Sample No.')
        plt.ylabel('t-value')
        plt.savefig(os.path.join(Dir, f'1st-order-tvla-{label}.png'))
        return (t_array, passed)

    def calcTvalues2(self):
        epsilon = 1e-24
        m0 = self.CM2_0
        m1 = self.CM2_1
        var0 = self.CM4_0 - self.CM2_0**2
        var1 = self.CM4_1 - self.CM2_1**2
        t_array = (m0 - m1) / np.sqrt((var0+epsilon) / self.n_0 + (var1+epsilon)/ self.n_1) #div by zero issue
        passed = (t_array > self.threshold).sum() == 0
        return (t_array.reshape(t_array.shape[1]), passed)

    def saveData2(self, Dir, label):
        plt.clf()
        (t_array, passed) = self.calcTvalues2()
        #print(t_array)
        np.save(os.path.join(Dir, f'2nd-order-tvla-{label}.npy') , t_array)
        threshold = [self.threshold] * self.numSamples
        minus_threshold = [-1 * self.threshold] * self.numSamples
        plt.plot(t_array, color='r')
        plt.plot(threshold, color='b')
        plt.plot(minus_threshold, color='b')
        plt.ylim(self.start_ylim, self.end_ylim)
        plt.xlim(self.start_xlim, self.end_xlim)
        plt.xlabel('Sample No.')
        plt.ylabel('t-value')
        plt.savefig(os.path.join(Dir, f'2nd-order-tvla-{label}.png'))
        return (t_array, passed)
    
    def doTVLA(self, traceFile, fvrFile, traceNum, analysisDir):
        print("Calculating TVLA results. Please wait ...")
        traceFile = open(traceFile, "r+b")
        #print(traceNum)
        fvrFile = open(fvrFile, 'r')
        for i in range(traceNum):
            trace = np.load(traceFile) #load one traces
            #print(trace[0:10])
            #print(trace.shape)
            c = fvrFile.read(1)
            self.addTrace(trace, int(c))
        self.saveData1(analysisDir, "")
        traceFile.close()
        fvrFile.close()
        print('Done.')

if __name__== '__main__':
    tCalc = TVLACalc(1000)

    tCalc.doTVLA(traceFile="fobosworkspace/aes_tvla/capture/attempt-01/powerTraces.npy", #os.path.join(captureDir, acqConf['traceFile']),
             fvrFile="fobosworkspace/aes_tvla/capture/attempt-01/fvrchoicefile.txt", #os.path.join(captureDir, acqConf['fvrFile']),
             traceNum=10, #acqConf['traceNum'],
             analysisDir="fobosworkspace/aes_tvla/capture/attempt-01/analysis/attempt-06" #analysisDir1
            )