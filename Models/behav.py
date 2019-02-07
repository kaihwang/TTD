 #analyze behavior data

import pandas as pd
import glob as glob
import numpy as np
import os



def pivot_behav(TMS):
	#i=0
	
	rows = ['Subj', 'Cond', 'Motor', 'Match', 'Accu', 'FA', 'RH', 'LH', 'RT', 'OT', 'fn']
	if TMS:
		subjects = [7002, 7003, 7004, 7006, 7008, 7009, 7012, 7014, 7016, 7017, 7018, 7019, 7021,7022,7024,7025,7026,7027,6601, 6602, 6603, 6605, 6617]
		sessions = ['Ips', 'S1']
	else:
		subjects = [6601, 6602, 6603, 6605, 6617, 7002, 7003, 7004, 7006, 7008, 7009, 7012, 7014, 7016, 7017, 7018, 7019]
		sessions = ['Ips', 'S1']


	df = pd.DataFrame() 

	for s in subjects:
		tdf = pd.DataFrame(columns=rows)
		
		for ses in sessions:
			
			fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/*%s*%s*txt' %(s, ses)
			
			for f in glob.glob(fn):
				tdf=tdf.append(pd.read_csv(f, sep='\t', header=None, names=rows))

			tdf['Session'] = ses
			
			df = df.append(tdf)	
			# conditions = ['F2', 'H2', 'FH', 'HF']

			# for c in conditions:
				
			# 	if tdf.loc[i,'Cond'] == c : 
			# 		df.loc[i, 'Accu']


			# 	df.loc[i, 'Subject'] = s	
			# 	df.loc[i, 'Session'] = ses
			
			
			# df.loc[i, 'F2_Accu'] = tdf.loc[(tdf['Cond']=='F2')]['Accu'].mean()
			# df.loc[i, 'H2_Accu'] = tdf.loc[(tdf['Cond']=='H2')]['Accu'].mean()
			# df.loc[i, 'FH_Accu'] = tdf.loc[(tdf['Cond']=='FH')]['Accu'].mean()
			# df.loc[i, 'HF_Accu'] = tdf.loc[(tdf['Cond']=='HF')]['Accu'].mean()
			# df.loc[i, 'F2_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='F2')]['FA'].mean()
			# df.loc[i, 'H2_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='H2')]['FA'].mean()
			# df.loc[i, 'FH_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='FH')]['FA'].mean()
			# df.loc[i, 'HF_FA'] = tdf.loc[(tdf['Match']==0) & (tdf['Cond']=='HF')]['FA'].mean()
			# df.loc[i, 'F2_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='F2') & (tdf['Accu']==1)]['RT'].mean()
			# df.loc[i, 'H2_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='H2') & (tdf['Accu']==1)]['RT'].mean()
			# df.loc[i, 'FH_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='FH') & (tdf['Accu']==1)]['RT'].mean()
			# df.loc[i, 'HF_RT'] = tdf.loc[(tdf['Match']==1) & (tdf['Cond']=='HF') & (tdf['Accu']==1)]['RT'].mean()

			# i=i+1

	df.loc[df['Cond'] == 'FH', 'Category' ] = 'Face'
	df.loc[df['Cond'] == 'F2', 'Category' ] = 'Face'
	df.loc[df['Cond'] == 'HF', 'Category' ] = 'Buildings'
	df.loc[df['Cond'] == 'H2', 'Category' ] = 'Buildings'

	df.loc[df['Cond'] == 'FH', 'Load' ] = '1-Back'
	df.loc[df['Cond'] == 'F2', 'Load' ] = '2-Back'
	df.loc[df['Cond'] == 'HF', 'Load' ] = '1-Back'
	df.loc[df['Cond'] == 'H2', 'Load' ] = '2-Back'		
	df.loc[df['RT'] == -1, 'RT' ] = np.nan
	df.loc[df['RT'] == 0, 'RT'] = np.nan
	df = df[df['Cond']!='Hp']
	df = df[df['Cond']!='Fp']
	df = df[df['RT']<2]
	return df



def MTD_behav():
	subjects = ['6601','6602','6603','6605','6617', '7002', '7003', '7004', '7006', '7008', '7009', '7012', '7014', '7016', '7017', '7018', '7019', '7021', '7022', '7024', '7025', '7026', '7027']
	rows = ['Subj', 'Cond', 'Motor', 'Match', 'Accu', 'FA', 'RH', 'LH', 'RT', 'OT', 'fn']
	conditions = ['F2', 'H2', 'FH', 'HF']  #'Fp', 'Hp'
	ROI = ['FFA', 'PPA']
	df =  pd.DataFrame(columns=rows)
	#s = 7002		

	for s in subjects:

		#get MTD files
		MTD={}
		for c in conditions:
			for r in ROI:
				try:
					fn = '/home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-Loc/%s_Loc_%s_MTD_w15_%s-V1.1D' %(s, s, c, r)
					MTD[c,r] = np.loadtxt(fn)
				except: 	
					#r2 = 'loc'
					fn = '/home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-Loc/%s_loc_%s_MTD_w15_%s-V1.1D' %(s, s, c, r)
					MTD[c,r] = np.loadtxt(fn)

		tdf = pd.DataFrame(columns=rows)
		

		#for ses in sessions:
		
		if s in ['6601','6602','6603','6605','6617']:
			ses='loc'
		else:	
			ses='Loc'
		fn = '/home/despoB/TRSEPPI/TTD/ScanLogs/*%s*%s*txt' %(s, ses)
			
		for f in sorted(glob.glob(fn)):
			tdf=tdf.append(pd.read_csv(f, sep='\t', header=None, names=rows))

		tdf['TR']=0	
		tdf['MTD_FFA']=0	
		tdf['MTD_PPA']=0	
		
		
		tdf = tdf.reset_index()
		#### add TR col
		
		if s in ['6601','6602','6603','6605','6617']:
			ntrial = 48
			run_length = 155
		else:
			ntrial = 39
			run_length = 236

		runs = len(tdf)/ntrial

		for r in np.arange(runs)+1:
			six = 0+(r-1)*ntrial
			eix = ntrial+(r-1)*ntrial
			
			for i in np.arange(six,eix):
				tdf.loc[i,'TR'] = np.round(tdf.iloc[i]['OT'] + run_length*(r-1))

				for c in conditions:
					if tdf.loc[i,'Cond'] == c:
						tdf.loc[i,'MTD_FFA'] = MTD[c, 'FFA'][int(tdf.loc[i,'TR']-1)]
						tdf.loc[i,'MTD_PPA'] = MTD[c, 'PPA'][int(tdf.loc[i,'TR']-1)]

						if c == 'F2':
							tdf.loc[i,'Category'] = 'Faces' 
							tdf.loc[i,'Load'] = '2-Back' 
						if c == 'H2':
							tdf.loc[i,'Category'] = 'Buildings' 
							tdf.loc[i,'Load'] = '2-Back' 	
						if c == 'FH': 
							tdf.loc[i,'Category'] = 'Faces' 
							tdf.loc[i,'Load'] = '1-Back' 
						if c == 'HF':
							tdf.loc[i,'Category'] = 'Buildings' 
							tdf.loc[i,'Load'] = '1-Back' 	

		tdf = tdf[tdf['Cond']!='Fp']
		tdf = tdf[tdf['Cond']!='Hp']					
		tdf = tdf.reset_index()

		df = df.append(tdf)			



def get_FIR_df(): 
	Results_DIR = '/home/despoB/kaihwang/TRSE/TTD/Results'
	Subjects = ['6601','6602','6603','6605','6617', '7002', '7003', '7004', '7006', '7008', '7009', '7012', '7014', '7016', '7017', '7018', '7019', '7021', '7022', '7024', '7025', '7026', '7027']

	Conditions = ['H2', 'F2', 'HF', 'FH']
	#ROIs=['S1', 'Ips', 'Loc']
	ROIs=['Loc']
	Category=['FFA', 'PPA', 'V1']  #'FFA', 'PPA', 

	FIR_df = pd.DataFrame()
	for s in Subjects:
	    for roi in ROIs:
	        for i, cond in enumerate(Conditions):           
	            for cat in Category:
	                tmpdf = pd.DataFrame()
	                
	                if cat =='MD':
	                    cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/ROIs/%s.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_MNI_FIR.nii.gz > ~/tmp/tmp' %(cat, s, roi, cond)
	                elif cat =='AN':
	                    cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/ROIs/%s.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_MNI_FIR.nii.gz > ~/tmp/tmp' %(cat, s, roi, cond)
	                else:
	                    cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-Loc/%s_indiv_ROIFIR_MNI.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_MNI_FIR.nii.gz > ~/tmp/tmp' %(s, cat, s, roi, cond)
	                
	                os.system(cmd)

	                a=np.loadtxt('/home/despoB/kaihwang/tmp/tmp')

	                tmpdf['Beta'] = a
	                tmpdf['Session'] = roi
	                tmpdf['Subj'] = int(s)
	                tmpdf['Condition'] = cond
	                
	                if cond == 'H2':
	                    tmpdf['Load'] = '2-Back'
	                    tmpdf['Category'] = 'Buildings'
	                elif cond == 'F2':
	                    tmpdf['Load'] = '2-Back'
	                    tmpdf['Category'] = 'Faces'
	                elif cond == 'FH':
	                    tmpdf['Load'] = '1-Back'
	                    tmpdf['Category'] = 'Faces'
	                elif cond == 'HF':
	                    tmpdf['Load'] = '1-Back'   
	                    tmpdf['Category'] = 'Buildings'
	                
	                
	                
	                tmpdf['ROI'] = cat
	                tmpdf['Volume'] = np.arange(1,len(tmpdf)+1)
	                FIR_df = FIR_df.append(tmpdf,ignore_index=True)
	return FIR_df



def TMS_FIR():
	Results_DIR = '/home/despoB/kaihwang/TRSE/TTD/Results'
	Subjects = ['6601', '6602', '6603', '6605','6617','7002', '7003', '7004', '7006', '7008', '7009', '7012', '7014', '7016', '7017', '7018', '7019']
	#Subjects = ['7002', '7003', '7004', '7006', '7008', '7009', '7012', '7014', '7016', '7017', '7018', '7019', '7021', '7022', '7024', '7025', '7026', '7027']

	Conditions = ['H2', 'F2', 'HF', 'FH']
	ROIs=['S1', 'Ips']
	Category=['FFA', 'PPA']

	FIR_df = pd.DataFrame()
	for s in Subjects:
	    for roi in ROIs:
	        for i, cond in enumerate(Conditions):           
	            for cat in Category:
	                tmpdf = pd.DataFrame()
	                cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-Loc/%s_indiv_ROIFIR.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_FIR.nii.gz > ~/tmp/tmp' %(s, cat, s, roi, cond)

	                os.system(cmd)

	                a=np.loadtxt('/home/despoB/kaihwang/tmp/tmp')

	                tmpdf['Beta'] = a
	                tmpdf['Session'] = roi
	                tmpdf['Subj'] = int(s)
	                tmpdf['Condition'] = cond
	                
	                if cond == 'H2':
	                    tmpdf['Load'] = '2-Back'
	                    tmpdf['Category'] = 'Buildings'
	                elif cond == 'F2':
	                    tmpdf['Load'] = '2-Back'
	                    tmpdf['Category'] = 'Faces'
	                elif cond == 'FH':
	                    tmpdf['Load'] = '1-Back'
	                    tmpdf['Category'] = 'Faces'
	                elif cond == 'HF':
	                    tmpdf['Load'] = '1-Back'   
	                    tmpdf['Category'] = 'Buildings'
	                
	                
	                
	                tmpdf['ROI'] = cat
	                tmpdf['Volume'] = np.arange(1,len(tmpdf)+1)
	                FIR_df = FIR_df.append(tmpdf,ignore_index=True)
    retrun FIR_df


def AUC_TMS_FIR():
	Results_DIR = '/home/despoB/kaihwang/TRSE/TTD/Results'
	Subjects = ['6601', '6602', '6603', '6605','6617','7002', '7003', '7004', '7006', '7008', '7009', '7012', '7014', '7016', '7017', '7018', '7019']
	#Subjects = ['7002', '7003', '7004', '7006', '7008', '7009', '7012', '7014', '7016', '7017', '7018', '7019', '7021', '7022', '7024', '7025', '7026', '7027']

	Conditions = ['H2', 'F2', 'HF', 'FH']
	ROIs=['S1', 'Ips']
	Category=['FFA', 'PPA']

	FIR_df = pd.DataFrame()
	for s in Subjects:
		for roi in ROIs:
			for i, cond in enumerate(Conditions):           
				for cat in Category:
					tmpdf = pd.DataFrame()
					cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-Loc/%s_indiv_ROIFIR.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_FIR.nii.gz > ~/tmp/tmp' %(s, cat, s, roi, cond)

					os.system(cmd)

					a=np.loadtxt('/home/despoB/kaihwang/tmp/tmp')

					tmpdf.loc[0, 'Beta'] = np.trapz(a)
					tmpdf.loc[0, 'Session'] = roi
					tmpdf.loc[0, 'Subj'] = int(s)
					tmpdf.loc[0, 'Condition'] = cond
					
					if cond == 'H2':
					    tmpdf.loc[0, 'Load'] = '2-Back'
					    tmpdf.loc[0, 'Category'] = 'Buildings'
					elif cond == 'F2':
					    tmpdf.loc[0, 'Load'] = '2-Back'
					    tmpdf.loc[0, 'Category'] = 'Faces'
					elif cond == 'FH':
					    tmpdf.loc[0, 'Load'] = '1-Back'
					    tmpdf.loc[0, 'Category'] = 'Faces'
					elif cond == 'HF':
					    tmpdf.loc[0, 'Load'] = '1-Back'   
					    tmpdf.loc[0, 'Category'] = 'Buildings'
					
					
					
					tmpdf['ROI'] = cat
					tmpdf['Volume'] = np.arange(1,len(tmpdf)+1)
					FIR_df = FIR_df.append(tmpdf,ignore_index=True) 

	retrun FIR_df





def get_AUC_FIR():
	Results_DIR = '/home/despoB/kaihwang/TRSE/TTD/Results'
	Subjects = ['6601','6602','6603','6605','6617', '7002', '7003', '7004', '7006', '7008', '7009', '7012', '7014', '7016', '7017', '7018', '7019', '7021', '7022', '7024', '7025', '7026', '7027']

	Conditions = ['H2', 'F2', 'HF', 'FH']
	#ROIs=['S1', 'Ips', 'Loc']
	ROIs=['Loc']
	Category=['FFA', 'PPA', 'V1'] 

	AUC_df = pd.DataFrame()
	for s in Subjects:
	    for roi in ROIs:
	        for i, cond in enumerate(Conditions):           
	            for cat in Category:
	                tmpdf = pd.DataFrame()
	                
	                if cat =='MD':
	                    cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/ROIs/%s.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_MNI_FIR.nii.gz > ~/tmp/tmp' %(cat, s, roi, cond)
	                elif cat =='AN':
	                    cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/ROIs/%s.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_MNI_FIR.nii.gz > ~/tmp/tmp' %(cat, s, roi, cond)
	                else:
	                    cmd = '3dmaskave -mask /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-Loc/%s_indiv_ROIFIR_MNI.nii.gz -quiet /home/despoB/kaihwang/TRSE/TTD/Results/sub-%s/ses-%s/Localizer_%s_MNI_FIR.nii.gz > ~/tmp/tmp' %(s, cat, s, roi, cond)
	                
	                os.system(cmd)

	                a=np.loadtxt('/home/despoB/kaihwang/tmp/tmp')

	                tmpdf.loc[0,'Beta'] = np.trapz(a)
	                tmpdf.loc[0,'Session'] = roi
	                tmpdf.loc[0,'Subj'] = int(s)
	                tmpdf.loc[0,'Condition'] = cond
	                
	                if cond == 'H2':
	                    tmpdf.loc[0,'Load'] = '2-Back'
	                    tmpdf.loc[0,'Category'] = 'Buildings'
	                elif cond == 'F2':
	                    tmpdf.loc[0,'Load'] = '2-Back'
	                    tmpdf.loc[0,'Category'] = 'Faces'
	                elif cond == 'FH':
	                    tmpdf.loc[0,'Load'] = '1-Back'
	                    tmpdf.loc[0,'Category'] = 'Faces'
	                elif cond == 'HF':
	                    tmpdf['Load'] = '1-Back'   
	                    tmpdf['Category'] = 'Buildings'

	                tmpdf.loc[0,'ROI'] = cat
	                #tmpdf['Volume'] = np.arange(1,len(tmpdf)+1)
	                AUC_df = AUC_df.append(tmpdf,ignore_index=True)    
	return AUC_df


if __name__ == "__main__":

	
	## get behav and TR info
	#TMS_behav_df = pivot_behav(TMS=True)
	FIR_df = AUC_TMS_FIR()
	#FIR_df = get_FIR_df()
	#AUC_FIR = get_AUC_FIR()





