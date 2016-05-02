import fileinput
import csv
import sys
import pandas as pd
import glob
import numpy as np
import os.path

#parse block order
os.chdir('/home/despoB/kaihwang/TRSE/TTD')
#Subjects = glob.glob('5*')
Subjects = [602]
os.chdir('/home/despoB/kaihwang/TRSE/TTD/Scripts/Logs')


def write_stimtime(filepath, inputvec):
	if os.path.isfile(filepath) is False:
			f = open(filepath, 'w')
			for val in inputvec[0]:
				if val =='*':
					f.write(val + '\n')
				else:
					# this is to dealt with some weird formating issue
					f.write(np.array2string(np.around(val,2)).replace('\n','')[4:-1] + '\n') 
			f.close()



for s in Subjects:

	for ROI in ['F', 'M', 'S']:

		#fix issue with inconsistent naming
		if ROI == 'F':
			site = 'FEF'
		if ROI == 'M':
			site = 'MFG'
		if ROI == 'S':
			site = 'S1'		

		timing_logs = []
		for ses in [3,2,1]:
			filestring = 'fMRI_Data_%s_%s_session%s*.txt' %(s, ROI, ses)
			timing_logs.append(glob.glob(filestring)[0]) #files to be loaded

		print(timing_logs)
		#load timing logs and concat into a pandas dataframe
		df = pd.read_table(timing_logs[2], header= None).append(pd.read_table(timing_logs[1], header= None)).append(pd.read_table(timing_logs[0],header= None))
		# give each column a name.
		df.columns = ['SubjID', 'Condition', 'MotorMapping', 'Target', 'Accu', 'FA', 'RH', 'LH', 'RT', 'OnsetTime', 'pic']

		# create new column variable of "block number" for every trial (48 trials per run). 12 blocks totoal 
		df['Block'] = np.repeat(np.arange(1, 13),48)

		# extract the order of each block condition and save to a text file
		run_order = df.groupby(['Block', 'Condition', 'MotorMapping']).sum().reset_index()[['Block', 'Condition', 'MotorMapping']]
		fn = '/home/despoB/TRSEPPI/TTD/Scripts/%s_%s_run_order' %(s, site)
		if os.path.isfile(fn) is False:			
			run_order[['Condition','MotorMapping']].to_csv(fn, index=None, header=None, )
		

		#write out target+distractor (TD) runs
		TD_runs = run_order[(run_order['Condition'] == 'HF') | (run_order['Condition'] == 'FH')]['Block'].values	
		fn = '/home/despoB/TRSEPPI/TTD/Scripts/%s_TD_runs' %s
		if os.path.isfile(fn) is False:			
			np.savetxt(fn, TD_runs, fmt='%2d')

		#write out passive runs	
		To_runs = run_order[(run_order['Condition'] == 'Hp') | (run_order['Condition'] == 'Fp')]['Block'].values	
		fn = '/home/despoB/TRSEPPI/TTD/Scripts/%s_P_runs' %s
		if os.path.isfile(fn) is False:			
			np.savetxt(fn, To_runs, fmt='%2d')



		#create FIR timing for every condition, extract trial timing for the first trial of every block
		FH_stimtime = [['*']*12] #stimtime format, * for runs with no events of this stimulus class
		HF_stimtime = [['*']*12] #create one of this for every condition
		Fp_stimtime = [['*']*12]
		Hp_stimtime = [['*']*12]
	
		for i, block in enumerate(np.arange(1,13)):  #loop through 12 locks
			block_df = df[df['Block']==block].reset_index() #"view" of block we are curreint sorting through
			FH_block_trials = [] #empty vector to store trial time info for the current block
			HF_block_trials = []
			Hp_block_trials = []
			Fp_block_trials = []

			for tr in np.arange(0,48,12):  #this is the first trial of each block
				if block_df.loc[tr,'Condition'] in ('FH'):
					FH_block_trials.append(block_df.loc[tr,'OnsetTime']) #if a match of condition, append trial timing						
				
				if block_df.loc[tr,'Condition'] in ('HF'):
					HF_block_trials.append(block_df.loc[tr,'OnsetTime']) 
					
				if block_df.loc[tr,'Condition'] in ('Fp'):
					Fp_block_trials.append(block_df.loc[tr,'OnsetTime']) 

				if block_df.loc[tr,'Condition'] in ('Hp'):
					Hp_block_trials.append(block_df.loc[tr,'OnsetTime']) 		

			if any(FH_block_trials):
				FH_stimtime[0][i] = FH_block_trials	#put trial timing of each block into the stimtime array	
			if any(HF_block_trials):
				HF_stimtime[0][i] = HF_block_trials			
			if any(Fp_block_trials):
				Fp_stimtime[0][i] = Fp_block_trials				
			if any(Hp_block_trials):
				Hp_stimtime[0][i] = Hp_block_trials

		#write out stimtime array to text file. 		
		fn = '/home/despoB/TRSEPPI/TTD/Scripts/%s_%s_FH_stimtime.1D' %(s, site)
		write_stimtime(fn, FH_stimtime)		
			
		fn = '/home/despoB/TRSEPPI/TTD/Scripts/%s_%s_HF_stimtime.1D' %(s, site)
		write_stimtime(fn, HF_stimtime)	

		fn = '/home/despoB/TRSEPPI/TTD/Scripts/%s_%s_Fp_stimtime.1D' %(s, site)
		write_stimtime(fn, Fp_stimtime)	

		fn = '/home/despoB/TRSEPPI/TTD/Scripts/%s_%s_Hp_stimtime.1D' %(s, site)
		write_stimtime(fn, Hp_stimtime)					



#create FIR regressors #not used??
# block_start_time = np.tile(([1.5, 42, 82.5, 121.5]),[4,1])
# for tr in np.arange(0,18):
#     StimTime = block_start_time + tr * 1.5
#     g = tr+1
#     fn = '/home/despoB/TRSEPPI/TTD/Scripts/FIR_%s.1D' %g
#     if os.path.isfile(fn) is False:
#     	np.savetxt(fn, StimTime, fmt='%2.2f')




	
