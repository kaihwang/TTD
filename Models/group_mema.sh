#!/bin/bash
# do group MTD regression analysis


#MTD_Target MTD_Distractor MTD_Target-Baseline MTD_Distractor-Baseline MTD_Target-Distractor BC_Target BC_Distractor BC_Target-Baseline BC_Distractor-Baseline BC_Target-Distractor


data='/home/despoB/kaihwang/TRSE/TTD/Results/'
#'sub-7002/ses-Loc'

for contrast in MTD_Target_2bk-1bk_GLT MTD_Target_1bk-categorize_GLT MTD_Target_2bk-categorize_GLT MTD_1bk_Target-Distractor_GLT MTD_2bk_Target-Distractor_GLT; do
	for w in 13; do
		for dset in FIR ; do #nusiance
			echo "cd /home/despoB/kaihwang/TRSE/TTD/Group 
			3dMEMA -prefix /home/despoB/kaihwang/TRSE/TTD/Group/${dset}_${contrast}_w${w}_groupMEMA \\
			-set ${contrast} \\" > /home/despoB/kaihwang/TRSE/TTD/Group/groupstat_${dset}_${contrast}.sh

			cd ${data}
			

			for s in sub-7002 sub-7003 sub-7004 sub-7006 sub-7008 sub-7009 sub-7012 sub-7014 sub-7016 sub-7017 sub-7019; do
				cbrik=$(3dinfo -verb ${data}/${s}//ses-Loc/MTD_BC_stats_w13_MNI+orig | grep "${contrast}#0_Coef" | grep -o ' #[0-9]\{1,3\}' | grep -o '[0-9]\{1,3\}')
				tbrik=$(3dinfo -verb ${data}/${s}//ses-Loc/MTD_BC_stats_w13_MNI+orig | grep "${contrast}#0_Tstat" | grep -o ' #[0-9]\{1,3\}' | grep -o '[0-9]\{1,3\}')

				echo "${s} ${data}/${s}//ses-Loc/MTD_BC_stats_w13_MNI+orig[${cbrik}] ${data}/${s}//ses-Loc/MTD_BC_stats_w13_MNI+orig[${tbrik}] \\" >> /home/despoB/kaihwang/TRSE/TTD/Group/groupstat_${dset}_${contrast}.sh
			done

			echo "-cio -mask /home/despoB/kaihwang/TRSE/TTD/Group/overlap_mask.nii.gz" >> /home/despoB/kaihwang/TRSE/TTD/Group/groupstat_${dset}_${contrast}.sh

			#qsub -l mem_free=3G -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/TRSE/TDSigEI/Group/groupstat_${dset}_${contrast}.sh
			. /home/despoB/kaihwang/TRSE/TTD/Group/groupstat_${dset}_${contrast}.sh

		done
	done
done

# 			#qsub -l mem_free=3G -V -M kaihwang -m e -e ~/tmp -o ~/tmp /home/despoB/kaihwang/TRSE/TDSigEI/Group/groupstat_${dset}_${contrast}.sh
