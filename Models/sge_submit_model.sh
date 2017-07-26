#!/bin/bash

#for SGE jobs

#mkdir tmp;
WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Models'

# submit \
# 	-s ${SCRIPTS}/run_FIR_model.sh \
# 	-f ${SCRIPTS}/test.subjects \
# 	-o ${SCRIPTS}/qsub.options.FIR_model


submit \
	-s ${SCRIPTS}/run_MTD_reg_model.sh \
	-f ${SCRIPTS}/test.subjects \
	-o ${SCRIPTS}/qsub.options.FIR_model





# cd ${WD}

# for Subject in $(/bin/ls -d 5*); do

# 	# if [ ! -e ${WD}/${Subject}/gPPI_PPA_Full_model_stats_REMLvar+tlrc.HEAD ]; then
# 	# 	sed "s/s in 503/s in ${Subject}/g" < ${SCRIPTS}/run_PPI_model.sh> ~/tmp/PPI_${Subject}.sh
# 	# 	qsub -l mem_free=5G -V -M kaihwang -m e -e ~/tmp -o ~/tmp ~/tmp/PPI_${Subject}.sh
# 	# fi	

# 	#if [ ! -e ${WD}/${Subject}/${Subject}_FIR_FH_errts.nii.gz ]; then
# 	# sed "s/s in 503/s in ${Subject}/g" < ${SCRIPTS}/run_sc_motor_model.sh> ~/tmp/rsmm_${Subject}.sh
# 	# qsub -l mem_free=5G -V -M kaihwang -m e -e ~/tmp -o ~/tmp ~/tmp/rsmm_${Subject}.sh

# 	sed "s/s in 503/s in ${Subject}/g" < ${SCRIPTS}/Models/run_FIR_model.sh > ~/tmp/FIR_${Subject}.sh
# 	qsub -l mem_free=5G -V -M kaihwang -m e -e ~/tmp -o ~/tmp ~/tmp/FIR_${Subject}.sh
# 	#fi	
# done
