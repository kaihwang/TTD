#!/bin/bash

#for SGE jobs

WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Preprocessing'

cd ${WD}

for Subject in 604; do #$(/bin/ls -d 6*)
	
	#sed "s/s in 601/s in ${Subject}/g" < ${SCRIPTS}/run_fs.sh > /home/despoB/kaihwang/tmp/fs${Subject}.sh 
	#qsub -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/tmp/fs${Subject}.sh 

	#sed "s/s in 601/s in ${Subject}/g" < ${SCRIPTS}/proc_retinotopy_func.sh > /home/despoB/kaihwang/tmp/ret${Subject}_v2.sh 
	#qsub -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/tmp/ret${Subject}_v2.sh 

	for r in $(seq 1 1 8); do
	
		#if [ ! -e "${WD}/${Subject}/run${r}/nswdktm_functional_6.nii.gz" ]; then
			sed "s/s in 601/s in ${Subject}/g; s/run1/run${r}/g " < ${SCRIPTS}/proc_loc_func.sh > /home/despoB/kaihwang/tmp/proc_loc_func_${Subject}_${r}.sh 
			qsub -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/tmp/proc_loc_func_${Subject}_${r}.sh    #
		#fi
	done

done