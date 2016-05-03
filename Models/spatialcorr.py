import os
import numpy as np
import nibabel as nib
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from scipy.stats.stats import pearsonr
import pandas as pd

dataPath = '/home/despoB/kaihwang/TRSE/TTD/'
subjects = ['602']
ROIs = ['FEF', 'MFG', 'S1']
repEnhanceArrFFA = np.zeros((len(subjects), 29))
repSuppArrFFA = np.zeros((len(subjects), 29))
repEnhanceArrPPA = np.zeros((len(subjects), 29))
repSuppArrPPA = np.zeros((len(subjects), 29))

SpatialCorrDF = pd.DataFrame()
corrFunc2 = lambda a, c, d: np.array(pearsonr(a, d)) - np.array(pearsonr(c, d))

subjNum = 0
i=0
for subj in subjects:

    print '*******************{1}. SUBJECT {0}*******************'.format(subj, i)

    os.chdir(dataPath+subj+'/Loc')
    os.system("3dAFNItoNIFTI -prefix FIR_FH.nii.gz Localizer_FH_FIR+tlrc")
    os.system("3dAFNItoNIFTI -prefix FIR_HF.nii.gz Localizer_HF_FIR+tlrc")
    os.system("3dAFNItoNIFTI -prefix FIR_Fp.nii.gz Localizer_Fp_FIR+tlrc")
    os.system("3dAFNItoNIFTI -prefix FIR_Hp.nii.gz Localizer_Hp_FIR+tlrc")

    fn = 'FIR_FH.nii.gz'
    FH_beta = nib.load(fn).get_data()
    fn = 'FIR_HF.nii.gz'
    HF_beta = nib.load(fn).get_data()
    fn = 'FIR_Fp.nii.gz'
    Fp_beta = nib.load(fn).get_data()
    fn = 'FIR_Hp.nii.gz'
    Hp_beta = nib.load(fn).get_data()

    ffa = nib.load(dataPath + subj + '/Loc/FFA_indiv_ROI.nii.gz').get_data()
    ppa = nib.load(dataPath + subj + '/Loc/PPA_indiv_ROI.nii.gz').get_data()

    Loc_FH_ffa = FH_beta[ffa!=0].mean(1)
    Loc_Fp_ffa = Fp_beta[ffa!=0].mean(1)
    Loc_HF_ffa = HF_beta[ffa!=0].mean(1)
    Loc_Hp_ffa = Hp_beta[ffa!=0].mean(1)
    Loc_FH_ppa = FH_beta[ppa!=0].mean(1)
    Loc_Fp_ppa = Fp_beta[ppa!=0].mean(1)
    Loc_HF_ppa = HF_beta[ppa!=0].mean(1)
    Loc_Hp_ppa = Hp_beta[ppa!=0].mean(1)


    for site in ROIs:

        SpatialCorrDF.set_value(i, 'Subject', subj)
        SpatialCorrDF.set_value(i, 'Site', site)

        os.chdir(dataPath+subj+'/'+site)

        os.system("3dAFNItoNIFTI -prefix FIR_FH.nii.gz FH_FIR+tlrc")
        os.system("3dAFNItoNIFTI -prefix FIR_HF.nii.gz HF_FIR+tlrc")
        os.system("3dAFNItoNIFTI -prefix FIR_Fp.nii.gz Fp_FIR+tlrc")
        os.system("3dAFNItoNIFTI -prefix FIR_Hp.nii.gz Hp_FIR+tlrc")
        

        fn = 'FIR_FH.nii.gz'
        FH_beta = nib.load(fn).get_data()
        fn = 'FIR_HF.nii.gz'
        HF_beta = nib.load(fn).get_data()
        fn = 'FIR_Fp.nii.gz'
        Fp_beta = nib.load(fn).get_data()
        fn = 'FIR_Hp.nii.gz'
        Hp_beta = nib.load(fn).get_data()

        ffa = nib.load(dataPath + subj + '/Loc/FFA_indiv_ROI.nii.gz').get_data()
        ppa = nib.load(dataPath + subj + '/Loc/PPA_indiv_ROI.nii.gz').get_data()
        
        FH_ffa = FH_beta[ffa!=0].mean(1)
        Fp_ffa = Fp_beta[ffa!=0].mean(1)
        HF_ffa = HF_beta[ffa!=0].mean(1)
        Hp_ffa = Hp_beta[ffa!=0].mean(1)
        FH_ppa = FH_beta[ppa!=0].mean(1)
        Fp_ppa = Fp_beta[ppa!=0].mean(1)
        HF_ppa = HF_beta[ppa!=0].mean(1)
        Hp_ppa = Hp_beta[ppa!=0].mean(1)



        #Compared to target condition as template for FFA
        repEnhancement = corrFunc2(FH_ffa, Fp_ffa, Loc_FH_ffa)
        repSuppression = corrFunc2(HF_ffa, Fp_ffa, Loc_FH_ffa)
        print('FFA Representation Similarity compared to target, stimulation site: ' + site)
        print('\tRepresentation Enhancement: {0}'.format(repEnhancement[0]))
        print('\tRepresentation Suppression: {0}'.format(repSuppression[0]))
        SpatialCorrDF.set_value(i, 'FFARepEnhancement_T', repEnhancement[0])
        SpatialCorrDF.set_value(i, 'FFARepSuppression_T', repSuppression[0])

        #Compared to target only condition as template for PPA
        repEnhancement = corrFunc2(HF_ppa, Hp_ppa, Loc_HF_ppa)
        repSuppression = corrFunc2(FH_ppa, Hp_ppa, Loc_HF_ppa)
        print('PPA Representation Similarity compared to target, stimulation site: ' + site)
        print('\tRepresentation Enhancement: {0}'.format(repEnhancement[0]))
        print('\tRepresentation Suppression: {0}'.format(repSuppression[0]))
        SpatialCorrDF.set_value(i, 'PPARepEnhancement_T', repEnhancement[0])
        SpatialCorrDF.set_value(i, 'PPARepSuppression_T', repSuppression[0])

        #Compared to passive condition as template for FFA
        repEnhancement = corrFunc2(FH_ffa, Fp_ffa, Loc_Fp_ffa)
        repSuppression = corrFunc2(HF_ffa, Fp_ffa, Loc_Fp_ffa)
        print('FFA Representation Similarity compared to passive, stimulation site: ' + site)
        print('\tRepresentation Enhancement: {0}'.format(repEnhancement[0]))
        print('\tRepresentation Suppression: {0}'.format(repSuppression[0]))
        SpatialCorrDF.set_value(i, 'FFARepEnhancement_P', repEnhancement[0])
        SpatialCorrDF.set_value(i, 'FFARepSuppression_P', repSuppression[0])

        #Compared to passive only condition as template for PPA
        repEnhancement = corrFunc2(HF_ppa, Hp_ppa, Loc_Hp_ppa)
        repSuppression = corrFunc2(FH_ppa, Hp_ppa, Loc_Hp_ppa)
        print('PPA Representation Similarity compared to passive, stimulation site: ' + site)
        print('\tRepresentation Enhancement: {0}'.format(repEnhancement[0]))
        print('\tRepresentation Suppression: {0}'.format(repSuppression[0]))
        SpatialCorrDF.set_value(i, 'PPARepEnhancement_P', repEnhancement[0])
        SpatialCorrDF.set_value(i, 'PPARepSuppression_P', repSuppression[0])
        i = i+1


    #end for loop

SpatialCorrDF.to_csv('/home/despoB/kaihwang/bin/TTD/Data/SpatialCorr_df.csv')

