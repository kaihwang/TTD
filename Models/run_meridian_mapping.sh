#!/bin/bash
# script to run retinotopy analysis, from Elizabeth

WD='/home/despoB/kaihwang/TRSE/TTD'
OutputDir='/home/despoB/kaihwang/TRSE/TTD/Results'
#SUB_ID=7018
ses=Ret
for subject in 7019; do

	#convert freesurfer skullstrip brain as underlay
	mri_convert /home/despoB/kaihwang/TRSE/TTD/fmriprep/freesurfer/sub-${subject}/mri/brain.mgz ${OutputDir}/sub-${subject}/ses-${ses}/brain.nii.gz
	fslreorient2std ${OutputDir}/sub-${subject}/ses-${ses}/brain.nii.gz ${OutputDir}/sub-${subject}/ses-${ses}/brain.nii.gz

	cd ${OutputDir}/sub-${subject}/ses-${ses}/
	afni_proc.py -subj_id ${subject}_meridian \
	-blocks surf blur scale regress \
	-copy_anat ${OutputDir}/sub-${subject}/ses-${ses}/brain.nii.gz \
	-anat_has_skull no \
	-dsets ${WD}/fmriprep/fmriprep/sub-${subject}/ses-${ses}/func/*Retinotopy*space-T1w_preproc.nii.gz \
	-surf_anat ${WD}/fmriprep/freesurfer/sub-${subject}/SUMA/sub-${subject}_SurfVol+orig \
	-surf_spec ${WD}/fmriprep/freesurfer/sub-${subject}/SUMA/sub-${subject}_?h.spec \
	-blur_size 6 \
	-regress_stim_times /home/despoC/faceWM/scripts/meridian_mapping/horz_timing.txt /home/despoC/faceWM/scripts/meridian_mapping/vert_timing.txt \
	-regress_stim_labels horz vert \
	-regress_basis 'BLOCK(10,1)' \
	-regress_opts_3dD \
	-jobs 3 \
	-gltsym 'SYM: horz -vert' \
	-glt_label 1 H-V \
	-gltsym 'SYM: vert -horz' \
	-glt_label 2 V-H	

	tcsh -xef proc.${subject}_meridian |& tee output.proc.${subject}_meridian

done


