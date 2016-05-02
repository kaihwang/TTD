WD='/home/despoB/TRSEPPI/TTD'

for s in 605; do

	cd ${WD}/${s}/Loc/MPRAGE
	recon-all -all -subjid ${s} -i mprage.nii.gz

	cd /home/despoB/kaihwang/Subjects/${s}
	
	/usr/local/afni/\@SUMA_Make_Spec_FS -sid ${s}

	ln -s /home/despoB/kaihwang/Subjects/${s}/SUMA ${WD}/${s}/Loc/SUMA

	cd ${WD}/${s}/Loc/SUMA
	preprocessMprage -r MNI_2mm -no_bias -b "-R -f 0.2 -g 0" -d a -o mprage_final.nii.gz -n T1.nii
	
done