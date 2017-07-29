#!/bin/bash
# script to run preprocessing (fmriprep) and localizer modle (FIR) amd MTD regression
export DISPLAY=""

WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Preprocessing'
Model='/home/despoB/kaihwang/bin/TTD/Models'

SUB_ID=$(echo ${SGE_TASK} | grep -Eo "^[[:digit:]]{1,}")
session=$(echo ${SGE_TASK} | grep -Eo "[A-Z][a-z]{1,}")
echo "running subject $SUB_ID, session $session"

## fmriprep
# source activate fmriprep;
# cd ${WD}/fmriprep;
# fmriprep \
#     --participant_label $SUB_ID \
#     --nthreads 8 \
#     --output-space T1w template \
#     --template MNI152NLin2009cAsym \
#     ${WD}/BIDS/ \
#     ${WD}/fmriprep/ \
#     participant

# END_TIME=$(date);
# echo "fmriprep for subject $SUB_ID completed at $END_TIME"

##parse stimulus timing
#change back to default env
source activate root 
#determine number of runs
nruns=$(/bin/ls ${WD}/fmriprep/fmriprep/sub-${SUB_ID}/ses-${session}/func/*task-TDD*T1w_preproc.nii.gz | wc -l)
echo "${SUB_ID} ${session} ${nruns}" | python ${SCRIPTS}/parse_stim.py

##FIR model for localizing
source ${Model}/run_FIR_model.sh

##MTD model
source ${Model}/run_MTD_reg_model.sh