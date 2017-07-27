#!/bin/bash
# script to run FLOB model
export DISPLAY=""

WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/ScanLogs'
OutputDir='/home/despoB/kaihwang/TRSE/TTD/Results'
#SUB_ID="${SGE_TASK}";

s=7002
session=Loc

# get FLOBS out
#Make_flobs, select 5 functions
#[kaihwang@nx1 .flobs]$ cat hrfbasisfns.txt | cut -f1 -d" " >../flobs_basis1.1D
#[kaihwang@nx1 .flobs]$ cat hrfbasisfns.txt | cut -f3 -d" " >../flobs_basis2.1D
#[kaihwang@nx1 .flobs]$ cat hrfbasisfns.txt | cut -f5 -d" " >../flobs_basis3.1D
#[kaihwang@nx1 .flobs]$ cat hrfbasisfns.txt | cut -f7 -d" " >../flobs_basis4.1D
#[kaihwang@nx1 .flobs]$ cat hrfbasisfns.txt | cut -f9 -d" " >../flobs_basis5.1D

# convolve Flobs basis function with stim timing 
for condition in F2 H2 FH HF Fp Hp; do
	for flob in $(seq 1 1 5); do
		echo "" > ${OutputDir}/sub-${s}/ses-Loc/${condition}_flob${flob}.1D
	done	
done

for condition in F2 H2 FH HF Fp Hp; do
	for run in $(seq 1 1 12); do
		for flob in $(seq 1 1 5); do	
			n=$(head -n ${run} /home/despoB/kaihwang/TRSE/TTD/ScanLogs/7002_Loc_${condition}_stimtime.1D | tail -n 1)
			if [ "${n}" = "*" ]; then  
				yes "0" | head -n 240 >> ${OutputDir}/sub-${s}/ses-Loc/${condition}_flob${flob}.1D
			else
				waver -FILE 0.05 ${OutputDir}/sub-${s}/ses-Loc/flobs_basis${flob}.1D -TR 1 -tstim `head -n ${run} /home/despoB/kaihwang/TRSE/TTD/ScanLogs/7002_Loc_${condition}_stimtime.1D | tail -n 1` -numout 240 >> ${OutputDir}/sub-${s}/ses-Loc/${condition}_flob${flob}.1D
			fi
		done	
	done
done


3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-0*_bold_space-T1w_smoothed_preproc.nii.gz | sort -V) \
-automask \
-polort A \
-num_stimts 30 \
-censor ${OutputDir}/sub-${s}/ses-${session}/FD0.2_censor.1D \
-ortvec ${OutputDir}/sub-${s}/ses-${session}/nuisance.tsv confounds \
-stim_file 1 ${OutputDir}/sub-${s}/ses-Loc/FH_flob1.1D -stim_label 1 FH_flob1 \
-stim_file 2 ${OutputDir}/sub-${s}/ses-Loc/FH_flob2.1D -stim_label 2 FH_flob2 \
-stim_file 3 ${OutputDir}/sub-${s}/ses-Loc/FH_flob3.1D -stim_label 3 FH_flob3 \
-stim_file 4 ${OutputDir}/sub-${s}/ses-Loc/FH_flob4.1D -stim_label 4 FH_flob4 \
-stim_file 5 ${OutputDir}/sub-${s}/ses-Loc/FH_flob5.1D -stim_label 5 FH_flob5 \
-stim_file 6 ${OutputDir}/sub-${s}/ses-Loc/HF_flob1.1D -stim_label 6 HF_flob1 \
-stim_file 7 ${OutputDir}/sub-${s}/ses-Loc/HF_flob2.1D -stim_label 7 HF_flob2 \
-stim_file 8 ${OutputDir}/sub-${s}/ses-Loc/HF_flob3.1D -stim_label 8 HF_flob3 \
-stim_file 9 ${OutputDir}/sub-${s}/ses-Loc/HF_flob4.1D -stim_label 9 HF_flob4 \
-stim_file 10 ${OutputDir}/sub-${s}/ses-Loc/HF_flob5.1D -stim_label 10 HF_flob5 \
-stim_file 11 ${OutputDir}/sub-${s}/ses-Loc/Fp_flob1.1D -stim_label 11 Fp_flob1 \
-stim_file 12 ${OutputDir}/sub-${s}/ses-Loc/Fp_flob2.1D -stim_label 12 Fp_flob2 \
-stim_file 13 ${OutputDir}/sub-${s}/ses-Loc/Fp_flob3.1D -stim_label 13 Fp_flob3 \
-stim_file 14 ${OutputDir}/sub-${s}/ses-Loc/Fp_flob4.1D -stim_label 14 Fp_flob4 \
-stim_file 15 ${OutputDir}/sub-${s}/ses-Loc/Fp_flob5.1D -stim_label 15 Fp_flob5 \
-stim_file 16 ${OutputDir}/sub-${s}/ses-Loc/Hp_flob1.1D -stim_label 16 Hp_flob1 \
-stim_file 17 ${OutputDir}/sub-${s}/ses-Loc/Hp_flob2.1D -stim_label 17 Hp_flob2 \
-stim_file 18 ${OutputDir}/sub-${s}/ses-Loc/Hp_flob3.1D -stim_label 18 Hp_flob3 \
-stim_file 19 ${OutputDir}/sub-${s}/ses-Loc/Hp_flob4.1D -stim_label 19 Hp_flob4 \
-stim_file 20 ${OutputDir}/sub-${s}/ses-Loc/Hp_flob5.1D -stim_label 20 Hp_flob5 \
-stim_file 21 ${OutputDir}/sub-${s}/ses-Loc/F2_flob1.1D -stim_label 21 F2_flob1 \
-stim_file 22 ${OutputDir}/sub-${s}/ses-Loc/F2_flob2.1D -stim_label 22 F2_flob2 \
-stim_file 23 ${OutputDir}/sub-${s}/ses-Loc/F2_flob3.1D -stim_label 23 F2_flob3 \
-stim_file 24 ${OutputDir}/sub-${s}/ses-Loc/F2_flob4.1D -stim_label 24 F2_flob4 \
-stim_file 25 ${OutputDir}/sub-${s}/ses-Loc/F2_flob5.1D -stim_label 25 F2_flob5 \
-stim_file 26 ${OutputDir}/sub-${s}/ses-Loc/H2_flob1.1D -stim_label 26 H2_flob1 \
-stim_file 27 ${OutputDir}/sub-${s}/ses-Loc/H2_flob2.1D -stim_label 27 H2_flob2 \
-stim_file 28 ${OutputDir}/sub-${s}/ses-Loc/H2_flob3.1D -stim_label 28 H2_flob3 \
-stim_file 29 ${OutputDir}/sub-${s}/ses-Loc/H2_flob4.1D -stim_label 29 H2_flob4 \
-stim_file 30 ${OutputDir}/sub-${s}/ses-Loc/H2_flob5.1D -stim_label 30 H2_flob5 \
-gltsym 'SYM: +1*Fp_flob1 +1*Fp_flob2 +1*Fp_flob3 + 1*Fp_flob4 + 1*Fp_flob5 -1*Hp_flob1 -1*Hp_flob2 -1*Hp_flob3 -1*Hp_flob4 -1*Hp_flob5' -glt_label 1 F-H \
-rout \
-tout \
-bucket ${OutputDir}/sub-${s}/ses-${session}/Localizer_FLOBSmodel_stats.nii.gz \
-GOFORIT 100 \
-noFDR \
-errts ${OutputDir}/sub-${s}/ses-${session}/Localizer_FLOBS_errts.nii.gz \
-allzero_OK	-jobs 3

#extract ts
3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROIFIR.nii.gz -q ${OutputDir}/sub-${s}/ses-${session}/Localizer_FLOBS_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_blobs_ts.1D
3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROIFIR.nii.gz -q ${OutputDir}/sub-${s}/ses-${session}/Localizer_FLOBS_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_blobs_ts.1D
3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROIFIR.nii.gz -q ${OutputDir}/sub-${s}/ses-${session}/Localizer_FLOBS_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_blobs_ts.1D


#extract ts from preproc, unmodeled ts
3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROIFIR.nii.gz -q ${OutputDir}/sub-${s}/ses-${session}/functional_concat.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_preproc_ts.1D
3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROIFIR.nii.gz -q ${OutputDir}/sub-${s}/ses-${session}/functional_concat.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_preproc_ts.1D
3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROIFIR.nii.gz -q ${OutputDir}/sub-${s}/ses-${session}/functional_concat.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_preproc_ts.1D



