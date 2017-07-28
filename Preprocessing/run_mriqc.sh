#!/bin/sh
source /home/despoB/kaihwang/.bashrc;
source activate mriqc;
SUB_ID="${SGE_TASK}";
WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Preprocessing'

cd ${WD}/QC;

mriqc \
    --participant_label $SUB_ID \
    -m T1w bold \
    --n_procs 8 \
    --mem_gb 8 \
    --ica \
    --ants-nthreads 3\
    -w ${WD}/QC/work \
    --verbose-reports \
    ${WD}/BIDS/ \
    ${WD}/QC/ \
    group 

END_TIME=$(date);
echo "QC pipeline for patient $SUB_ID completed at $END_TIME";