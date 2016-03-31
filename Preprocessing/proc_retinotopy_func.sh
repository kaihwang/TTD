#!/bin/bash
WD='/home/despoB/TRSEPPI/TTD'

for s in 603; do

	for run in 1 2 3 4; do

	if [ ! -e /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/retinotopy_run${run}.nii.gz ]; then
	
		cd ${WD}/${s}/Loc/retinotopy_run${run}

		rm *nii*
		rm *log*
		rm -rf *motion*
		rm -rf *mat*
		rm .*
		tar -xf functional_dicom.tar.gz
		rm functional_dicom.tar.gz

		preprocessFunctional -dicom "IM*" \
		-mprage_bet /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/T1_bet.nii.gz \
		-warpcoef /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/T1_warpcoef.nii.gz \
		-func_refimg /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/retinotopy_ref/*.dcm \
		-tr 1.0 \
		-rescaling_method 100_voxelmean \
		-template_brain MNI_2mm \
		-func_struc_dof bbr \
		-compute_warp_only \
		-constrain_to_template n \
		-no_hp \
		-delete_dicom archive \
		-mc_first \
		-motion_sinc n \
		-startover \
		-smoothing_kernel 4

		3dresample -inset /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/T1.nii.gz -dxyz 2.5 2.5 2.5 -prefix /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/T1_2.5.nii.gz

		flirt -in nsktm_functional_4.nii.gz \
		-ref /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/T1_2.5.nii.gz \
		-init func_to_struct.mat \
		-o retinotopy_run${run}.nii.gz \
		-applyxfm

		rm /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/retinotopy_run${run}.nii.gz
		ln -s ${WD}/${s}/Loc/retinotopy_run${run}/retinotopy_run${run}.nii.gz /home/despoB/kaihwang/TRSE/TTD/${s}/Loc/SUMA/retinotopy_run${run}.nii.gz
	fi

	done
done