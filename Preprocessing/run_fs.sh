WD='/home/despoB/TRSEPPI/TTD'

for s in 601; do

	cd ${WD}/${s}/Loc/MPRAGE

	recon-all -all -subjid ${s} -i mprage.nii.gz
done