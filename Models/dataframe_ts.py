# read residual ts data into dataframe

import pandas as pd
import glob
import os
import numpy as np
#import scipy.stats
#from ggplot import *

os.chdir('/home/despoB/kaihwang/TRSE/TTD')
Subjects = [601, 603, 602, 605]#[glob.glob('6*')]

ROIs = ['FFA', 'PPA', 'VC']
Conditions = ['FH', 'HF', 'Fp', 'Hp']
dsets = ['FIR'] #'nusiance'
sites = ['FEF', 'S1', 'MFG']

os.chdir('/home/despoB/kaihwang/bin/TTD/Models')


for dset in dsets:
	TS_df = pd.DataFrame()
	for s in Subjects:
			for site in sites:
				for i, cond in enumerate(Conditions):
					for run in np.arange(1,4):
						#for roi in ROIpairs:	
						tmpdf = pd.DataFrame()
						#tmpdf['Time'] = np.arange(1,153)
						
						for roi in ROIs:
							fn = '/home/despoB/kaihwang/TRSE/TTD/%s/%s/1Ds/%s_Reg_%s_%s_run%s.1D' %(s, site, dset, cond, roi, run)
							ts = np.loadtxt(fn)
							tmpdf[roi] = ts
						
						tmpdf['Subject'] = s
						tmpdf['Condition'] = cond
						tmpdf['Dataset'] = dset	
						tmpdf['Run'] = run	
						tmpdf['site'] = site

						TS_df = TS_df.append(tmpdf,  ignore_index=True)

	#os.chdir('/home/despoB/kaihwang/bin/TDSigEI/')
	#fn = '/home/despoB/kaihwang/bin/TDSigEI/Data/TS_%s_df.csv' %dset
	#TS_df.to_csv(fn)


#groupedDF = FIR_df.groupby(['ROI','Condition','Volume'])
#SEMdf = groupedDF.aggregate(scipy.stats.sem)
#MEANdf = groupedDF.aggregate(np.mean)
#plotdata = MEANdf.reset_index()
#ggplot(aes(x='Volume', y='Beta', colour='Condition'), data = FIR_df) + stat_smooth(se=True)+ facet_wrap('ROI') + xlim(1, 21)
