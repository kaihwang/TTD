
WD='/home/despoB/TRSEPPI/TTD'

for s in 603 604; do

	cd ${WD}/${s}/Loc/

	@RetinoProc -TR 1.0 \
	-period_pol 20 \
	-period_ecc 0 \
	-pre_pol 0 \
	-pre_ecc 0 \
	-nwedges 1 \
	-no_tshift \
	-noVR \
	-ignore 0 \
	-clw ${WD}/${s}/Loc/SUMA/retinotopy_run1.nii.gz ${WD}/${s}/Loc/SUMA/retinotopy_run3.nii.gz \
	-ccw ${WD}/${s}/Loc/SUMA/retinotopy_run2.nii.gz ${WD}/${s}/Loc/SUMA/retinotopy_run4.nii.gz \
	-anat_vol@epi ${WD}/${s}/Loc/SUMA/${s}_SurfVol+orig.HEAD \
	-surf_vol@epi ${WD}/${s}/Loc/SUMA/${s}_SurfVol+orig.HEAD \
	-spec_left ${WD}/${s}/Loc/SUMA/${s}_lh.spec \
	-spec_right ${WD}/${s}/Loc/SUMA/${s}_rh.spec \
	-sid ${s} \
	-out_dir ${WD}/${s}/Loc/Retinotopy

done