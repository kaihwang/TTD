#!/bin/bash
# script to run FIR model for each condition. For localization FFA/PPA

WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/ScanLogs'
OutputDir='/home/despoB/kaihwang/TRSE/TTD/Results'

for s in 7002; do

	rm -rf ${OutputDir}/sub-${s}/ses-Loc
	if [ ! -d ${OutputDir}/sub-${s}/ses-Loc ]; then
		mkdir ${OutputDir}/sub-${s}/
		mkdir ${OutputDir}/sub-${s}/ses-Loc
	fi

	for run in $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-*_space-T1w_preproc.nii.gz | grep -o 'run-[[:digit:]][[:digit:]][[:digit:]]'  | grep -o "[[:digit:]][[:digit:]][[:digit:]]"); do
		3dBlurToFWHM -input ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-${run}_space-T1w_preproc.nii.gz \
		-prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-${run}_space-T1w_smoothed_preproc.nii.gz \
		-FWHM 4
	done
	
	
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
	#FIR model
	if [ ! -f ${OutputDir}/sub-${s}/ses-Loc/Localizer_FIR_errts.nii.gz ]; then
		3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-0*_space-T1w_smoothed_preproc.nii.gz | sort -V) \
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
		-gltsym 'SYM: +1*Fp -1*Hp ' -glt_label 1 F-H \
		-gltsym 'SYM: +1*FH +1*HF -1*Fp -1*Hp ' -glt_label 2 TD-p \
		-gltsym 'SYM: +1*F2 +1*H2 -1*FH -1*HF ' -glt_label 3 2B-TD \
		-gltsym 'SYM: +1*F2 +1*H2 -1*Fp -1*Hp ' -glt_label 4 2B-p \
		-gltsym 'SYM: +0.5*F2 +0.5*H2 ' -glt_label 5 2B \
		-gltsym 'SYM: +0.5*FH +0.5*HF ' -glt_label 6 TD \
		-gltsym 'SYM: +0.5*Fp +0.5*Hp ' -glt_label 7 p \
		-gltsym 'SYM: +1*Fp ' -glt_label 8 F \
		-gltsym 'SYM: +1*Hp ' -glt_label 9 H \
		-rout \
		-tout \
		-bucket ${OutputDir}/sub-${s}/ses-Loc/Localizer_FIRmodel_stats \
		-GOFORIT 100 \
		-noFDR \
		-nocout \
		-errts ${OutputDir}/sub-${s}/ses-Loc/Localizer_FIR_errts.nii.gz \
		-allzero_OK	
	fi

	#SPM basis functions
	if [ ! -f ${OutputDir}/sub-${s}/ses-Loc/Localizer_SPMGmodel_stats+orig.HEAD ]; then
		3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-0*_space-T1w_smoothed_preproc.nii.gz | sort -V) \
		-automask \
		-polort A \
		-num_stimts 6 \
		-censor ${OutputDir}/sub-${s}/ses-Loc/FD0.2_censor.1D \
		-ortvec ${OutputDir}/sub-${s}/ses-Loc/confounds.tsv confounds \
		-stim_times 1 ${SCRIPTS}/${s}_Loc_FH_stimtime.1D 'SPMG3' -stim_label 1 FH \
		-stim_times 2 ${SCRIPTS}/${s}_Loc_HF_stimtime.1D 'SPMG3' -stim_label 2 HF \
		-stim_times 3 ${SCRIPTS}/${s}_Loc_Fp_stimtime.1D 'SPMG3' -stim_label 3 Fp \
		-stim_times 4 ${SCRIPTS}/${s}_Loc_Hp_stimtime.1D 'SPMG3' -stim_label 4 Hp \
		-stim_times 5 ${SCRIPTS}/${s}_Loc_F2_stimtime.1D 'SPMG3' -stim_label 5 F2 \
		-stim_times 6 ${SCRIPTS}/${s}_Loc_H2_stimtime.1D 'SPMG3' -stim_label 6 H2 \
		-iresp 1 ${OutputDir}/sub-${s}/ses-Loc/Localizer_FH_SPMG \
		-iresp 2 ${OutputDir}/sub-${s}/ses-Loc/Localizer_HF_SPMG \
		-iresp 3 ${OutputDir}/sub-${s}/ses-Loc/Localizer_Fp_SPMG \
		-iresp 4 ${OutputDir}/sub-${s}/ses-Loc/Localizer_Hp_SPMG \
		-iresp 5 ${OutputDir}/sub-${s}/ses-Loc/Localizer_F2_SPMG \
		-iresp 6 ${OutputDir}/sub-${s}/ses-Loc/Localizer_H2_SPMG \
		-gltsym 'SYM: +1*Fp -1*Hp ' -glt_label 1 F-H \
		-gltsym 'SYM: +1*FH +1*HF -1*Fp -1*Hp ' -glt_label 2 TD-p \
		-gltsym 'SYM: +1*F2 +1*H2 -1*FH -1*HF ' -glt_label 3 2B-TD \
		-gltsym 'SYM: +1*F2 +1*H2 -1*Fp -1*Hp ' -glt_label 4 2B-p \
		-gltsym 'SYM: +0.5*F2 +0.5*H2 ' -glt_label 5 2B \
		-gltsym 'SYM: +0.5*FH +0.5*HF ' -glt_label 6 TD \
		-gltsym 'SYM: +0.5*Fp +0.5*Hp ' -glt_label 7 p \
		-gltsym 'SYM: +1*Fp ' -glt_label 8 F \
		-gltsym 'SYM: +1*Hp ' -glt_label 9 H \
		-rout \
		-tout \
		-bucket ${OutputDir}/sub-${s}/ses-Loc/Localizer_SPMGmodel_stats \
		-GOFORIT 100 \
		-noFDR \
		-nocout \
		-errts ${OutputDir}/sub-${s}/ses-Loc/Localizer_SPMG_errts.nii.gz \
		-allzero_OK	
	fi


	#get T1 link
	mri_convert /home/despoB/kaihwang/TRSE/TTD/fmriprep/freesurfer/sub-${s}/mri/T1.mgz ${OutputDir}/sub-${s}/ses-Loc/Native_T1.nii.gz

	#Reverse normalize Group FFA PPA V1 mask
	antsApplyTransforms --default-value 0 --float 1 \
	--reference-image ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-001_bold_space-T1w_brainmask.nii.gz \
	--input /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/FFA_LR_mask.nii.gz \
	--interpolation NearestNeighbor \
	--output ${OutputDir}/sub-${s}/ses-Loc/Group_to_nativeFFA.nii.gz \
	--transform /home/despoB/TRSEPPI/TTD/fmriprep/work/fmriprep_wf/single_subject_${s}_wf/anat_preproc_wf/t1_2_mni/ants_t1_to_mniInverseComposite.h5
	
	antsApplyTransforms --default-value 0 --float 1 \
	--reference-image ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-001_bold_space-T1w_brainmask.nii.gz \
	--input /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/PPA_LR_mask.nii.gz \
	--interpolation NearestNeighbor \
	--output ${OutputDir}/sub-${s}/ses-Loc/Group_to_nativePPA.nii.gz \
	--transform /home/despoB/TRSEPPI/TTD/fmriprep/work/fmriprep_wf/single_subject_${s}_wf/anat_preproc_wf/t1_2_mni/ants_t1_to_mniInverseComposite.h5
	
	antsApplyTransforms --default-value 0 --float 1 \
	--reference-image ${WD}/fmriprep/fmriprep/sub-${s}/ses-Loc/func/sub-${s}_ses-Loc_task-TDD_run-001_bold_space-T1w_brainmask.nii.gz \
	--input /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/Group_V1.nii.gz \
	--interpolation NearestNeighbor \
	--output ${OutputDir}/sub-${s}/ses-Loc/Group_to_nativeV1.nii.gz \
	--transform /home/despoB/TRSEPPI/TTD/fmriprep/work/fmriprep_wf/single_subject_${s}_wf/anat_preproc_wf/t1_2_mni/ants_t1_to_mniInverseComposite.h5
	
	#--transform [/home/despoB/TRSEPPI/TTD/fmriprep/work/fmriprep_wf/single_subject_${s}_wf/func_preproc_ses_Loc_task_TDD_run_001_wf/epi_reg_wf/fsl2itk_fwd/affine.txt, 1] \


	#create FFA PPA masks
	for model in FIR SPMG; do
		3dTcat -prefix ${OutputDir}/sub-${s}/ses-Loc/face_v_house_${model}tstat ${OutputDir}/sub-${s}/ses-Loc/Localizer_${model}model_stats+orig[3]
		3dcalc \
		-a ${OutputDir}/sub-${s}/ses-Loc/face_v_house_${model}tstat+orig \
		-b ${OutputDir}/sub-${s}/ses-Loc/Group_to_nativeFFA.nii.gz \
		-expr 'ispositive(a*b)' -short \
		-prefix ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz

		3dmaskdump -mask ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz -quiet \
		${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz | sort -k4 -n -r | head -n 255 | \
		3dUndump -master ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz -ijk \
		-prefix ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROI${model}.nii.gz stdin

		3dcalc \
		-a ${OutputDir}/sub-${s}/ses-Loc/face_v_house_${model}tstat+orig \
		-b ${OutputDir}/sub-${s}/ses-Loc/Group_to_nativePPA.nii.gz \
		-expr 'isnegative(a*b)' -short \
		-prefix ${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz

		3dmaskdump -mask ${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz -quiet \
		${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz | sort -k4 -n -r | head -n 255 | \
		3dUndump -master ${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz -ijk \
		-prefix ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROI${model}.nii.gz stdin
	
		#create V1 mask 
		3dmaskdump -mask ${OutputDir}/sub-${s}/ses-Loc/Group_to_nativeV1.nii.gz -quiet \
		${OutputDir}/sub-${s}/ses-Loc/Localizer_${model}model_stats+orig[1] | sort -k4 -n -r | head -n 1 | \
		3dUndump -master ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz -srad 8 -ijk -prefix ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROI${model}.nii.gz stdin
	done

done
#
