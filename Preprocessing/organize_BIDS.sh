#!/bin/bash
# use heudiconv to convert raw dicoms into NIFTIs in a BIDS directory
WD='/home/despoB/TRSEPPI/TTD'

# run heudiconv without converter

for s in 7004; do

	for ses in Loc S1 IPS; do

		if [ -d ${WD}/Raw/{subject}_{session} ]; then
			#first use no converter, get dicom info
			heudiconv -d ${WD}/Raw/{subject}_{session}/*/*/* -s ${s} -ss ${ses} \
			-f /home/despoB/kaihwang/bin/TTD/Preprocessing/TTD_heuristics.py -c none \
			-o ${WD}/BIDS --bids

			#convert dicom
			heudiconv -d ${WD}/Raw/{subject}_{session}/*/*/* -s ${s} -ss ${ses} \
			-f /home/despoB/kaihwang/bin/TTD/Preprocessing/TTD_heuristics.py -c dcm2niix \
			-o ${WD}/BIDS --bids --minmeta
		fi
	done
done
