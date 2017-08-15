#!/bin/bash
# script to run FIR model for each condition. For localization FFA/PPA
export DISPLAY=""

WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/ScanLogs'
OutputDir='/home/despoB/kaihwang/TRSE/TTD/Results'
#SUB_ID="${SGE_TASK}";

for s in ${SUB_ID}; do

	echo "running FIR localizer model for subject $SUB_ID, session $session"
	
	if [ ! -d ${OutputDir}/sub-${s}/ses-${session} ]; then
		mkdir ${OutputDir}/sub-${s}/
		mkdir ${OutputDir}/sub-${s}/ses-${session}
	fi

	#additional preproc
	for run in $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-*_space-T1w_preproc.nii.gz | grep -o 'run-[[:digit:]][[:digit:]][[:digit:]]'  | grep -o "[[:digit:]][[:digit:]][[:digit:]]"); do
		if [ ! -e ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_smoothed_scaled_preproc.nii.gz ]; then
			#low amount of smooth
			3dBlurToFWHM -input ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_preproc.nii.gz \
			-prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_smoothed_preproc.nii.gz \
			-FWHM 4		

			#scaling
			3dTstat -mean -prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_mean.nii.gz \
			${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_smoothed_preproc.nii.gz

			3dcalc \
			-a ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_smoothed_preproc.nii.gz \
			-b ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_mean.nii.gz \
			-c ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_brainmask.nii.gz\
			-expr "(a/b * 100) * c" \
			-prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_smoothed_scaled_preproc.nii.gz

			#remove not needed files
			rm ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_mean.nii.gz
			rm ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-T1w_smoothed_preproc.nii.gz
		fi
	done
	
	#get T1 link
	if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/Native_T1.nii.gz ]; then
		mri_convert /home/despoB/kaihwang/TRSE/TTD/fmriprep/freesurfer/sub-${s}/mri/T1.mgz ${OutputDir}/sub-${s}/ses-${session}/Native_T1.nii.gz
	fi	
	fslreorient2std ${OutputDir}/sub-${s}/ses-${session}/Native_T1.nii.gz ${OutputDir}/sub-${s}/ses-${session}/Native_T1.nii.gz

	#create union mask
	if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/union_mask.nii.gz ]; then
		3dMean -count -prefix ${OutputDir}/sub-${s}/ses-${session}/union_mask.nii.gz ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/*task-TDD*T1w_brainmask.nii.gz
	fi

	#concat nuisance regressors
	#this is the confound variables. we need the last six (13-24)
	# WhiteMatter	GlobalSignal	stdDVARS	non-stdDVARS	vx-wisestdDVARS	FramewiseDisplacement	
	# tCompCor00	tCompCor01	tCompCor02	tCompCor03	tCompCor04	tCompCor05
	# aCompCor00	aCompCor01	aCompCor02	aCompCor03	aCompCor04	aCompCor05	X	Y	Z	RotX	RotY	RotZ
	echo "" > ${OutputDir}/sub-${s}/ses-${session}/confounds.tsv
	echo "" > ${OutputDir}/sub-${s}/ses-${session}/motion.tsv
	echo "" > ${OutputDir}/sub-${s}/ses-${session}/gsr.tsv
	for f in $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run*confounds.tsv | sort -V); do
		cat ${f} | tail -n+2 | cut -f13-24 >> ${OutputDir}/sub-${s}/ses-${session}/confounds.tsv
		cat ${f} | tail -n+2 | cut -f19-24 >> ${OutputDir}/sub-${s}/ses-${session}/motion.tsv
		cat ${f} | tail -n+2 | cut -f1 >> ${OutputDir}/sub-${s}/ses-${session}/gsr.tsv
	done

	#create censor
	nruns=$(/bin/ls ${WD}/fmriprep/fmriprep/sub-${SUB_ID}/ses-${session}/func/*task-TDD*T1w_preproc.nii.gz | wc -l)
	1d_tool.py -infile ${OutputDir}/sub-${s}/ses-${session}/motion.tsv \
	-set_nruns ${nruns} -show_censor_count -censor_motion 0.2 ${OutputDir}/sub-${s}/ses-${session}/FD0.2 -censor_prev_TR -overwrite

	#FD0.2_enorm.1D is AFNI's FD
	1dcat ${OutputDir}/sub-${s}/ses-${session}/confounds.tsv ${OutputDir}/sub-${s}/ses-${session}/FD0.2_enorm.1D ${OutputDir}/sub-${s}/ses-${session}/gsr.tsv > ${OutputDir}/sub-${s}/ses-${session}/nuisance.tsv

	#run localizer Model
	#FIR model
	if [ ${session} = Loc ]; then
		if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz ]; then
			3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-0*_bold_space-T1w_smoothed_scaled_preproc.nii.gz | sort -V) \
			-mask ${OutputDir}/sub-${s}/ses-${session}/union_mask.nii.gz \
			-polort A \
			-num_stimts 6 \
			-censor ${OutputDir}/sub-${s}/ses-${session}/FD0.2_censor.1D \
			-ortvec ${OutputDir}/sub-${s}/ses-${session}/nuisance.tsv confounds \
			-stim_times 1 ${SCRIPTS}/${s}_${session}_FH_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 1 FH \
			-stim_times 2 ${SCRIPTS}/${s}_${session}_HF_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 2 HF \
			-stim_times 3 ${SCRIPTS}/${s}_${session}_Fp_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 3 Fp \
			-stim_times 4 ${SCRIPTS}/${s}_${session}_Hp_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 4 Hp \
			-stim_times 5 ${SCRIPTS}/${s}_${session}_F2_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 5 F2 \
			-stim_times 6 ${SCRIPTS}/${s}_${session}_H2_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 6 H2 \
			-iresp 1 ${OutputDir}/sub-${s}/ses-${session}/Localizer_FH_FIR.nii.gz \
			-iresp 2 ${OutputDir}/sub-${s}/ses-${session}/Localizer_HF_FIR.nii.gz \
			-iresp 3 ${OutputDir}/sub-${s}/ses-${session}/Localizer_Fp_FIR.nii.gz \
			-iresp 4 ${OutputDir}/sub-${s}/ses-${session}/Localizer_Hp_FIR.nii.gz \
			-iresp 5 ${OutputDir}/sub-${s}/ses-${session}/Localizer_F2_FIR.nii.gz \
			-iresp 6 ${OutputDir}/sub-${s}/ses-${session}/Localizer_H2_FIR.nii.gz \
			-gltsym 'SYM: +1*Fp[3..7] -1*Hp[3..7] ' -glt_label 1 F-H \
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
			-bucket ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIRmodel_stats.nii.gz \
			-GOFORIT 100 \
			-noFDR \
			-nocout \
			-errts ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz \
			-allzero_OK	-jobs 4
		fi
	fi

	if [ ${session} != Loc ]; then
		if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz ]; then
			3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-0*_bold_space-T1w_smoothed_scaled_preproc.nii.gz | sort -V) \
			-mask ${OutputDir}/sub-${s}/ses-${session}/union_mask.nii.gz \
			-polort A \
			-num_stimts 4 \
			-censor ${OutputDir}/sub-${s}/ses-${session}/FD0.2_censor.1D \
			-ortvec ${OutputDir}/sub-${s}/ses-${session}/nuisance.tsv confounds \
			-stim_times 1 ${SCRIPTS}/${s}_${session}_FH_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 1 FH \
			-stim_times 2 ${SCRIPTS}/${s}_${session}_HF_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 2 HF \
			-stim_times 3 ${SCRIPTS}/${s}_${session}_F2_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 3 F2 \
			-stim_times 4 ${SCRIPTS}/${s}_${session}_H2_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 4 H2 \
			-iresp 1 ${OutputDir}/sub-${s}/ses-${session}/Localizer_FH_FIR.nii.gz \
			-iresp 2 ${OutputDir}/sub-${s}/ses-${session}/Localizer_HF_FIR.nii.gz \
			-iresp 3 ${OutputDir}/sub-${s}/ses-${session}/Localizer_F2_FIR.nii.gz \
			-iresp 4 ${OutputDir}/sub-${s}/ses-${session}/Localizer_H2_FIR.nii.gz \
			-gltsym 'SYM: +1*F2 +1*H2 -1*FH -1*HF ' -glt_label 3 2B-TD \
			-gltsym 'SYM: +0.5*F2 +0.5*H2 ' -glt_label 5 2B \
			-gltsym 'SYM: +0.5*FH +0.5*HF ' -glt_label 6 TD \
			-rout \
			-tout \
			-bucket ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIRmodel_stats.nii.gz \
			-GOFORIT 100 \
			-noFDR \
			-nocout \
			-errts ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz \
			-allzero_OK	-jobs 4
		fi
	fi

	
	#Reverse normalize Group FFA PPA V1 mask
	if [ $session = Loc ]; then
		if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/Group_to_native_ventral_Anatomicals.nii.gz ]; then
			antsApplyTransforms --default-value 0 --float 1 \
			--reference-image ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-001_bold_space-T1w_brainmask.nii.gz \
			--input /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/Ventral_anatomical_ROI.nii.gz \
			--interpolation NearestNeighbor \
			--output ${OutputDir}/sub-${s}/ses-${session}/Group_to_native_ventral_Anatomicals.nii.gz \
			--transform /home/despoB/TRSEPPI/TTD/fmriprep/work/fmriprep_wf/single_subject_${s}_wf/anat_preproc_wf/t1_2_mni/ants_t1_to_mniInverseComposite.h5
		fi
	fi
	
	if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/Group_to_nativeV1.nii.gz ]; then
		antsApplyTransforms --default-value 0 --float 1 \
		--reference-image ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-001_bold_space-T1w_brainmask.nii.gz \
		--input /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/Group_V1.nii.gz \
		--interpolation NearestNeighbor \
		--output ${OutputDir}/sub-${s}/ses-${session}/Group_to_nativeV1.nii.gz \
		--transform /home/despoB/TRSEPPI/TTD/fmriprep/work/fmriprep_wf/single_subject_${s}_wf/anat_preproc_wf/t1_2_mni/ants_t1_to_mniInverseComposite.h5
	fi

	#--transform [/home/despoB/TRSEPPI/TTD/fmriprep/work/fmriprep_wf/single_subject_${s}_wf/func_preproc_ses_Loc_task_TDD_run_001_wf/epi_reg_wf/fsl2itk_fwd/affine.txt, 1] \

	#create FFA PPA masks for localizer session
	if [ $session = Loc ]; then
		for model in FIR; do
			
			if [ ! -e ${OutputDir}/sub-${s}/ses-Loc/face_v_house_${model}tstat+orig.HEAD ]; then
				3dTcat -prefix ${OutputDir}/sub-${s}/ses-Loc/face_v_house_${model}tstat ${OutputDir}/sub-${s}/ses-Loc/Localizer_${model}model_stats.nii.gz[3]
			fi

			if [ ! -e ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROI${model}.nii.gz ]; then
				#rm ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz
				3dcalc \
				-a ${OutputDir}/sub-${s}/ses-Loc/face_v_house_${model}tstat+orig \
				-b ${OutputDir}/sub-${s}/ses-Loc/Group_to_native_ventral_Anatomicals.nii.gz \
				-expr 'ispositive(a*b)*a' -short \
				-prefix ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz

				#rm ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROI${model}.nii.gz
				3dmaskdump -mask ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz -quiet \
				${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz | sort -k4 -n -r | head -n 1 | \
				3dUndump -master ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz -srad 8 -ijk \
				-prefix ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROI${model}.nii.gz stdin
			fi

			if [ ! -e ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROI${model}.nii.gz ]; then
				#rm ${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz
				3dcalc \
				-a ${OutputDir}/sub-${s}/ses-Loc/face_v_house_${model}tstat+orig \
				-b ${OutputDir}/sub-${s}/ses-Loc/Group_to_native_ventral_Anatomicals.nii.gz \
				-expr 'isnegative(a*b)*a*(-1)' -short \
				-prefix ${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz

				#rm ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROI${model}.nii.gz
				3dmaskdump -mask ${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz -quiet \
				${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz | sort -k4 -n -r | head -n 1 | \
				3dUndump -master ${OutputDir}/sub-${s}/ses-Loc/PPAmasked${model}.nii.gz -srad 8 -ijk \
				-prefix ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROI${model}.nii.gz stdin
			fi
			
			#create V1 mask 

			if [ ! -e ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROI${model}.nii.gz ]; then
				#rm ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROI${model}.nii.gz
				3dmaskdump -mask ${OutputDir}/sub-${s}/ses-Loc/Group_to_nativeV1.nii.gz -quiet \
				${OutputDir}/sub-${s}/ses-Loc/Localizer_${model}model_stats.nii.gz[1] | sort -k4 -n -r | head -n 1 | \
				3dUndump -master ${OutputDir}/sub-${s}/ses-Loc/FFAmasked${model}.nii.gz -srad 8 -ijk \
				-prefix ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROI${model}.nii.gz stdin
			fi
			
		done
	fi

done

