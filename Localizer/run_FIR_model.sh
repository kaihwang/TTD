#!/bin/bash
# script to run FIR model for each condition. For localization FFA/PPA/FEF/MFG

WD='/home/despoB/kaihwang/TRSE/TTD'
SCRIPTS='/home/despoB/kaihwang/TRSE/TTD/Scripts'


for s in 605; do
	cd ${WD}/${s}/Loc
	rm *FIR*
	rm *nusiance*
	rm Localizer*
	
	# normalize tissue masks to extract nuisance signal
	if [ ! -e ${WD}/${s}/Loc/CSF_erode.nii.gz ]; then
		fslreorient2std ${WD}/${s}/Loc/MPRAGE/mprage_bet_fast_seg_0.nii.gz ${WD}/${s}/Loc/MPRAGE/mprage_bet_fast_seg_0.nii.gz
		applywarp --ref=${WD}/${s}/Loc/MPRAGE/mprage_final.nii.gz \
		--rel \
		--interp=nn \
		--in=${WD}/${s}/Loc/MPRAGE/mprage_bet_fast_seg_0.nii.gz \
		--warp=${WD}/${s}/Loc/MPRAGE/mprage_warpcoef.nii.gz \
		-o ${WD}/${s}/Loc/CSF_orig.nii.gz
		rm ${WD}/${s}/Loc/CSF_erode.nii.gz

		3dmask_tool -prefix ${WD}/${s}/Loc/CSF_erode.nii.gz -quiet -input ${WD}/${s}/Loc/CSF_orig.nii.gz -dilate_result -1
	fi
	
	if [ ! -e ${WD}/${s}/Loc/WM_erode.nii.gz ]; then
		fslreorient2std ${WD}/${s}/Loc/MPRAGE/mprage_bet_fast_seg_2.nii.gz ${WD}/${s}/Loc/MPRAGE/mprage_bet_fast_seg_2.nii.gz
		applywarp --ref=${WD}/${s}/Loc/MPRAGE/mprage_final.nii.gz \
		--rel \
		--interp=nn \
		--in=${WD}/${s}/Loc/MPRAGE/mprage_bet_fast_seg_2.nii.gz \
		--warp=${WD}/${s}/Loc/MPRAGE/mprage_warpcoef.nii.gz \
		-o ${WD}/${s}/Loc/WM_orig.nii.gz	
		rm ${WD}/${s}/Loc/WM_erode.nii.gz
		
		3dmask_tool -prefix ${WD}/${s}/Loc/WM_erode.nii.gz -quiet -input ${WD}/${s}/Loc/WM_orig.nii.gz -dilate_result -1
	fi	
	
	#get regressors and sym link to runs
	cat $(/bin/ls loc_run*/motion.par | sort -V) > ${WD}/${s}/Loc/motion.1D


	for run in 1 2 3 4 5 6; do
		
		if [ ! -e ${WD}/${s}/Loc/localizer_run${run}.nii.gz ]; then
			ln -s ${WD}/${s}/Loc/loc_run${run}/nswktm_functional_4.nii.gz ${WD}/${s}/Loc/localizer_run${run}.nii.gz
		fi

		if [ ! -e ${WD}/${s}/Loc/CSF_TS_run${run}.1D ]; then
			3dmaskave -quiet -mask ${WD}/${s}/Loc/CSF_erode.nii.gz ${WD}/${s}/Loc/localizer_run${run}.nii.gz > ${WD}/${s}/Loc/CSF_TS_run${run}.1D
		fi
		if [ ! -e ${WD}/${s}/Loc/WM_TS_run${run}.1D ]; then
			3dmaskave -quiet -mask ${WD}/${s}/Loc/WM_erode.nii.gz ${WD}/${s}/Loc/localizer_run${run}.nii.gz > ${WD}/${s}/Loc/WM_TS_run${run}.1D
		fi
	done

	cat $(/bin/ls ${WD}/${s}/Loc/CSF_TS_run*.1D | sort -V) > ${WD}/${s}/Loc/RegCSF_TS.1D
	cat $(/bin/ls ${WD}/${s}/Loc/WM_TS_run*.1D | sort -V) > ${WD}/${s}/Loc/RegWM_TS.1D

	#run localizer Model
	3dDeconvolve -input $(/bin/ls ${WD}/${s}/Loc/localizer_run*.nii.gz | sort -V) \
	-automask \
	-polort A \
	-num_stimts 12 \
	-stim_file 1 ${WD}/${s}/Loc/motion.1D[0] -stim_label 1 motpar1 -stim_base 1 \
	-stim_file 2 ${WD}/${s}/Loc/motion.1D[1] -stim_label 2 motpar2 -stim_base 2 \
	-stim_file 3 ${WD}/${s}/Loc/motion.1D[2] -stim_label 3 motpar3 -stim_base 3 \
	-stim_file 4 ${WD}/${s}/Loc/motion.1D[3] -stim_label 4 motpar4 -stim_base 4 \
	-stim_file 5 ${WD}/${s}/Loc/motion.1D[4] -stim_label 5 motpar5 -stim_base 5 \
	-stim_file 6 ${WD}/${s}/Loc/motion.1D[5] -stim_label 6 motpar6 -stim_base 6 \
	-stim_file 7 ${WD}/${s}/Loc/RegCSF_TS.1D -stim_label 7 CSF -stim_base 7 \
	-stim_file 8 ${WD}/${s}/Loc/RegWM_TS.1D -stim_label 8 WM -stim_base 8 \
	-stim_times 9 ${SCRIPTS}/${s}_loc_FH_stimtime 'TENT(-1, 26, 27)' -stim_label 9 FH \
	-stim_times 10 ${SCRIPTS}/${s}_loc_HF_stimtime 'TENT(-1, 26, 27)' -stim_label 10 HF \
	-stim_times 11 ${SCRIPTS}/${s}_loc_Fp_stimtime 'TENT(-1, 26, 27)' -stim_label 11 Fp \
	-stim_times 12 ${SCRIPTS}/${s}_loc_Hp_stimtime 'TENT(-1, 26, 27)' -stim_label 12 Hp \
	-iresp 9 Localizer_FH_FIR \
	-iresp 10 Localizer_HF_FIR \
	-iresp 11 Localizer_Fp_FIR \
	-iresp 12 Localizer_Hp_FIR \
	-gltsym 'SYM: +1*FH +1*Fp -1*HF -1*Hp ' -glt_label 1 F-H \
	-gltsym 'SYM: +1*FH +1*HF -1*Fp -1*Hp ' -glt_label 2 TD-p \
	-gltsym 'SYM: +0.5*FH +0.5*HF ' -glt_label 3 TD \
	-gltsym 'SYM: +0.5*Fp +0.5*Hp ' -glt_label 4 p \
	-gltsym 'SYM: +0.5*FH +0.5*Fp ' -glt_label 5 F \
	-gltsym 'SYM: +0.5*HF +0.5*Hp ' -glt_label 6 H \
	-rout \
	-tout \
	-bucket Localizer_stats \
	-x1D Localizer_design_mat \
	-GOFORIT 100 \
	-noFDR \
	-nocout \
	-errts Localizer_FIR_errts.nii.gz \
	-allzero_OK
	#-x1D_stop \


	#create FFA PPA masks
	3dTcat -prefix face_v_house_tstat Localizer_stats+tlrc[3]
	3dcalc \
	-a face_v_house_tstat+tlrc \
	-b /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/Group_FFA_mask.nii.gz \
	-expr 'ispositive(a*b)' -short -prefix FFAmasked.nii.gz
	3dmaskdump -mask FFAmasked.nii.gz -quiet FFAmasked.nii.gz | sort -k4 -n -r | head -n 255 | 3dUndump -master FFAmasked.nii.gz -ijk -prefix FFA_indiv_ROI.nii.gz stdin

	3dcalc \
	-a face_v_house_tstat+tlrc \
	-b /home/despoB/kaihwang/TRSE/TDSigEI/ROIs/Group_PPA_mask.nii.gz \
	-expr 'isnegative(a*b)' -short -prefix PPAmasked.nii.gz
	3dmaskdump -mask PPAmasked.nii.gz -quiet PPAmasked.nii.gz | sort -k4 -n -r | head -n 255 | 3dUndump -master PPAmasked.nii.gz -ijk -prefix PPA_indiv_ROI.nii.gz stdin
	
	#create V1 mask 
	3dmaskdump -mask /home/despoB/kaihwang/TRSE/TTD/ROIs/vismask.nii.gz -quiet Localizer_stats+tlrc[1] | sort -k4 -n -r | head -n 1 | 3dUndump -master FFAmasked.nii.gz -srad 8 -ijk -prefix V1_indiv_ROI.nii.gz stdin


done
#
