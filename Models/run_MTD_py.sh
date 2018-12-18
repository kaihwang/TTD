#!/bin/bash
# script to run MTD regression model


WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/ScanLogs'
OutputDir='/home/despoB/kaihwang/TRSE/TTD/Results'
Model='/home/despoB/kaihwang/bin/TTD/Models'


for window in 5 10 15 20; do
		
	for s in 7003; do	#7003 7004 7006 7008 7009 7012 7014 7016 7017 7018 7019
		#create MTD and BC regressors, use ${Model}/create_MTD_regressor.py
		# the input to that python script is n_runs, ntp_per_run, window, subject, ses, ffa_path, ppa_path, v1_path
	
		for session in Loc; do  #Ips S1


			#if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ts.1D ]; then
			#3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROIFIR.nii.gz -q \
			#${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ts.1D
			#fi
			
			#if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ts.1D ]; then
			#3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROIFIR.nii.gz -q \
			#${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ts.1D
			#fi	
			
			#if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_tng_s.1D ]; then
			#3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROIFIR.nii.gz -q \
			#${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_ts.1D
			#fi
			
			for ROI in V1 FFA PPA ; do #V1v V1d V2v V2d V3v V3d V3a V4v

				#3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR.nii.gz -q \
				#${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_ts.1D

				3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR_MNI.nii.gz -q \
				${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_w${window}_ts.1D

			done

			for ROI in V1v V1d V2v V2d V3v V3d V3a V4v ; do #V1v V1d V2v V2d V3v V3d V3a V4v

				#3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR.nii.gz -q \
				#${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_ts.1D

				3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR.nii.gz -q \
				${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_w${window}_ts.1D

			done


			n_runs=$(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-0*_bold_space-T1w_smoothed_scaled_preproc.nii.gz | wc -l)
			ntp_per_run=$(3dinfo ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-001_bold_space-T1w_smoothed_scaled_preproc.nii.gz | grep -o "time steps = [[:digit:]][[:digit:]][[:digit:]] " | grep -o [[:digit:]][[:digit:]][[:digit:]])
			#window=${w} #smoothing window for MTD
			ffa_path="${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_w${window}_ts.1D"
			ppa_path="${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_w${window}_ts.1D"
			
			for ROI in V1 V1d V1v V2d V2v V3d V3v V3a V4v; do
				vc_path="${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_w{window}_ts.1D"
				echo "${n_runs} ${ntp_per_run} ${window} ${s} ${session} ${ffa_path} ${ppa_path} ${vc_path} ${ROI}" | python ${Model}/create_MTD_regressors.py
			done

		done	
	done
done