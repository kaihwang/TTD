#!/bin/sh
source /home/despoB/kaihwang/.bashrc;
source activate fmriprep;
SUB_ID="${SGE_TASK}";
#SUB_ID=7009
WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Preprocessing'

cd ${WD}/fmriprep;

fmriprep \
    --participant_label $SUB_ID \
    --nthreads 4 \
    --output-space T1w template \
    --template MNI152NLin2009cAsym \
    ${WD}/BIDS/ \
    ${WD}/fmriprep/ \
    participant

END_TIME=$(date);
echo "fMRIprep for $SUB_ID completed at $END_TIME";