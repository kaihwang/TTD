#!/bin/bash
WD='/home/despoB/TRSEPPI/TTD'

for s in 601; do

	cd ${WD}/${s}/Loc/retinotopy_run1

	if [ ! -e ${WD}/${s}/Loc/retinotopy_run1/nswktm_functional_6.nii.gz ]; then

		rm *nii*
		rm *log
		preprocessFunctional -dicom "IM*" \
		-mprage_bet /home/despoB/kaihwang/TRSE/TTD/601/Loc/MPRAGE/mprage_bet.nii.gz \
		-warpcoef /home/despoB/kaihwang/TRSE/TTD/601/Loc/MPRAGE/mprage_warpcoef.nii.gz \
		-func_refimg /home/despoB/kaihwang/TRSE/TTD/601/Loc/retinotopy_ref/*.dcm \
		-tr 1.0 \
		-rescaling_method 100_voxelmean \
		-template_brain MNI_2mm \
		-func_struc_dof bbr \
		-compute_warp_only \
		-constrain_to_template n \
		-no_hp \
		-delete_dicom no \
		-mc_first \
		-motion_sinc n \
		-startover \
		-smoothing_kernel 4
	fi
done