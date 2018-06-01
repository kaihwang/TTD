import fileinput
import csv
import sys
import pandas as pd
import glob
import numpy as np
import os.path

#parse block order
#os.chdir('/home/despoB/kaihwang/TRSE/TTD')
#Subjects = glob.glob('5*')
#these are old FTTD subjects
#[601, 602, 603, 605]
#os.chdir('/home/despoB/kaihwang/TRSE/TTD/ScanLogs')


def write_stimtime(filepath, inputvec):
	''' short hand function to write AFNI style stimtime'''
	if os.path.isfile(filepath) is False:
			f = open(filepath, 'w')
			for val in inputvec[0]:
				if val =='*':
					f.write(val + '\n')
				else:
					# this is to dealt with some weird formating issue
					f.write(np.array2string(np.around(val,2)).replace('\n','')[4:-1] + '\n') 
			f.close()



def parse_stim(s, ROI, ntrials_per_run, num_runs):
	''' parse stim log from pscyhtoolbox script
	input: s, subjects
		ROIs,
		ntrials_per_rn
		num_runs 

	'''
	
	num_runs = int(num_runs)
	
	#fix issue with inconsistent naming
	if ROI == 'F':
		site = 'FEF'
	if ROI == 'M':
		site = 'MFG'
	if ROI == 'S':
		site = 'S1'		
	if ROI == 'Loc':
		site = 'Loc'	
	if ROI == 'S1':
		site = 'S1'
	if ROI == 'Ips':
		site = 'Ips'
		
			
	print "parsing stimulus timing for subject %s, session %s" %(s, ROI)	

	filestring = '/home/despoB/kaihwang/TRSE/TTD/ScanLogs/fMRI_Data_%s_%s_ses*.txt' %(s, ROI)
	timing_logs = sorted(glob.glob(filestring)) #important to sort since glob seems to randomly order files.

	#to check the order is correct, in ascending order
	print('check timing logs are in ascending order:')
	print(timing_logs) 

	#load timing logs, concat depend on number of sessions
	df = pd.read_table(timing_logs[0], header= None)
	for i in np.arange(1, len(timing_logs), 1):
		df = df.append(pd.read_table(timing_logs[i], header= None))
	# give each column a name.
	df.columns = ['SubjID', 'Condition', 'MotorMapping', 'Target', 'Accu', 'FA', 'RH', 'LH', 'RT', 'OnsetTime', 'pic']

	# create new column variable of "run number" for every trial (48 trials per run). 12 blocks totoal 
	df['Run'] = np.repeat(np.arange(1, num_runs+1), ntrials_per_run)

	# extract the order of each block condition and save to a text file
	run_order = df.groupby(['Run', 'Condition', 'MotorMapping']).sum().reset_index()[['Run', 'Condition', 'MotorMapping']]
	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_run_order' %(s, site)
	if os.path.isfile(fn) is False:			
		run_order[['Condition','MotorMapping']].to_csv(fn, index=None, header=None, sep = '\t')

	#write out target+distractor (TD) runs
	TD_runs = run_order[(run_order['Condition'] == 'HF') | (run_order['Condition'] == 'FH')]['Run'].values	
	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_TD_runs' %s
	if os.path.isfile(fn) is False:			
		np.savetxt(fn, TD_runs, fmt='%2d')

	#write out 2bk runs
	TD_runs = run_order[(run_order['Condition'] == 'H2') | (run_order['Condition'] == 'F2')]['Run'].values	
	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_2B_runs' %s
	if os.path.isfile(fn) is False:			
		np.savetxt(fn, TD_runs, fmt='%2d')	

	#write out passive runs	
	To_runs = run_order[(run_order['Condition'] == 'Hp') | (run_order['Condition'] == 'Fp')]['Run'].values	
	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_P_runs' %s
	if os.path.isfile(fn) is False:			
		np.savetxt(fn, To_runs, fmt='%2d')


	#create FIR timing for every condition, extract trial timing for the first trial of every block
	FH_stimtime = [['*']*num_runs] #stimtime format, * for runs with no events of this stimulus class
	HF_stimtime = [['*']*num_runs] #create one of this for every condition
	Fp_stimtime = [['*']*num_runs]
	Hp_stimtime = [['*']*num_runs]
	F2_stimtime = [['*']*num_runs]
	H2_stimtime = [['*']*num_runs]
	Fo_stimtime = [['*']*num_runs]
	Ho_stimtime = [['*']*num_runs]

	for i, run in enumerate(np.arange(1,num_runs+1)):  #loop through 12 runs
		run_df = df[df['Run']==run].reset_index() #"view" of block we are curreint sorting through
		FH_run_trials = [] #empty vector to store trial time info for the current block
		HF_run_trials = []
		Hp_run_trials = []
		Fp_run_trials = []
		H2_run_trials = []
		F2_run_trials = []
		Ho_run_trials = []
		Fo_run_trials = []

		for tr in np.arange(0,ntrials_per_run):  #this is to loop through trials
			if run_df.loc[tr,'Condition'] in ('FH'):
				FH_run_trials.append(run_df.loc[tr,'OnsetTime']) #if a match of condition, append trial timing						
			
			if run_df.loc[tr,'Condition'] in ('HF'):
				HF_run_trials.append(run_df.loc[tr,'OnsetTime']) 
				
			if run_df.loc[tr,'Condition'] in ('Fp'):
				Fp_run_trials.append(run_df.loc[tr,'OnsetTime']) 

			if run_df.loc[tr,'Condition'] in ('Hp'):
				Hp_run_trials.append(run_df.loc[tr,'OnsetTime']) 	

			if run_df.loc[tr,'Condition'] in ('F2'):
				F2_run_trials.append(run_df.loc[tr,'OnsetTime']) 

			if run_df.loc[tr,'Condition'] in ('H2'):
				H2_run_trials.append(run_df.loc[tr,'OnsetTime']) 
			if run_df.loc[tr,'Condition'] in ('Fo'):
				Fo_run_trials.append(run_df.loc[tr,'OnsetTime']) 

			if run_df.loc[tr,'Condition'] in ('Ho'):
				Ho_run_trials.append(run_df.loc[tr,'OnsetTime']) 					

		if any(FH_run_trials):
			FH_stimtime[0][i] = FH_run_trials	#put trial timing of each block into the stimtime array	
		if any(HF_run_trials):
			HF_stimtime[0][i] = HF_run_trials			
		if any(Fp_run_trials):
			Fp_stimtime[0][i] = Fp_run_trials				
		if any(Hp_run_trials):
			Hp_stimtime[0][i] = Hp_run_trials
		if any(F2_run_trials):
			F2_stimtime[0][i] = F2_run_trials				
		if any(H2_run_trials):
			H2_stimtime[0][i] = H2_run_trials
		if any(Fo_run_trials):
			Fo_stimtime[0][i] = Fo_run_trials				
		if any(Ho_run_trials):
			Ho_stimtime[0][i] = Ho_run_trials		


	#write out stimtime array to text file. 		
	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_FH_stimtime.1D' %(s, site)
	write_stimtime(fn, FH_stimtime)		
		
	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_HF_stimtime.1D' %(s, site)
	write_stimtime(fn, HF_stimtime)	

	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_Fp_stimtime.1D' %(s, site)
	write_stimtime(fn, Fp_stimtime)	

	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_Hp_stimtime.1D' %(s, site)
	write_stimtime(fn, Hp_stimtime)	

	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_F2_stimtime.1D' %(s, site)
	write_stimtime(fn, F2_stimtime)	

	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_H2_stimtime.1D' %(s, site)
	write_stimtime(fn, H2_stimtime)					

	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_Fo_stimtime.1D' %(s, site)
	write_stimtime(fn, Fo_stimtime)	

	fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/%s_%s_Ho_stimtime.1D' %(s, site)
	write_stimtime(fn, Ho_stimtime)	

if __name__ == "__main__":

	Subject, ROI, nruns = raw_input().split()

	#Subjects = [7002]
	#ROIs = ['Loc']
	ntrials_per_run = 39
	#nruns = 12

	parse_stim(Subject, ROI, ntrials_per_run, nruns)






	
