import numpy as np
import pandas as pd
import sys

def coupling(data,window):
    """
        creates a functional coupling metric from 'data'
        data: should be organized in 'time x nodes' matrix
        smooth: smoothing parameter for dynamic coupling score

        # from PD
        #By default, the result is set to the right edge of the window. 
        This can be changed to the center of the window by setting center=True.
    """
    
    #define variables
    [tr,nodes] = data.shape
    der = tr-1
    td = np.zeros((der,nodes))
    td_std = np.zeros((der,nodes))
    data_std = np.zeros(nodes)
    mtd = np.zeros((der,nodes,nodes))
    sma = np.zeros((der,nodes*nodes))
    
    #calculate temporal derivative
    for i in range(0,nodes):
        for t in range(0,der):
            td[t,i] = data[t+1,i] - data[t,i]
    
    
    #standardize data
    for i in range(0,nodes):
        data_std[i] = np.std(td[:,i])
    
    td_std = td / data_std
   
   
    #functional coupling score
    for t in range(0,der):
        for i in range(0,nodes):
            for j in range(0,nodes):
                mtd[t,i,j] = td_std[t,i] * td_std[t,j]


    #temporal smoothing
    temp = np.reshape(mtd,[der,nodes*nodes])
    sma = pd.rolling_mean(temp,window)
    sma = np.reshape(sma,[der,nodes,nodes])
    
    return (mtd, sma)



a, b, fn, w = raw_input().split()

wsize=int(w)

TS1 = np.loadtxt(a)
TS2 = np.loadtxt(b)
MTD = coupling(np.array([TS1, TS2]).T, wsize)[1][:,0,1]
MTD[np.isnan(MTD)] = 0; #turn nans to zero for saving
MTD = np.insert(MTD,0,0) #insert 0 to the first element because its temporal diff
#shifted_MTD = np.concatenate((np.array([0,0,0]),MTD[8:],np.array([0,0,0,0,0])))

#print MTD[9:]
np.savetxt(fn, MTD)
