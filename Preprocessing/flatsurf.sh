#FS flat

WD='/home/despoB/TRSEPPI/TTD'

for s in 7003; do
	mris_flatten /home/despoB/kaihwang/TRSE/TTD/fmriprep/freesurfer/sub-${s}/surf/rh.full.patch.3d /home/despoB/kaihwang/TRSE/TTD/fmriprep/freesurfer/sub-${s}/surf/rh.full.flat.patch.3d
	rm -rf ${WD}/fmriprep/freesurfer/sub-${s}/SUMA
	cd ${WD}/fmriprep/freesurfer/sub-${s}/
	@SUMA_Make_Spec_FS -sid sub-${s}
done