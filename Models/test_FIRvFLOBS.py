import numpy as np
import pandas as pd
import sys
import seaborn as sns
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings('ignore')

# script to compare the effects of FIR/FLOBS/basisc preproc on task connectivity between V1-FFA/PPA


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


def cal_MTD(TS_FFA, TS_PPA, TS_V1, window, n_runs, ntp_per_run):
	#reshape the TS into run x timepoints
	#to test the reshape works correctly np.arange(0,2400).reshape((12,200))
    TS_FFA_runs = np.reshape(TS_FFA, (n_runs, ntp_per_run))
    TS_PPA_runs = np.reshape(TS_PPA, (n_runs, ntp_per_run))
    TS_V1_runs = np.reshape(TS_V1, (n_runs, ntp_per_run))

	# get run indices that match condition
    MTD_FFA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
    MTD_PPA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
    Seed_FFA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
    Seed_PPA = np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))
    Seed_VC =np.zeros(ntp_per_run*n_runs).reshape((n_runs,ntp_per_run))

    for r in np.arange(0,12):
        MTD_FFA[r,:] = get_MTD(TS_FFA_runs[r,],TS_V1_runs[r,],window)
        MTD_PPA[r,:] = get_MTD(TS_PPA_runs[r,],TS_V1_runs[r,],window)
        Seed_FFA[r,:] = TS_FFA_runs[r,:]
        Seed_PPA[r,:] = TS_PPA_runs[r,:]
        Seed_VC[r,:] = TS_V1_runs[r,:]	
	
    return MTD_FFA, MTD_PPA, Seed_FFA, Seed_PPA, Seed_VC


if __name__ == "__main__":

    ffa_ts_FIR = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/FFA_allruns_ts.1D')
    ppa_ts_FIR = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/PPA_allruns_ts.1D')
    v1_ts_FIR = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/V1_allruns_ts.1D')

    ffa_ts_FLOBS = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/FFA_allruns_blobs_ts.1D')
    ppa_ts_FLOBS = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/PPA_allruns_blobs_ts.1D')
    v1_ts_FLOBS = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/V1_allruns_blobs_ts.1D')

    ffa_ts_preproc = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/FFA_allruns_preproc_ts.1D')
    ppa_ts_preproc = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/PPA_allruns_preproc_ts.1D')
    v1_ts_preproc = np.loadtxt('/home/despoB/TRSEPPI/TTD/Results/sub-7002/ses-Loc/V1_allruns_preproc_ts.1D')

    n_runs = 12
    ntp_per_run = 240
    window = 15 #simulation from Mac
    subject = 7002
    ses ='Loc'

    MTD_FFA_FIR, MTD_PPA_FIR, Seed_FFA_FIR, Seed_PPA_FIR, Seed_VC_FIR = cal_MTD(ffa_ts_FIR, ppa_ts_FIR, v1_ts_FIR, window, n_runs, ntp_per_run)
    MTD_FFA_FLOBS, MTD_PPA_FLOBS, Seed_FFA_FLOBS, Seed_PPA_FLOBS, Seed_VC_FLOBS = cal_MTD(ffa_ts_FLOBS, ppa_ts_FLOBS, v1_ts_FLOBS, window, n_runs, ntp_per_run)
    MTD_FFA_preproc, MTD_PPA_preproc, Seed_FFA_preproc, Seed_PPA_preproc, Seed_VC_preproc = cal_MTD(ffa_ts_preproc, ppa_ts_preproc, v1_ts_preproc, window, n_runs, ntp_per_run)

    conditions = ['FH', 'Fp', 'HF', 'Hp']
    scanlog_path = '/home/despoB/TRSEPPI/TTD/ScanLogs/'

    fn = scanlog_path + "%s_%s_run_order" %(7002, 'Loc')
    sequence = pd.read_table(fn, header = None)

    print ""
    print "**** Subject %s ****" %subject
    print "Correlation coefficient:"
    print "     FIR Model"
    for condition in conditions[0:2]:
        rindx = np.where(np.array(sequence[0]==condition))
        print "         Condition: %s, between FFA and V1: %s" %(condition, np.corrcoef([Seed_FFA_FIR[[rindx],:].flatten(),Seed_VC_FIR[[rindx],].flatten()])[0,1])
    for condition in conditions[2:4]:   
        rindx = np.where(np.array(sequence[0]==condition)) 
        print "         Condition: %s, between PPA and V1: %s" %(condition, np.corrcoef([Seed_PPA_FIR[[rindx],:].flatten(),Seed_VC_FIR[[rindx],].flatten()])[0,1])
        
    print "     FLOBS Model"
    for condition in conditions[0:2]:
        rindx = np.where(np.array(sequence[0]==condition))
        print "         Condition: %s, between FFA and V1: %s" %(condition, np.corrcoef([Seed_FFA_FLOBS[[rindx],:].flatten(),Seed_VC_FLOBS[[rindx],].flatten()])[0,1])
    for condition in conditions[2:4]:   
        rindx = np.where(np.array(sequence[0]==condition)) 
        print "         Condition: %s, between PPA and V1: %s" %(condition, np.corrcoef([Seed_PPA_FLOBS[[rindx],:].flatten(),Seed_VC_FLOBS[[rindx],].flatten()])[0,1])

    print "     preproc only Model"
    for condition in conditions[0:2]:
        rindx = np.where(np.array(sequence[0]==condition))
        print "         Condition: %s, between FFA and V1: %s" %(condition, np.corrcoef([Seed_FFA_preproc[[rindx],:].flatten(),Seed_VC_preproc[[rindx],].flatten()])[0,1])
    for condition in conditions[2:4]:   
        rindx = np.where(np.array(sequence[0]==condition)) 
        print "         Condition: %s, between PPA and V1: %s" %(condition, np.corrcoef([Seed_PPA_preproc[[rindx],:].flatten(),Seed_VC_preproc[[rindx],].flatten()])[0,1])



    print "MTD Score:"
    print "     FIR Model"
    for condition in conditions[0:2]:
        rindx = np.where(np.array(sequence[0]==condition))
        print "         Condition: %s, between FFA and V1: %s" %(condition, np.mean(MTD_FFA_FIR[[rindx],:]))
    for condition in conditions[2:4]:   
        rindx = np.where(np.array(sequence[0]==condition)) 
        print "         Condition: %s, between PPA and V1: %s" %(condition, np.mean(MTD_PPA_FIR[[rindx],:]))
        
    print "     FLOBS Model"
    for condition in conditions[0:2]:
        rindx = np.where(np.array(sequence[0]==condition))
        print "         Condition: %s, between FFA and V1: %s" %(condition, np.mean(MTD_FFA_FLOBS[[rindx],:]))
    for condition in conditions[2:4]:   
        rindx = np.where(np.array(sequence[0]==condition)) 
        print "         Condition: %s, between PPA and V1: %s" %(condition, np.mean(MTD_PPA_FLOBS[[rindx],:]))

    print "     preproc only Model"
    for condition in conditions[0:2]:
        rindx = np.where(np.array(sequence[0]==condition))
        print "         Condition: %s, between FFA and V1: %s" %(condition, np.mean(MTD_FFA_preproc[[rindx],:]))
    for condition in conditions[2:4]:   
        rindx = np.where(np.array(sequence[0]==condition)) 
        print "         Condition: %s, between PPA and V1: %s" %(condition, np.mean(MTD_PPA_preproc[[rindx],:]))

    print ""    
    print "Correlations between timeseries:"    
    print "    FFA, correlation between FIR and FLOBS %s" %(np.corrcoef([Seed_FFA_FIR.flatten(),Seed_FFA_FLOBS.flatten()])[0,1])
    print "    PPA, correlation between FIR and FLOBS %s" %(np.corrcoef([Seed_PPA_FIR.flatten(),Seed_PPA_FLOBS.flatten()])[0,1])
    print "    V1, correlation between FIR and FLOBS %s" %(np.corrcoef([Seed_VC_FIR.flatten(),Seed_VC_FLOBS.flatten()])[0,1])
    print "    FFA, correlation between FIR and preproc %s" %(np.corrcoef([Seed_FFA_FIR.flatten(),Seed_FFA_preproc.flatten()])[0,1])
    print "    PPA, correlation between FIR and preproc %s" %(np.corrcoef([Seed_PPA_FIR.flatten(),Seed_PPA_preproc.flatten()])[0,1])
    print "    V1, correlation between FIR and preproc %s" %(np.corrcoef([Seed_VC_FIR.flatten(),Seed_VC_preproc.flatten()])[0,1])
    print "    FFA, correlation between preproc and FLOBS %s" %(np.corrcoef([Seed_FFA_preproc.flatten(),Seed_FFA_FLOBS.flatten()])[0,1])
    print "    PPA, correlation between preproc and FLOBS %s" %(np.corrcoef([Seed_PPA_preproc.flatten(),Seed_PPA_FLOBS.flatten()])[0,1])
    print "    V1, correlation between preproc and FLOBS %s" %(np.corrcoef([Seed_VC_preproc.flatten(),Seed_VC_FLOBS.flatten()])[0,1])
















