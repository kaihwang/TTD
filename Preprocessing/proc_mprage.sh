#!/bin/bash

#run preprocessMprage on subjects.

WD='/home/despoB/TRSEPPI/TTD'

for s in 601 602 603; do
	cd ${WD}/${s}/Loc/MPRAGE

	if [ ! -e ${WD}/${s}/Loc/MPRAGE/mprage_final.nii.gz ]; then
		
		preprocessMprage -r MNI_2mm -b "-R -f 0.2 -g 0" -d a -o mprage_final.nii.gz -p "IM*"
	fi
	

done