#!/bin/bash

#for SGE jobs
WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Preprocessing'


#run_mriqc.sh or run_fmriprep.sh

# submit \
# 	-s ${SCRIPTS}/run_mriqc.sh \
# 	-f ${SCRIPTS}/test.subjects \
# 	-o ${SCRIPTS}/qsub.options


# submit \
#  	-s ${SCRIPTS}/run_preproc_and_localizer_analysis.sh \
#  	-f ${SCRIPTS}/test.subjects \
#  	-o ${SCRIPTS}/qsub.options

submit \
	-s ${SCRIPTS}/rerun_MTD.sh \
	-f ${SCRIPTS}/test.subjects \
	-o ${SCRIPTS}/qsub.options



# cd ${WD}

# for Subject in 560 617; do #$(/bin/ls -d 6*)
	
# 	#sed "s/s in 601/s in ${Subject}/g" < ${SCRIPTS}/run_fs.sh > /home/despoB/kaihwang/tmp/fs${Subject}.sh 
# 	#qsub -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/tmp/fs${Subject}.sh 

# 	#sed "s/s in 601/s in ${Subject}/g" < ${SCRIPTS}/proc_retinotopy_func.sh > /home/despoB/kaihwang/tmp/ret${Subject}.sh 
# 	#qsub -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/tmp/ret${Subject}.sh 

# 	for r in $(seq 1 1 16); do

# 	# 	#if [ ! -e "${WD}/${Subject}/run${r}/nswdktm_functional_6.nii.gz" ]; then
# 	 	sed "s/s in 601/s in ${Subject}/g; s/run1/run${r}/g " < ${SCRIPTS}/proc_func.sh > /home/despoB/kaihwang/tmp/proc_func_${Subject}_${r}.sh 
# 	 	qsub -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/tmp/proc_func_${Subject}_${r}.sh    #
# 	# 	#fi
# 	done

# done


# for Subject in 7003 7004 7006 7008 7009 7012 7014 7017 7016 7018 7019; do
# 	sed "s/s in 7003/s in ${Subject}/g" < ${SCRIPTS}/flatsurf.sh > /home/despoB/kaihwang/tmp/fs${Subject}.sh 
# 	qsub -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/tmp/fs${Subject}.sh

# done
