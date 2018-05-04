#analyze behavior data

import pandas as pd
import glob as glob


rows = ['Subj', 'Cond', 'Motor', 'Match', 'Accu', 'FA', 'RH', 'LH', 'RT', 'OT', 'fn']


subjects = [7002, 7003, 7004, 7006, 7008, 7009, 7012, 7014, 7016, 7017, 7018, 7019]

sessions = ['Ips','S1', 'Loc']


df = pd.DataFrame(columns=('Subject', 'Session')) 

i=0
for s in subjects:
	tdf = pd.DataFrame(columns=rows)
	
	for ses in sessions:
		
		fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/*%s*%s*txt' %(s, ses)
		
		for f in glob.glob(fn):
			tdf=tdf.append(pd.read_csv(f, sep='\t', header=None, names=rows))
	
		i=i+1

		df.loc[i, 'Subject'] = s
		df.loc[i, 'Session'] = ses
		df.loc[i, 'F2_Accu'] = tdf.loc[(tdf['Cond']=='F2')]['Accu'].mean()
		df.loc[i, 'H2_Accu'] = tdf.loc[(tdf['Cond']=='H2')]['Accu'].mean()
		df.loc[i, 'FH_Accu'] = tdf.loc[(tdf['Cond']=='FH')]['Accu'].mean()
		df.loc[i, 'HF_Accu'] = tdf.loc[(tdf['Cond']=='HF')]['Accu'].mean()
		df.loc[i, 'F2_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='F2')]['FA'].mean()
		df.loc[i, 'H2_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='H2')]['FA'].mean()
		df.loc[i, 'FH_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='FH')]['FA'].mean()
		df.loc[i, 'HF_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='HF')]['FA'].mean()
		df.loc[i, 'F2_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='F2') & (tdf['Accu']==1)]['RT'].mean()
		df.loc[i, 'H2_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='H2') & (tdf['Accu']==1)]['RT'].mean()
		df.loc[i, 'FH_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='FH') & (tdf['Accu']==1)]['RT'].mean()
		df.loc[i, 'HF_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='HF') & (tdf['Accu']==1)]['RT'].mean()

df.to_csv('behav.csv')	