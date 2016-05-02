#!/bin/bash
# script to run FIR model for each condition.

WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/Scripts'

for s in 602; do
	for site in FEF MFG S1; do
		if [ -d ${WD}/${s}/${site}/ ]; then

			cd ${WD}/${s}/${site}/
			rm *FIR*
			rm *nusiance*
			
			# normalize tissue masks to extract nuisance signal
			fslreorient2std ${WD}/${s}/${site}/MPRAGE/mprage_bet_fast_seg_0.nii.gz ${WD}/${s}/${site}/MPRAGE/mprage_bet_fast_seg_0.nii.gz
			applywarp --ref=${WD}/${s}/${site}/MPRAGE/mprage_final.nii.gz \
			--rel \
			--interp=nn \
			--in=${WD}/${s}/${site}/MPRAGE/mprage_bet_fast_seg_0.nii.gz \
			--warp=${WD}/${s}/${site}/MPRAGE/mprage_warpcoef.nii.gz \
			-o ${WD}/${s}/${site}/CSF_orig.nii.gz
			rm ${WD}/${s}/${site}/CSF_erode.nii.gz
			3dmask_tool -prefix ${WD}/${s}/${site}/CSF_erode.nii.gz -quiet -input ${WD}/${s}/${site}/CSF_orig.nii.gz -dilate_result -1

			fslreorient2std ${WD}/${s}/${site}/MPRAGE/mprage_bet_fast_seg_2.nii.gz ${WD}/${s}/${site}/MPRAGE/mprage_bet_fast_seg_2.nii.gz
			applywarp --ref=${WD}/${s}/${site}/MPRAGE/mprage_final.nii.gz \
			--rel \
			--interp=nn \
			--in=${WD}/${s}/${site}/MPRAGE/mprage_bet_fast_seg_2.nii.gz \
			--warp=${WD}/${s}/${site}/MPRAGE/mprage_warpcoef.nii.gz \
			-o ${WD}/${s}/${site}/WM_orig.nii.gz	
			rm ${WD}/${s}/${site}/WM_erode.nii.gz
			3dmask_tool -prefix ${WD}/${s}/${site}/WM_erode.nii.gz -quiet -input ${WD}/${s}/${site}/WM_orig.nii.gz -dilate_result -1

			#extract runs for each condition: FH, HF, Fp, Hp
			for condition in FH HF Fp Hp; do
				
				# create motor regressors
				echo -n "" > ${WD}/${s}/${site}/${condition}_stimtime.1D
				
				#create stimtime for each condition
				for run in $(cat ${SCRIPTS}/${s}_${site}_run_order | grep -n ${condition} | cut -f1 -d:); do
					
					if [ ! -e ${WD}/${s}/${site}/${condition}_run${run}.nii.gz ]; then
						ln -s ${WD}/${s}/${site}/${site}_run${run}/nswktm_functional_4.nii.gz ${WD}/${s}/${site}/${condition}_run${run}.nii.gz
					fi
					
					if [ ! -e ${WD}/${s}/${site}/${condition}_run${run}_motpar.1D ]; then
						ln -s ${WD}/${s}/${site}/${site}_run${run}/motion.par ${WD}/${s}/${site}/${condition}_run${run}_motpar.1D
					fi

					sed -n "${run},${run}p" ${SCRIPTS}/${s}_${site}_${condition}_stimtime.1D >> ${WD}/${s}/${site}/${condition}_stimtime.1D

					#nuisance tissue signal
					3dmaskave -quiet -mask ${WD}/${s}/${site}/CSF_erode.nii.gz ${WD}/${s}/${site}/${condition}_run${run}.nii.gz > ${WD}/${s}/${site}/CSF_TS_${condition}_run${run}.1D
					3dmaskave -quiet -mask ${WD}/${s}/${site}/WM_erode.nii.gz ${WD}/${s}/${site}/${condition}_run${run}.nii.gz > ${WD}/${s}/${site}/WM_TS_${condition}_run${run}.1D
					3dmaskave -quiet -mask ${WD}/${s}/${site}/${site}_run${run}/subject_mask.nii.gz ${WD}/${s}/${site}/${condition}_run${run}.nii.gz > ${WD}/${s}/${site}/GS_TS_${condition}_run${run}.1D

				done

				# concat motion regressors and create censor files
				cat $(/bin/ls ${WD}/${s}/${site}/${condition}_run*_motpar.1D | sort -V) > ${WD}/${s}/${site}/Motion_${condition}_runs.1D

				1d_tool.py -infile ${WD}/${s}/${site}/Motion_${condition}_runs.1D \
				-set_nruns 3 -show_censor_count -censor_motion 0.3 ${s}_${condition} -censor_prev_TR -overwrite

				#tissue regressors
				cat $(/bin/ls ${WD}/${s}/${site}/CSF_TS_${condition}_run*.1D | sort -V) > ${WD}/${s}/${site}/RegCSF_${condition}_TS.1D
				cat $(/bin/ls ${WD}/${s}/${site}/WM_TS_${condition}_run*.1D | sort -V) > ${WD}/${s}/${site}/RegWM_${condition}_TS.1D
				cat $(/bin/ls ${WD}/${s}/${site}/GS_TS_${condition}_run*.1D | sort -V) > ${WD}/${s}/${site}/RegGS_${condition}_TS.1D

				#run "nuisance model"
				3dDeconvolve -input $(/bin/ls ${WD}/${s}/${site}/${condition}_run*.nii.gz | sort -V) \
				-automask \
				-polort A \
				-num_stimts 9 \
				-stim_file 1 ${WD}/${s}/${site}/Motion_${condition}_runs.1D[0] -stim_label 1 motpar1 \
				-stim_file 2 ${WD}/${s}/${site}/Motion_${condition}_runs.1D[1] -stim_label 2 motpar2 \
				-stim_file 3 ${WD}/${s}/${site}/Motion_${condition}_runs.1D[2] -stim_label 3 motpar3 \
				-stim_file 4 ${WD}/${s}/${site}/Motion_${condition}_runs.1D[3] -stim_label 4 motpar4 \
				-stim_file 5 ${WD}/${s}/${site}/Motion_${condition}_runs.1D[4] -stim_label 5 motpar5 \
				-stim_file 6 ${WD}/${s}/${site}/Motion_${condition}_runs.1D[5] -stim_label 6 motpar6 \
				-stim_file 7 ${WD}/${s}/${site}/RegCSF_${condition}_TS.1D -stim_label 7 CSF \
				-stim_file 8 ${WD}/${s}/${site}/RegWM_${condition}_TS.1D -stim_label 8 WM \
				-stim_file 9 ${WD}/${s}/${site}/RegGS_${condition}_TS.1D -stim_label 9 GS \
				-nobucket \
				-GOFORIT 100 \
				-noFDR \
				-errts ${WD}/${s}/${site}/${s}_nusiance_${condition}_errts.nii.gz \
				-allzero_OK


				# run FIR model
				3dDeconvolve -input ${WD}/${s}/${site}/${s}_nusiance_${condition}_errts.nii.gz \
				-concat '1D: 0 155 310' \
				-automask \
				-polort A \
				-num_stimts 1 \
				-stim_times 1 ${WD}/${s}/${site}/${condition}_stimtime.1D 'TENT(-2, 28, 30)' -stim_label 1 ${condition}_FIR \
				-iresp 1 ${condition}_FIR \
				-rout \
				-nocout \
				-bucket FIR_${condition}_stats \
				-x1D FIR_${condition}_design_mat \
				-GOFORIT 100\
				-noFDR \
				-errts ${WD}/${s}/${site}/${s}_FIR_${condition}_errts.nii.gz \
				-allzero_OK
			done	
		fi			
	done
done

