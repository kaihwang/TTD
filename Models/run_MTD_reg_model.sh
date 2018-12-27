#!/bin/bash
# script to run MTD regression model
export DISPLAY=""

WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/ScanLogs'
OutputDir='/home/despoB/kaihwang/TRSE/TTD/Results'
Model='/home/despoB/kaihwang/bin/TTD/Models'
#SUB_ID="${SGE_TASK}";
#SUB_ID=7002
#session=Ips
jobN=2

echo "running MTD regression model for subject ${SUB_ID}, session ${session}"

for s in ${SUB_ID}; do

	#Create folder
	if [ ! -d ${OutputDir}/sub-${s}/ ]; then
		mkdir ${OutputDir}/sub-${s}/
	fi

	if [ ! -d ${OutputDir}/sub-${s}/ses-${session} ]; then	
		mkdir ${OutputDir}/sub-${s}/ses-${session}
	fi

	#create union mask
	if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/union_mask.nii.gz ]; then
		3dMean -count -prefix ${OutputDir}/sub-${s}/ses-${session}/union_mask.nii.gz ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/*task-TDD*T1w_brainmask.nii.gz
	fi	
	

	### Now TS extraction are done somewhere else.
	#extract TS
	# if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ts.1D ]; then
	# 3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROIFIR.nii.gz -q \
	# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ts.1D
	# fi
	
	# if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ts.1D ]; then
	# 3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROIFIR.nii.gz -q \
	# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ts.1D
	# fi	
	
	# if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_ts.1D ]; then
	# 3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROIFIR.nii.gz -q \
	# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_ts.1D
	# fi

	# if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ng_ts.1D ]; then
	# 3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/FFA_indiv_ROIFIR.nii.gz -q \
	# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_ng_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ng_ts.1D
	# fi
	
	# if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ng_ts.1D ]; then
	# 3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/PPA_indiv_ROIFIR.nii.gz -q \
	# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_ng_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ng_ts.1D
	# fi	
	
	# if [ ! -s ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_tng_s.1D ]; then
	# 3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/V1_indiv_ROIFIR.nii.gz -q \
	# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_ng_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/V1_allruns_ng_ts.1D
	# fi
	
	# for ROI in V1 FFA PPA V1v V1d V2v V2d V3v V3d V3a V4v; do

	# 	3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR.nii.gz -q \
	# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_ts.1D

	# 	#3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR.nii.gz -q \
	# 	#${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_ng_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_ng_ts.1D

	# done

	for w in 15; do #5 10 15 20
		
		
		#create MTD and BC regressors, use ${Model}/create_MTD_regressor.py
		# the input to that python script is n_runs, ntp_per_run, window, subject, ses, ffa_path, ppa_path, v1_path
		
		# now done somewhere else
		# n_runs=$(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-0*_bold_space-T1w_smoothed_scaled_preproc.nii.gz | wc -l)
		# ntp_per_run=$(3dinfo ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-001_bold_space-T1w_smoothed_scaled_preproc.nii.gz | grep -o "time steps = [[:digit:]][[:digit:]][[:digit:]] " | grep -o [[:digit:]][[:digit:]][[:digit:]])
		# window=${w} #smoothing window for MTD
		# ffa_path="${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ts.1D"
		# ppa_path="${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ts.1D"
		
		# for ROI in V1 V1d V1v V2d V2v V3d V3v V3a V4v; do
		# 	vc_path="${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_ts.1D"
		# 	echo "${n_runs} ${ntp_per_run} ${window} ${s} ${session} ${ffa_path} ${ppa_path} ${vc_path} ${ROI}" | python ${Model}/create_MTD_regressors.py
		# done

		# ffa_path="${OutputDir}/sub-${s}/ses-${session}/FFA_allruns_ng_ts.1D"
		# ppa_path="${OutputDir}/sub-${s}/ses-${session}/PPA_allruns_ng_ts.1D"
		
		# for ROI in V1 V1d V1v V2d V2v V3d V3v V3a V4v; do
		# 	vc_path="${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_ng_ts.1D"
		# 	echo "${n_runs} ${ntp_per_run} ${window} ${s} ${session} ${ffa_path} ${ppa_path} ${vc_path} ${ROI}" | python ${Model}/create_MTD_regressors.py
		# done
			
		# run big model!
		if [ ${session} = Loc ]; then

			#rm ${OutputDir}/sub-${s}/ses-${session}/GLTresults_w${w}*
			#rm ${OutputDir}/sub-${s}/ses-${session}/MTD*

			#first do MTD regression in native space
			if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}+orig.HEAD ]; then

				3dDeconvolve \
				-input ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz \
				-mask ${OutputDir}/sub-${s}/ses-${session}/union_mask.nii.gz \
				-num_stimts 30 \
				-stim_file 1 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_MTD_w${w}_FFA-V1.1D -stim_label 1 MTD_FH_FFA-VC \
				-stim_file 2 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_MTD_w${w}_PPA-V1.1D -stim_label 2 MTD_FH_PPA-VC \
				-stim_file 3 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_MTD_w${w}_FFA-V1.1D -stim_label 3 MTD_HF_FFA-VC \
				-stim_file 4 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_MTD_w${w}_PPA-V1.1D -stim_label 4 MTD_HF_PPA-VC \
				-stim_file 5 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_MTD_w${w}_FFA-V1.1D -stim_label 5 MTD_Hp_FFA-VC \
				-stim_file 6 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_MTD_w${w}_PPA-V1.1D -stim_label 6 MTD_Hp_PPA-VC \
				-stim_file 7 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_MTD_w${w}_FFA-V1.1D -stim_label 7 MTD_Fp_FFA-VC \
				-stim_file 8 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_MTD_w${w}_PPA-V1.1D -stim_label 8 MTD_Fp_PPA-VC \
				-stim_file 9 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_MTD_w${w}_FFA-V1.1D -stim_label 9 MTD_H2_FFA-VC \
				-stim_file 10 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_MTD_w${w}_PPA-V1.1D -stim_label 10 MTD_H2_PPA-VC \
				-stim_file 11 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_MTD_w${w}_FFA-V1.1D -stim_label 11 MTD_F2_FFA-VC \
				-stim_file 12 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_MTD_w${w}_PPA-V1.1D -stim_label 12 MTD_F2_PPA-VC \
				-stim_file 13 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_FFA.1D -stim_label 13 BC_FH_FFA \
				-stim_file 14 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_PPA.1D -stim_label 14 BC_FH_PPA \
				-stim_file 15 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_FFA.1D -stim_label 15 BC_HF_FFA \
				-stim_file 16 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_PPA.1D -stim_label 16 BC_HF_PPA \
				-stim_file 17 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_BC_FFA.1D -stim_label 17 BC_Hp_FFA \
				-stim_file 18 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_BC_PPA.1D -stim_label 18 BC_Hp_PPA \
				-stim_file 19 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_BC_FFA.1D -stim_label 19 BC_Fp_FFA \
				-stim_file 20 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_BC_PPA.1D -stim_label 20 BC_Fp_PPA \
				-stim_file 21 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_FFA.1D -stim_label 21 BC_F2_FFA \
				-stim_file 22 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_PPA.1D -stim_label 22 BC_F2_PPA \
				-stim_file 23 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_FFA.1D -stim_label 23 BC_H2_FFA \
				-stim_file 24 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_PPA.1D -stim_label 24 BC_H2_PPA \
				-stim_file 25 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_V1.1D -stim_label 25 BC_FH_VC \
				-stim_file 26 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_V1.1D -stim_label 26 BC_HF_VC \
				-stim_file 27 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_BC_V1.1D -stim_label 27 BC_Fp_VC \
				-stim_file 28 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_BC_V1.1D -stim_label 28 BC_Hp_VC \
				-stim_file 29 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_V1.1D -stim_label 29 BC_H2_VC \
				-stim_file 30 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_V1.1D -stim_label 30 BC_F2_VC \
				-num_glt 34 \
				-gltsym 'SYM: +0.5*MTD_FH_FFA-VC +0.5*MTD_HF_PPA-VC' -glt_label 1 MTD_Target_1bk \
				-gltsym 'SYM: +0.5*MTD_HF_FFA-VC +0.5*MTD_FH_PPA-VC' -glt_label 2 MTD_Distractor_1bk \
				-gltsym 'SYM: +0.5*MTD_Fp_FFA-VC +0.5*MTD_Hp_PPA-VC' -glt_label 3 MTD_Target_categorize \
				-gltsym 'SYM: +0.5*MTD_Hp_FFA-VC +0.5*MTD_Fp_PPA-VC' -glt_label 4 MTD_Distractor_categorize \
				-gltsym 'SYM: +0.5*MTD_F2_FFA-VC +0.5*MTD_H2_PPA-VC' -glt_label 5 MTD_Target_2bk \
				-gltsym 'SYM: +0.5*MTD_H2_FFA-VC +0.5*MTD_F2_PPA-VC' -glt_label 6 MTD_Distractor_2bk \
				-gltsym 'SYM: +1*MTD_FH_FFA-VC +1*MTD_HF_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 7 MTD_Target_1bk-categorize \
				-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 8 MTD_Target_2bk-categorize \
				-gltsym 'SYM: +1*MTD_HF_FFA-VC +1*MTD_FH_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 9 MTD_Distractor_1bk-categorize \
				-gltsym 'SYM: +1*MTD_H2_FFA-VC +1*MTD_F2_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 10 MTD_Distractor_2bk-categorize \
				-gltsym 'SYM: +1*MTD_FH_FFA-VC +1*MTD_HF_PPA-VC -1*MTD_HF_FFA-VC -1*MTD_FH_PPA-VC' -glt_label 11 MTD_1bk_Target-Distractor \
				-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_H2_FFA-VC -1*MTD_F2_PPA-VC' -glt_label 12 MTD_2bk_Target-Distractor \
				-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_FH_FFA-VC -1*MTD_HF_PPA-VC' -glt_label 13 MTD_Target_2bk-1bk \
				-gltsym 'SYM: +1*MTD_H2_FFA-VC +1*MTD_F2_PPA-VC -1*MTD_HF_FFA-VC -1*MTD_FH_PPA-VC' -glt_label 14 MTD_Distractor_2bk-1bk \
				-gltsym 'SYM: +0.5*BC_FH_FFA +0.5*BC_HF_PPA' -glt_label 15 BC_Target_1bk \
				-gltsym 'SYM: +0.5*BC_HF_FFA +0.5*BC_FH_PPA' -glt_label 16 BC_Distractor_1bk \
				-gltsym 'SYM: +0.5*BC_Fp_FFA +0.5*BC_Hp_PPA' -glt_label 17 BC_Target_categorize \
				-gltsym 'SYM: +0.5*BC_Hp_FFA +0.5*BC_Fp_PPA' -glt_label 18 BC_Distractor_categorize \
				-gltsym 'SYM: +0.5*BC_F2_FFA +0.5*BC_H2_PPA' -glt_label 19 BC_Target_2bk \
				-gltsym 'SYM: +0.5*BC_H2_FFA +0.5*BC_F2_PPA' -glt_label 20 BC_Distractor_2bk \
				-gltsym 'SYM: +1*BC_FH_FFA +1*BC_HF_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 21 BC_Target_1bk-categorize \
				-gltsym 'SYM: +1*BC_HF_FFA +1*BC_FH_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 22 BC_Distractor_1bk-categorize \
				-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 23 BC_Target_2bk-categorize \
				-gltsym 'SYM: +1*BC_H2_FFA +1*BC_F2_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 24 BC_Distractor_2bk-categorize \
				-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_FH_FFA -1*BC_HF_PPA' -glt_label 25 BC_Target_2bk-1bk \
				-gltsym 'SYM: +1*BC_H2_FFA +1*BC_F2_PPA -1*BC_HF_FFA -1*BC_FH_PPA' -glt_label 26 BC_Distractor_2bk-1bk \
				-gltsym 'SYM: +1*BC_FH_FFA +1*BC_HF_PPA -1*BC_HF_FFA -1*BC_FH_PPA' -glt_label 27 BC_1bk_Target-Distractor \
				-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_H2_FFA -1*BC_F2_PPA' -glt_label 28 BC_2bk_Target-Distractor \
				-gltsym 'SYM: +1*BC_FH_VC +1*BC_HF_VC -1*BC_Fp_VC -1*BC_Hp_VC' -glt_label 29 BC_1bk-categorize_VC \
				-gltsym 'SYM: +1*BC_F2_VC +1*BC_H2_VC -1*BC_Fp_VC -1*BC_Hp_VC' -glt_label 30 BC_2bk-categorize_VC \
				-gltsym 'SYM: +1*BC_F2_VC +1*BC_H2_VC -1*BC_FH_VC -1*BC_HF_VC' -glt_label 31 BC_2bk-1bk_VC \
				-gltsym 'SYM: +0.5*BC_FH_VC +0.5*BC_HF_VC' -glt_label 32 BC_1bk_VC \
				-gltsym 'SYM: +0.5*BC_F2_VC +0.5*BC_H2_VC' -glt_label 33 BC_2bk_VC \
				-gltsym 'SYM: +0.5*BC_Fp_VC +0.5*BC_Hp_VC' -glt_label 34 BC_categorize_VC \
				-tout \
				-nocout \
				-bucket ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w} \
				-GOFORIT 100 \
				-noFDR -jobs ${jobN}
				#-fout \
				#-rout \

				#results from 3dREMLfit cannot be saved into AFNI format or header info will be lost
				. ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}.REML_cmd
				#3dTcat -prefix ${OutputDir}/sub-${s}/ses-${session}/GLTresults_w${w} ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}_REML+orig[61..128]
			fi	

			# then do MTD regression in MNI space
			if [ ! -e ${OutputDir}/sub-${s}/ses-${session}//MTD_BC_stats_w${w}_MNI_${ROI}+tlrc.HEAD ]; then

				#preproc in MNI space
				for run in $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-*_space-MNI152NLin2009cAsym_preproc.nii.gz | grep -o 'run-[[:digit:]][[:digit:]][[:digit:]]'  | grep -o "[[:digit:]][[:digit:]][[:digit:]]"); do
					if [ ! -e ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_scaled_preproc.nii.gz ]; then
						#low amount of smooth
						3dBlurToFWHM -input ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_preproc.nii.gz \
						-prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz \
						-FWHM 4		

						#scaling
						3dTstat -mean -prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_mean.nii.gz \
						${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz

						3dcalc \
						-a ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz \
						-b ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_mean.nii.gz \
						-c ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz\
						-expr "(a/b * 100) * c" \
						-prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_scaled_preproc.nii.gz

						#remove not needed files
						rm ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_mean.nii.gz
						rm ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz
					fi
				done

				#create union mask in MNI space
				if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz ]; then
					3dMean -count -prefix ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/*task-TDD*MNI152NLin2009cAsym_brainmask.nii.gz
				fi

				#FIR regression in MNI space, save risiduals
				if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz ]; then
					3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-0*_bold_space-MNI152NLin2009cAsym_smoothed_scaled_preproc.nii.gz | sort -V) \
					-mask ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz \
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
					-iresp 1 ${OutputDir}/sub-${s}/ses-${session}/Localizer_FH_MNI_FIR.nii.gz \
					-iresp 2 ${OutputDir}/sub-${s}/ses-${session}/Localizer_HF_MNI_FIR.nii.gz \
					-iresp 3 ${OutputDir}/sub-${s}/ses-${session}/Localizer_Fp_MNI_FIR.nii.gz \
					-iresp 4 ${OutputDir}/sub-${s}/ses-${session}/Localizer_Hp_MNI_FIR.nii.gz \
					-iresp 5 ${OutputDir}/sub-${s}/ses-${session}/Localizer_F2_MNI_FIR.nii.gz \
					-iresp 6 ${OutputDir}/sub-${s}/ses-${session}/Localizer_H2_MNI_FIR.nii.gz \
					-gltsym 'SYM: +1*Fp[2..7] -1*Hp[2..7] ' -glt_label 1 F-H \
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
					-bucket ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIRmodel_MNI_stats.nii.gz \
					-GOFORIT 100 \
					-noFDR \
					-nocout \
					-errts ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz \
					-allzero_OK	-jobs 4
				fi




				#do MTD
				for ROI in V1 ; do  #V1d V1v V2d V2v V3d V3v V3a V4v

					3dDeconvolve \
					-input ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz \
					-mask ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz \
					-num_stimts 30 \
					-stim_file 1 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_MTD_w${w}_FFA-${ROI}.1D -stim_label 1 MTD_FH_FFA-VC \
					-stim_file 2 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_MTD_w${w}_PPA-${ROI}.1D -stim_label 2 MTD_FH_PPA-VC \
					-stim_file 3 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_MTD_w${w}_FFA-${ROI}.1D -stim_label 3 MTD_HF_FFA-VC \
					-stim_file 4 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_MTD_w${w}_PPA-${ROI}.1D -stim_label 4 MTD_HF_PPA-VC \
					-stim_file 5 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_MTD_w${w}_FFA-${ROI}.1D -stim_label 5 MTD_Hp_FFA-VC \
					-stim_file 6 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_MTD_w${w}_PPA-${ROI}.1D -stim_label 6 MTD_Hp_PPA-VC \
					-stim_file 7 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_MTD_w${w}_FFA-${ROI}.1D -stim_label 7 MTD_Fp_FFA-VC \
					-stim_file 8 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_MTD_w${w}_PPA-${ROI}.1D -stim_label 8 MTD_Fp_PPA-VC \
					-stim_file 9 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_MTD_w${w}_FFA-${ROI}.1D -stim_label 9 MTD_H2_FFA-VC \
					-stim_file 10 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_MTD_w${w}_PPA-${ROI}.1D -stim_label 10 MTD_H2_PPA-VC \
					-stim_file 11 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_MTD_w${w}_FFA-${ROI}.1D -stim_label 11 MTD_F2_FFA-VC \
					-stim_file 12 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_MTD_w${w}_PPA-${ROI}.1D -stim_label 12 MTD_F2_PPA-VC \
					-stim_file 13 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_FFA.1D -stim_label 13 BC_FH_FFA \
					-stim_file 14 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_PPA.1D -stim_label 14 BC_FH_PPA \
					-stim_file 15 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_FFA.1D -stim_label 15 BC_HF_FFA \
					-stim_file 16 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_PPA.1D -stim_label 16 BC_HF_PPA \
					-stim_file 17 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_BC_FFA.1D -stim_label 17 BC_Hp_FFA \
					-stim_file 18 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_BC_PPA.1D -stim_label 18 BC_Hp_PPA \
					-stim_file 19 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_BC_FFA.1D -stim_label 19 BC_Fp_FFA \
					-stim_file 20 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_BC_PPA.1D -stim_label 20 BC_Fp_PPA \
					-stim_file 21 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_FFA.1D -stim_label 21 BC_F2_FFA \
					-stim_file 22 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_PPA.1D -stim_label 22 BC_F2_PPA \
					-stim_file 23 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_FFA.1D -stim_label 23 BC_H2_FFA \
					-stim_file 24 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_PPA.1D -stim_label 24 BC_H2_PPA \
					-stim_file 25 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_${ROI}.1D -stim_label 25 BC_FH_VC \
					-stim_file 26 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_${ROI}.1D -stim_label 26 BC_HF_VC \
					-stim_file 27 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Fp_BC_${ROI}.1D -stim_label 27 BC_Fp_VC \
					-stim_file 28 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_Hp_BC_${ROI}.1D -stim_label 28 BC_Hp_VC \
					-stim_file 29 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_${ROI}.1D -stim_label 29 BC_H2_VC \
					-stim_file 30 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_${ROI}.1D -stim_label 30 BC_F2_VC \
					-num_glt 34 \
					-gltsym 'SYM: +0.5*MTD_FH_FFA-VC +0.5*MTD_HF_PPA-VC' -glt_label 1 MTD_Target_1bk \
					-gltsym 'SYM: +0.5*MTD_HF_FFA-VC +0.5*MTD_FH_PPA-VC' -glt_label 2 MTD_Distractor_1bk \
					-gltsym 'SYM: +0.5*MTD_Fp_FFA-VC +0.5*MTD_Hp_PPA-VC' -glt_label 3 MTD_Target_categorize \
					-gltsym 'SYM: +0.5*MTD_Hp_FFA-VC +0.5*MTD_Fp_PPA-VC' -glt_label 4 MTD_Distractor_categorize \
					-gltsym 'SYM: +0.5*MTD_F2_FFA-VC +0.5*MTD_H2_PPA-VC' -glt_label 5 MTD_Target_2bk \
					-gltsym 'SYM: +0.5*MTD_H2_FFA-VC +0.5*MTD_F2_PPA-VC' -glt_label 6 MTD_Distractor_2bk \
					-gltsym 'SYM: +1*MTD_FH_FFA-VC +1*MTD_HF_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 7 MTD_Target_1bk-categorize \
					-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 8 MTD_Target_2bk-categorize \
					-gltsym 'SYM: +1*MTD_HF_FFA-VC +1*MTD_FH_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 9 MTD_Distractor_1bk-categorize \
					-gltsym 'SYM: +1*MTD_H2_FFA-VC +1*MTD_F2_PPA-VC -1*MTD_Fp_FFA-VC -1*MTD_Hp_PPA-VC' -glt_label 10 MTD_Distractor_2bk-categorize \
					-gltsym 'SYM: +1*MTD_FH_FFA-VC +1*MTD_HF_PPA-VC -1*MTD_HF_FFA-VC -1*MTD_FH_PPA-VC' -glt_label 11 MTD_1bk_Target-Distractor \
					-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_H2_FFA-VC -1*MTD_F2_PPA-VC' -glt_label 12 MTD_2bk_Target-Distractor \
					-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_FH_FFA-VC -1*MTD_HF_PPA-VC' -glt_label 13 MTD_Target_2bk-1bk \
					-gltsym 'SYM: +1*MTD_H2_FFA-VC +1*MTD_F2_PPA-VC -1*MTD_HF_FFA-VC -1*MTD_FH_PPA-VC' -glt_label 14 MTD_Distractor_2bk-1bk \
					-gltsym 'SYM: +0.5*BC_FH_FFA +0.5*BC_HF_PPA' -glt_label 15 BC_Target_1bk \
					-gltsym 'SYM: +0.5*BC_HF_FFA +0.5*BC_FH_PPA' -glt_label 16 BC_Distractor_1bk \
					-gltsym 'SYM: +0.5*BC_Fp_FFA +0.5*BC_Hp_PPA' -glt_label 17 BC_Target_categorize \
					-gltsym 'SYM: +0.5*BC_Hp_FFA +0.5*BC_Fp_PPA' -glt_label 18 BC_Distractor_categorize \
					-gltsym 'SYM: +0.5*BC_F2_FFA +0.5*BC_H2_PPA' -glt_label 19 BC_Target_2bk \
					-gltsym 'SYM: +0.5*BC_H2_FFA +0.5*BC_F2_PPA' -glt_label 20 BC_Distractor_2bk \
					-gltsym 'SYM: +1*BC_FH_FFA +1*BC_HF_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 21 BC_Target_1bk-categorize \
					-gltsym 'SYM: +1*BC_HF_FFA +1*BC_FH_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 22 BC_Distractor_1bk-categorize \
					-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 23 BC_Target_2bk-categorize \
					-gltsym 'SYM: +1*BC_H2_FFA +1*BC_F2_PPA -1*BC_Fp_FFA -1*BC_Hp_PPA' -glt_label 24 BC_Distractor_2bk-categorize \
					-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_FH_FFA -1*BC_HF_PPA' -glt_label 25 BC_Target_2bk-1bk \
					-gltsym 'SYM: +1*BC_H2_FFA +1*BC_F2_PPA -1*BC_HF_FFA -1*BC_FH_PPA' -glt_label 26 BC_Distractor_2bk-1bk \
					-gltsym 'SYM: +1*BC_FH_FFA +1*BC_HF_PPA -1*BC_HF_FFA -1*BC_FH_PPA' -glt_label 27 BC_1bk_Target-Distractor \
					-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_H2_FFA -1*BC_F2_PPA' -glt_label 28 BC_2bk_Target-Distractor \
					-gltsym 'SYM: +1*BC_FH_VC +1*BC_HF_VC -1*BC_Fp_VC -1*BC_Hp_VC' -glt_label 29 BC_1bk-categorize_VC \
					-gltsym 'SYM: +1*BC_F2_VC +1*BC_H2_VC -1*BC_Fp_VC -1*BC_Hp_VC' -glt_label 30 BC_2bk-categorize_VC \
					-gltsym 'SYM: +1*BC_F2_VC +1*BC_H2_VC -1*BC_FH_VC -1*BC_HF_VC' -glt_label 31 BC_2bk-1bk_VC \
					-gltsym 'SYM: +0.5*BC_FH_VC +0.5*BC_HF_VC' -glt_label 32 BC_1bk_VC \
					-gltsym 'SYM: +0.5*BC_F2_VC +0.5*BC_H2_VC' -glt_label 33 BC_2bk_VC \
					-gltsym 'SYM: +0.5*BC_Fp_VC +0.5*BC_Hp_VC' -glt_label 34 BC_categorize_VC \
					-tout \
					-nocout \
					-bucket ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}_MNI_${ROI} \
					-GOFORIT 100 \
					-noFDR -jobs ${jobN}
					#-fout \
					#-rout \

					#results from 3dREMLfit cannot be saved into AFNI format or header info will be lost
					. ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}_MNI_${ROI}.REML_cmd
					#3dTcat -prefix ${OutputDir}/sub-${s}/ses-${session}/GLTresults_w${w}_MNI ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}_MNI_REML+orig[61..128]
				done
			fi	
		fi	

		if [ ${session} != Loc ]; then

			#rm ${OutputDir}/sub-${s}/ses-${session}/GLTresults*
			#rm ${OutputDir}/sub-${s}/ses-${session}/MTD*

			#preproc in MNI space
			for run in $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-*_space-MNI152NLin2009cAsym_preproc.nii.gz | grep -o 'run-[[:digit:]][[:digit:]][[:digit:]]'  | grep -o "[[:digit:]][[:digit:]][[:digit:]]"); do
				if [ ! -e ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_scaled_preproc.nii.gz ]; then
					#low amount of smooth
					3dBlurToFWHM -input ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_preproc.nii.gz \
					-prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz \
					-FWHM 4		

					#scaling
					3dTstat -mean -prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_mean.nii.gz \
					${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz

					3dcalc \
					-a ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz \
					-b ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_mean.nii.gz \
					-c ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_brainmask.nii.gz\
					-expr "(a/b * 100) * c" \
					-prefix ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_scaled_preproc.nii.gz

					#remove not needed files
					rm ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_mean.nii.gz
					rm ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-${run}_bold_space-MNI152NLin2009cAsym_smoothed_preproc.nii.gz
				fi
			done

			#create union mask in MNI space
			if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz ]; then
				3dMean -count -prefix ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/*task-TDD*MNI152NLin2009cAsym_brainmask.nii.gz
			fi

			#FIR regression in MNI space, save risiduals
			if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz ]; then
				3dDeconvolve -input $(/bin/ls ${WD}/fmriprep/fmriprep/sub-${s}/ses-${session}/func/sub-${s}_ses-${session}_task-TDD_run-0*_bold_space-MNI152NLin2009cAsym_smoothed_scaled_preproc.nii.gz | sort -V) \
				-mask ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz \
				-polort A \
				-num_stimts 4 \
				-censor ${OutputDir}/sub-${s}/ses-${session}/FD0.2_censor.1D \
				-ortvec ${OutputDir}/sub-${s}/ses-${session}/nuisance.tsv confounds \
				-stim_times 1 ${SCRIPTS}/${s}_${session}_FH_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 1 FH \
				-stim_times 2 ${SCRIPTS}/${s}_${session}_HF_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 2 HF \
				-stim_times 5 ${SCRIPTS}/${s}_${session}_F2_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 3 F2 \
				-stim_times 6 ${SCRIPTS}/${s}_${session}_H2_stimtime.1D 'TENT(-1, 12, 14)' -stim_label 4 H2 \
				-iresp 1 ${OutputDir}/sub-${s}/ses-${session}/Localizer_FH_MNI_FIR.nii.gz \
				-iresp 2 ${OutputDir}/sub-${s}/ses-${session}/Localizer_HF_MNI_FIR.nii.gz \
				-iresp 3 ${OutputDir}/sub-${s}/ses-${session}/Localizer_F2_MNI_FIR.nii.gz \
				-iresp 4 ${OutputDir}/sub-${s}/ses-${session}/Localizer_H2_MNI_FIR.nii.gz \
				-gltsym 'SYM: +1*FH[2..7] +1*F2[2..7] -1*HF[2..7] -1*H2[2..7]' -glt_label 1 F-H \
				-gltsym 'SYM: +1*F2 +1*H2 -1*FH -1*HF ' -glt_label 2 2B-TD \
				-gltsym 'SYM: +0.5*F2 +0.5*H2 ' -glt_label 3 2B \
				-gltsym 'SYM: +0.5*FH +0.5*HF ' -glt_label 4 TD \
				-rout \
				-tout \
				-bucket ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIRmodel_MNI_stats.nii.gz \
				-GOFORIT 100 \
				-noFDR \
				-nocout \
				-errts ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz \
				-allzero_OK	-jobs ${jobN}
			fi

			
			# do MTD reg in MNI space for non Loc sessions
			if [ ! -e ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}_MNI+orig.HEAD ]; then


				for ROI in V1 FFA PPA ; do #V1v V1d V2v V2d V3v V3d V3a V4v

					3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR_MNI.nii.gz -q \
					${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_w${w}_ts.1D

				done

				# for ROI in V1v V1d V2v V2d V3v V3d V3a V4v ; do #V1v V1d V2v V2d V3v V3d V3a V4v

				# 	#3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR.nii.gz -q \
				# 	#${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_ts.1D

				# 	3dmaskave -mask ${OutputDir}/sub-${s}/ses-Loc/${ROI}_indiv_ROIFIR.nii.gz -q \
				# 	${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_errts.nii.gz > ${OutputDir}/sub-${s}/ses-${session}/${ROI}_allruns_w{w}_ts.1D

				# done



				3dDeconvolve \
				-input ${OutputDir}/sub-${s}/ses-${session}/Localizer_FIR_MNI_errts.nii.gz \
				-mask ${OutputDir}/sub-${s}/ses-${session}/union_MNI_mask.nii.gz \
				-num_stimts 20 \
				-stim_file 1 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_MTD_w${w}_FFA-V1.1D -stim_label 1 MTD_FH_FFA-VC \
				-stim_file 2 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_MTD_w${w}_PPA-V1.1D -stim_label 2 MTD_FH_PPA-VC \
				-stim_file 3 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_MTD_w${w}_FFA-V1.1D -stim_label 3 MTD_HF_FFA-VC \
				-stim_file 4 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_MTD_w${w}_PPA-V1.1D -stim_label 4 MTD_HF_PPA-VC \
				-stim_file 5 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_MTD_w${w}_FFA-V1.1D -stim_label 5 MTD_H2_FFA-VC \
				-stim_file 6 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_MTD_w${w}_PPA-V1.1D -stim_label 6 MTD_H2_PPA-VC \
				-stim_file 7 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_MTD_w${w}_FFA-V1.1D -stim_label 7 MTD_F2_FFA-VC \
				-stim_file 8 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_MTD_w${w}_PPA-V1.1D -stim_label 8 MTD_F2_PPA-VC \
				-stim_file 9 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_FFA.1D -stim_label 9 BC_FH_FFA \
				-stim_file 10 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_PPA.1D -stim_label 10 BC_FH_PPA \
				-stim_file 11 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_FFA.1D -stim_label 11 BC_HF_FFA \
				-stim_file 12 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_PPA.1D -stim_label 12 BC_HF_PPA \
				-stim_file 13 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_FFA.1D -stim_label 13 BC_F2_FFA \
				-stim_file 14 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_PPA.1D -stim_label 14 BC_F2_PPA \
				-stim_file 15 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_FFA.1D -stim_label 15 BC_H2_FFA \
				-stim_file 16 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_PPA.1D -stim_label 16 BC_H2_PPA \
				-stim_file 17 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_FH_BC_V1.1D -stim_label 17 BC_FH_VC \
				-stim_file 18 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_HF_BC_V1.1D -stim_label 18 BC_HF_VC \
				-stim_file 19 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_H2_BC_V1.1D -stim_label 19 BC_H2_VC \
				-stim_file 20 ${OutputDir}/sub-${s}/ses-${session}/${s}_${session}_F2_BC_V1.1D -stim_label 20 BC_F2_VC \
				-num_glt 19 \
				-gltsym 'SYM: +0.5*MTD_FH_FFA-VC +0.5*MTD_HF_PPA-VC' -glt_label 1 MTD_Target_1bk \
				-gltsym 'SYM: +0.5*MTD_HF_FFA-VC +0.5*MTD_FH_PPA-VC' -glt_label 2 MTD_Distractor_1bk \
				-gltsym 'SYM: +0.5*MTD_F2_FFA-VC +0.5*MTD_H2_PPA-VC' -glt_label 3 MTD_Target_2bk \
				-gltsym 'SYM: +0.5*MTD_H2_FFA-VC +0.5*MTD_F2_PPA-VC' -glt_label 4 MTD_Distractor_2bk \
				-gltsym 'SYM: +1*MTD_FH_FFA-VC +1*MTD_HF_PPA-VC -1*MTD_HF_FFA-VC -1*MTD_FH_PPA-VC' -glt_label 5 MTD_1bk_Target-Distractor \
				-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_H2_FFA-VC -1*MTD_F2_PPA-VC' -glt_label 6 MTD_2bk_Target-Distractor \
				-gltsym 'SYM: +1*MTD_F2_FFA-VC +1*MTD_H2_PPA-VC -1*MTD_FH_FFA-VC -1*MTD_HF_PPA-VC' -glt_label 7 MTD_Target_2bk-1bk \
				-gltsym 'SYM: +1*MTD_H2_FFA-VC +1*MTD_F2_PPA-VC -1*MTD_HF_FFA-VC -1*MTD_FH_PPA-VC' -glt_label 8 MTD_Distractor_2bk-1bk \
				-gltsym 'SYM: +0.5*BC_FH_FFA +0.5*BC_HF_PPA' -glt_label 9 BC_Target_1bk \
				-gltsym 'SYM: +0.5*BC_HF_FFA +0.5*BC_FH_PPA' -glt_label 10 BC_Distractor_1bk \
				-gltsym 'SYM: +0.5*BC_F2_FFA +0.5*BC_H2_PPA' -glt_label 11 BC_Target_2bk \
				-gltsym 'SYM: +0.5*BC_H2_FFA +0.5*BC_F2_PPA' -glt_label 12 BC_Distractor_2bk \
				-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_FH_FFA -1*BC_HF_PPA' -glt_label 13 BC_Target_2bk-1bk \
				-gltsym 'SYM: +1*BC_H2_FFA +1*BC_F2_PPA -1*BC_HF_FFA -1*BC_FH_PPA' -glt_label 14 BC_Distractor_2bk-1bk \
				-gltsym 'SYM: +1*BC_FH_FFA +1*BC_HF_PPA -1*BC_HF_FFA -1*BC_FH_PPA' -glt_label 15 BC_1bk_Target-Distractor \
				-gltsym 'SYM: +1*BC_F2_FFA +1*BC_H2_PPA -1*BC_H2_FFA -1*BC_F2_PPA' -glt_label 16 BC_2bk_Target-Distractor \
				-gltsym 'SYM: +1*BC_F2_VC +1*BC_H2_VC -1*BC_FH_VC -1*BC_HF_VC' -glt_label 17 BC_2bk-1bk_VC \
				-gltsym 'SYM: +0.5*BC_FH_VC +0.5*BC_HF_VC' -glt_label 18 BC_1bk_VC \
				-gltsym 'SYM: +0.5*BC_F2_VC +0.5*BC_H2_VC' -glt_label 19 BC_2bk_VC \
				-tout \
				-nocout \
				-bucket ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}_MNI \
				-GOFORIT 100 \
				-noFDR -jobs ${jobN}
				#-fout \
				#-rout \

				#results from 3dREMLfit cannot be saved into AFNI format or header info will be lost
				. ${OutputDir}/sub-${s}/ses-${session}/MTD_BC_stats_w${w}.REML_cmd


			fi	
		fi
	done
done


