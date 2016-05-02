#!/bin/bash

WD='/home/despoB/TRSEPPI/TTD'

for s in 601; do

	for site in FEF MFG S1; do

		if [ -d ${WD}/${s}/${site}/${site}_run1 ]; then

			cd ${WD}/${s}/${site}/${site}_run1

			if [ ! -e ${WD}/${s}/${site}/${site}_run1/nswktm_functional_4.nii.gz ]; then
				
				preprocessFunctional -dicom "IM*" \
				-mprage_bet ${WD}/${s}/${site}/MPRAGE/mprage_bet.nii.gz \
				-warpcoef ${WD}/${s}/${site}/MPRAGE/mprage_warpcoef.nii.gz \
				-func_refimg ${WD}/${s}/${site}/${site}_run1_ref/*.dcm \
				-tr 1.0 \
				-rescaling_method 100_voxelmean \
				-template_brain MNI_2mm \
				-func_struc_dof bbr \
				-warp_interpolation spline \
				-constrain_to_template y \
				-4d_slice_motion \
				-no_hp \
				-cleanup \
				-custom_slice_times detect \
				-delete_dicom archive \
				-smoothing_kernel 4
			fi
		fi
	done
done


