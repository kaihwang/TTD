#!/bin/bash
# script to run FIR model for each condition. For localization FFA/PPA

WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/ScanLogs'
OutputDir='/home/despoB/kaihwang/TRSE/TTD/Results'

for s in 7002; do

	if [ ! -d ${OutputDir}/sub-${s}/ses-Loc ]; then
		mkdir ${OutputDir}/sub-${s}/
		mkdir ${OutputDir}/sub-${s}/ses-Loc
	fi

	#cd ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func
	#rm *FIR*
	#rm *nusiance*
	#rm Localizer*
	
	
	#concat nuisance regressors
	#this is the confound variables. we need the last six (13-24)
	# WhiteMatter	GlobalSignal	stdDVARS	non-stdDVARS	vx-wisestdDVARS	FramewiseDisplacement	
	# tCompCor00	tCompCor01	tCompCor02	tCompCor03	tCompCor04	tCompCor05
	# aCompCor00	aCompCor01	aCompCor02	aCompCor03	aCompCor04	aCompCor05	X	Y	Z	RotX	RotY	RotZ

	echo "" > ${OutputDir}/sub-${s}/ses-Loc/confounds.tsv
	echo "" > ${OutputDir}/sub-${s}/ses-Loc/motion.tsv
	for f in $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run*.tsv | sort -V); do
		cat ${f} | tail -n+2 | cut -f13-24 >> ${OutputDir}/sub-${s}/ses-Loc/confounds.tsv
		cat ${f} | tail -n+2 | cut -f19-24 >> ${OutputDir}/sub-${s}/ses-Loc/motion.tsv
	done
	
	#create censor
	1d_tool.py -infile ${OutputDir}/sub-${s}/ses-Loc/motion.tsv \
	-set_nruns 12 -show_censor_count -censor_motion 0.2 ${OutputDir}/sub-${s}/ses-Loc/FD0.2 -censor_prev_TR -overwrite

	#run localizer Model
	if [ ! -f ${OutputDir}/sub-${s}/ses-Loc/Localizer_FIR_errts.nii.gz ]; then
		3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-0*_space-T1w_preproc.nii.gz | sort -V) \
		-automask \
		-polort A \
		-num_stimts 6 \
		-censor ${OutputDir}/sub-${s}/ses-Loc/FD0.2_censor.1D \
		-ortvec ${OutputDir}/sub-${s}/ses-Loc/confounds.tsv confounds \
		-stim_times 1 ${SCRIPTS}/${s}_Loc_FH_stimtime.1D 'TENT(0, 12, 13)' -stim_label 1 FH \
		-stim_times 2 ${SCRIPTS}/${s}_Loc_HF_stimtime.1D 'TENT(0, 12, 13)' -stim_label 2 HF \
		-stim_times 3 ${SCRIPTS}/${s}_Loc_Fp_stimtime.1D 'TENT(0, 12, 13)' -stim_label 3 Fp \
		-stim_times 4 ${SCRIPTS}/${s}_Loc_Hp_stimtime.1D 'TENT(0, 12, 13)' -stim_label 4 Hp \
		-stim_times 5 ${SCRIPTS}/${s}_Loc_F2_stimtime.1D 'TENT(0, 12, 13)' -stim_label 5 F2 \
		-stim_times 6 ${SCRIPTS}/${s}_Loc_H2_stimtime.1D 'TENT(0, 12, 13)' -stim_label 6 H2 \
		-iresp 1 ${OutputDir}/sub-${s}/ses-Loc/Localizer_FH_FIR \
		-iresp 2 ${OutputDir}/sub-${s}/ses-Loc/Localizer_HF_FIR \
		-iresp 3 ${OutputDir}/sub-${s}/ses-Loc/Localizer_Fp_FIR \
		-iresp 4 ${OutputDir}/sub-${s}/ses-Loc/Localizer_Hp_FIR \
		-iresp 5 ${OutputDir}/sub-${s}/ses-Loc/Localizer_F2_FIR \
		-iresp 6 ${OutputDir}/sub-${s}/ses-Loc/Localizer_H2_FIR \
		-gltsym 'SYM: +1*FH +1*Fp +1*F2 -1*HF -1*Hp -1*H2 ' -glt_label 1 F-H \
		-gltsym 'SYM: +1*FH +1*HF -1*Fp -1*Hp ' -glt_label 2 TD-p \
		-gltsym 'SYM: +1*F2 +1*H2 -1*FH -1*HF ' -glt_label 3 2B-TD \
		-gltsym 'SYM: +0.5*F2 +0.5*H2 ' -glt_label 4 2B \
		-gltsym 'SYM: +0.5*FH +0.5*HF ' -glt_label 5 TD \
		-gltsym 'SYM: +0.5*Fp +0.5*Hp ' -glt_label 6 p \
		-gltsym 'SYM: +0.5*FH +0.5*Fp ' -glt_label 7 F \
		-gltsym 'SYM: +0.5*HF +0.5*Hp ' -glt_label 8 H \
		-rout \
		-tout \
		-bucket ${OutputDir}/sub-${s}/ses-Loc/Localizer_stats \
		-x1D ${OutputDir}/sub-${s}/ses-Loc/Localizer_design_mat \
		-GOFORIT 100 \
		-noFDR \
		-nocout \
		-errts ${OutputDir}/sub-${s}/ses-Loc/Localizer_FIR_errts.nii.gz \
		-allzero_OK
	fi
	# create syn link
	#ln -s ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/anat/sub-${s}_ses-Loc_T1w_preproc.nii.gz ${OutputDir}/sub-${s}/ses-Loc/native_anat.nii.gz
	#-x1D_stop \


	#create FFA PPA masks
	# 3dTcat -prefix face_v_house_tstat Localizer_stats+tlrc[3]
	# 3dcalc \
	# -a face_v_house_tstat+tlrc \
	# -b /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/Group_FFA_mask.nii.gz \
	# -expr 'ispositive(a*b)' -short -prefix FFAmasked.nii.gz
	# 3dmaskdump -mask FFAmasked.nii.gz -quiet FFAmasked.nii.gz | sort -k4 -n -r | head -n 255 | 3dUndump -master FFAmasked.nii.gz -ijk -prefix FFA_indiv_ROI.nii.gz stdin

	# 3dcalc \
	# -a face_v_house_tstat+tlrc \
	# -b /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/Group_PPA_mask.nii.gz \
	# -expr 'isnegative(a*b)' -short -prefix PPAmasked.nii.gz
	# 3dmaskdump -mask PPAmasked.nii.gz -quiet PPAmasked.nii.gz | sort -k4 -n -r | head -n 255 | 3dUndump -master PPAmasked.nii.gz -ijk -prefix PPA_indiv_ROI.nii.gz stdin
	
	# #create V1 mask 
	# 3dmaskdump -mask /home/despoB/kaihwang/TRSE/TTD/ROIs/vismask.nii.gz -quiet Localizer_stats+tlrc[1] | sort -k4 -n -r | head -n 1 | 3dUndump -master FFAmasked.nii.gz -srad 8 -ijk -prefix V1_indiv_ROI.nii.gz stdin


done
#
