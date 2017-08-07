#!/bin/sh
source /home/despoB/kaihwang/.bashrc;
source activate mriqc;
SUB_ID=$(echo ${SGE_TASK} | grep -Eo "^[[:digit:]]{1,}")
WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Preprocessing'

cd ${WD}/QC;

mriqc \
    --participant_label $SUB_ID \
    -m T1w bold \
    --n_procs 4 \
    --mem_gb 8 \
    --ica \
    --ants-nthreads 4 \
    -w ${WD}/QC/work \
    --verbose-reports \
    ${WD}/BIDS/ \
    ${WD}/QC/ \
    participant group 

END_TIME=$(date);
echo "QC pipeline for subject $SUB_ID completed at $END_TIME";