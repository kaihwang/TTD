


for s in 7003 7004 7006 7008 7009 7010 7011 7012 7014 7016 7018 7019; do

	cd /home/despoB/kaihwang/TRSE/TTD/Results/sub-${s}/ses-Loc/${s}_meridian.results


	for roi in V1d V1v V2d V2v V3v V3d V3a V4v; do
		ROI2dataset -prefix ${roi} -of 1D -input RH_${roi}.niml.roi

		3dSurf2Vol -spec ~/TRSE/TTD/fmriprep/freesurfer/sub-${s}/SUMA/sub-${s}_rh.spec \
		-surf_A smoothwm -surf_B pial \
		-sv ${s}_meridian_SurfVol_Alnd_Exp+orig \
		-grid_parent ${s}_meridian_SurfVol_Alnd_Exp+orig \
		-sdata_1D ${roi}.1D.dset \
		-prefix /home/despoB/kaihwang/TRSE/TTD/Results/sub-${s}/ses-Loc/${roi}_indiv_ROIFIR.nii.gz \
		-map_function mode

	done
	

done