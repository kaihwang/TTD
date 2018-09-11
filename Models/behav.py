 #analyze behavior data

import pandas as pd
import glob as glob
import numpy as np

rows = ['Subj', 'Cond', 'Motor', 'Match', 'Accu', 'FA', 'RH', 'LH', 'RT', 'OT', 'fn']


subjects = [7002, 7003, 7004, 7006, 7008, 7009, 7012, 7014, 7016, 7017, 7018, 7019, 7021, 7022, 7024, 7025, 7026, 7027]

sessions = ['Ips','S1', 'Loc']


df = pd.DataFrame(columns=('Subject', 'Session')) 


def pivot_behav():
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

			return df



#def get_MTD_behav():



if __name__ == "__main__":

	

	## get behav and TR info
	
	
	conditions = ['F2', 'H2', 'FH', 'HF', 'Fp', 'Hp']
	ROI = ['FFA', 'PPA']
	df =  pd.DataFrame(columns=rows)
	#s = 7002		

	for s in subjects:

		#get MTD files
		MTD={}
		for c in conditions:
			for r in ROI:
				fn = '/home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-Loc/%s_Loc_%s_MTD_w15_%s-V4v.1D' %(s, s, c, r)
				MTD[c,r] = np.loadtxt(fn)



		tdf = pd.DataFrame(columns=rows)
		

		#for ses in sessions:
			
		ses='Loc'
		fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/*%s*%s*txt' %(s, ses)
			
		for f in glob.glob(fn):
			tdf=tdf.append(pd.read_csv(f, sep='\t', header=None, names=rows))

		tdf['TR']=0	
		tdf['MTD_FFA']=0	
		tdf['MTD_PPA']=0	
		tdf = tdf.reset_index()
		#### add TR col
		
		runs = len(tdf)/39

		for r in np.arange(runs)+1:
			six = 0+(r-1)*39
			eix = 39+(r-1)*39
			
			for i in np.arange(six,eix):
				tdf.loc[i,'TR'] = np.round(tdf.iloc[i]['OT'] + 236*(r-1))

				for c in conditions:
					if tdf.loc[i,'Cond'] == c:
						tdf.loc[i,'MTD_FFA'] = MTD[c, 'FFA'][int(tdf.loc[i,'TR']-1)]
						tdf.loc[i,'MTD_PPA'] = MTD[c, 'PPA'][int(tdf.loc[i,'TR']-1)]
		df = df.append(tdf)					

						
		#np.mean(df[(df['Match']==1) & (df['Accu']==1)]['MTD_FFA'])



#df.to_csv('behav.csv')	