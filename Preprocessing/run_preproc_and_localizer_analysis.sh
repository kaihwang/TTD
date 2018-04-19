#!/bin/bash
# script to run preprocessing (fmriprep) and localizer modle (FIR) amd MTD regression
export DISPLAY=""

WD='/home/despoB/TRSEPPI/TTD'
SCRIPTS='/home/despoB/kaihwang/bin/TTD/Preprocessing'
Model='/home/despoB/kaihwang/bin/TTD/Models'

SUB_ID=$(echo ${SGE_TASK} | grep -Eo "^[[:digit:]]{1,}")
session=$(echo ${SGE_TASK} | grep -Eo "[A-Z][a-zA-Z0-9]{1,}")

#SUB_ID=7014
#session=Loc

echo "running subject $SUB_ID, session $session"


##fmriprep for prerpocessing
#determine number of preproc runs, if preproc finished then will not run fmriprep
#nruns=$(/bin/ls ${WD}/fmriprep/fmriprep/sub-${SUB_ID}/ses-${session}/func/*task-TDD*T1w_preproc.nii.gz | wc -l)
#n_raw=$(/bin/ls ${WD}/BIDS/sub-${SUB_ID}/ses-${session}/func/*task-TDD*bold.nii.gz | wc -l)
#if [ "${nruns}" != "${n_raw}" ]; then
source activate fmriprep1.0;
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
echo "fmriprep for subject $SUB_ID completed at $END_TIME"
#fi

##parse stimulus timing
#change back to default env
source activate root 
nruns=$(/bin/ls ${WD}/fmriprep/fmriprep/sub-${SUB_ID}/ses-${session}/func/*task-TDD*T1w_preproc.nii.gz | wc -l)
echo "${SUB_ID} ${session} ${nruns}" | python ${SCRIPTS}/parse_stim.py


##FIR model for localizing
. ${Model}/run_FIR_model.sh


##MTD model
. ${Model}/run_MTD_reg_model.sh


##Retinotopy
if [ ${session} = Loc ]; then
	#create	SUMA surfaces
	if [ ! -d ${WD}/fmriprep/freesurfer/sub-${SUB_ID}/SUMA ]; then
		cd ${WD}/fmriprep/freesurfer/sub-${SUB_ID}/
		@SUMA_Make_Spec_FS -sid sub-${SUB_ID}
	fi

	if [ ! -d ${WD}/Results/sub-${SUB_ID}/ses-Loc/${SUB_ID}_meridian.results ]; then
		. ${Model}/run_meridian_mapping.sh
	fi
fi

