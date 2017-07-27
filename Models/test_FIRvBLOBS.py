
import numpy as np
import pandas as pd
import sys
import seaborn as sns
import matplotlib.pyplot as plt

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
    sma = pd.rolling_mean(temp,window, center=True)
    sma = np.reshape(sma,[der,nodes,nodes])
    
    return (mtd, sma)

def get_MTD(input1, input2, window):
	MTD = coupling(np.array([input1,input2]).T, window)[1][:,0,1]
	MTD[np.isnan(MTD)] = 0
	MTD = np.insert(MTD,0,0)

	return MTD 


def cal_MTD(TS_FFA, TS_PPA, TS_V1, window, conditions, n_runs, ntp_per_run, scanlog_path):
	#reshape the TS into run x timepoints
	#to test the reshape works correctly np.arange(0,2400).reshape((12,200))
	TS_FFA_runs = np.reshape(TS_FFA, (n_runs, ntp_per_run))
	TS_PPA_runs = np.reshape(TS_PPA, (n_runs, ntp_per_run))
	TS_V1_runs = np.reshape(TS_V1, (n_runs, ntp_per_run))

	#gen MTD and BC regressors based on the sequence of design
	fn = scanlog_path + "%s_%s_run_order" %(7002, 'Loc')
	sequence = pd.read_table(fn, header = None)

	for condition in conditions:
		
		# get run indices that match condition
		run_idx = np.arange(0,n_runs)[[np.array(sequence[0]==condition)]]
		MTD_FFA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
		MTD_PPA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
		Seed_FFA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
		Seed_PPA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
		Seed_VC =np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))

		for r in run_idx:
			MTD_FFA[r,:] = get_MTD(TS_FFA_runs[r,],TS_V1_runs[r,],window)
			MTD_PPA[r,:] = get_MTD(TS_PPA_runs[r,],TS_V1_runs[r,],window)
			Seed_FFA[r,:] = TS_FFA_runs[r,:]
			Seed_PPA[r,:] = TS_PPA_runs[r,:]
			Seed_VC[r,:] = TS_V1_runs[r,:]	
	return MTD_FFA, MTD_PPA, Seed_FFA, Seed_PPA, Seed_VC		


ffa_ts_FIR = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/FFA_allruns_ts.1D')
ppa_ts_FIR = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/PPA_allruns_ts.1D')
v1_ts_FIR = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/V1_allruns_ts.1D')

ffa_ts_BLOBS = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/FFA_allruns_blobs_ts.1D')
ppa_ts_BLOBS = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/PPA_allruns_blobs_ts.1D')
v1_ts_BLOBS = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/V1_allruns_blobs_ts.1D')

n_runs = 12
ntp_per_run = 240
window = 15 #simulation from MAC
subject = 7002
ses ='Loc'

conditions = ['Fp', 'Hp', 'FH', 'HF', 'F2', 'H2']
scanlog_path = '/home/despoB/TRSEPPI/TTD/ScanLogs/'

MTD_FFA_FIR, MTD_PPA_FIR, Seed_FFA_FIR, Seed_PPA_FIR, Seed_VC_FIR = cal_MTD(ffa_ts_FIR, ppa_ts_FIR, v1_ts_FIR, window, conditions, n_runs, ntp_per_run, scanlog_path)
MTD_FFA_BLOBS, MTD_PPA_BLOBS, Seed_FFA_BLOBS, Seed_PPA_BLOBS, Seed_VC_BLOBS = cal_MTD(ffa_ts_BLOBS, ppa_ts_BLOBS, v1_ts_BLOBS, window, conditions, n_runs, ntp_per_run, scanlog_path)







