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
    temp = pd.DataFrame(temp)
    sma = temp.rolling(window=window, center=True).mean()
    sma = np.reshape(np.array(sma),[der,nodes,nodes])
    
    return (mtd, sma)

def get_MTD(input1, input2, window):
	MTD = coupling(np.array([input1,input2]).T, window)[1][:,0,1]
	MTD[np.isnan(MTD)] = 0
	MTD = np.insert(MTD,0,0)

	return MTD 



#input
if __name__ == "__main__":

	n_runs, ntp_per_run, window, subject, ses, ffa_path, ppa_path, v1_path, VC = raw_input().split()
	n_runs = int(n_runs)
	ntp_per_run = int(ntp_per_run)
	window = int(window) #simulation from MAC
	subject = int(subject)
	#ses ='Loc'

	conditions = ['Fp', 'Hp', 'FH', 'HF', 'F2', 'H2', 'Fo', 'Ho']
	scanlog_path = '/home/despoB/TRSEPPI/TTD/ScanLogs/'
	output_path = '/home/despoB/TRSEPPI/TTD/Results/sub-%s/ses-%s/' %(subject, ses)


	TS_FFA = np.loadtxt(ffa_path) #np.random.randn(n_runs * ntp_per_run)
	TS_PPA = np.loadtxt(ppa_path) #np.random.randn(n_runs * ntp_per_run)
	TS_V1 = np.loadtxt(v1_path) #np.random.randn(n_runs * ntp_per_run)

	#reshape the TS into run x timepoints
	#to test the reshape works correctly np.arange(0,2400).reshape((12,200))
	TS_FFA_runs = np.reshape(TS_FFA, (n_runs, ntp_per_run))
	TS_PPA_runs = np.reshape(TS_PPA, (n_runs, ntp_per_run))
	TS_V1_runs = np.reshape(TS_V1, (n_runs, ntp_per_run))	

	#gen MTD and BC regressors based on the sequence of design
	fn = scanlog_path + "%s_%s_run_order" %(subject, ses)
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


		fn = output_path + '%s_%s_%s_MTD_w%s_FFA-%s.1D'	%(subject,ses, condition, window, VC)
		np.savetxt(fn, MTD_FFA.flatten())
		fn = output_path +  '%s_%s_%s_MTD_w%s_PPA-%s.1D'	%(subject,ses, condition, window, VC)
		np.savetxt(fn, MTD_PPA.flatten())
		fn = output_path +  '%s_%s_%s_BC_FFA.1D'	%(subject,ses, condition)
		np.savetxt(fn, Seed_FFA.flatten())
		fn = output_path +  '%s_%s_%s_BC_PPA.1D'	%(subject,ses, condition)
		np.savetxt(fn, Seed_PPA.flatten())
		fn = output_path + '%s_%s_%s_BC_%s.1D'	%(subject,ses, condition, VC)
		np.savetxt(fn, Seed_VC.flatten())








