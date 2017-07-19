#!/bin/bash
# use heudiconv to convert raw dicoms into NIFTIs in a BIDS directory
WD='/home/despoB/TRSEPPI/TTD'

# run heudiconv without converter

for s in P01; do
	#first use no converter, get dicom info
	#heudiconv -d ${WD}/Raw/{subject}/*/*/* -s ${s} \
	#-f /home/despoB/kaihwang/bin/heudiconv/heuristics/convertall.py -c none \
	#-o ${WD}/BIDS --bids

	#convert dicom 
	heudiconv -d ${WD}/Raw/{subject}/*/*/* -s ${s} \
	-f /home/despoB/kaihwang/bin/TTD/Preprocessing/TTD_heuristics.py -c dcm2niix -o ${WD}/BIDS --bids --minmeta
done
