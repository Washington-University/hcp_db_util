#!/bin/sh
# hcp_copy : make copy of data from HCP archive
# Copyright (c) 2012 Washington University
# Author: Kevin A. Archie <karchie@wustl.edu>

declare -r archive=/data/intradb/archive/HCP_Phase2/arc001

while getopts "D:F:K:S:V" opt; do
    case $opt in
	D)
	    declare -r outdir=$OPTARG
	    ;;

	F)
	    declare -r fMRIName=$OPTARG
	    ;;

	K)
	    declare -r input_packet=$OPTARG
	    ;;

	S)
	    declare -r subject=$OPTARG
	    ;;

	V)
	    declare -r verbose="-v"
	    ;;

	\?)
	    echo 'Usage: hcp_copy -S subject -K Structural|Functional [-F fMRI-packet-name] [-D output-directory]' >&2
	    exit 1
	    ;;

	:)
	    echo 'Error: Option -$OPTARG requires an argument.' >&2
	    exit 1
	    ;;
    esac
done

if [ "x$subject" == "x" ]; then
    echo 'Error: Must use -S to specify a subject' >&2
    exit 1
fi

# if output directory not specified, use subject label
declare -r outdir=${outdir:-$subject}
mkdir -p "$outdir"

shopt -s nocasematch
case $input_packet in
    structural)
	for h in $(cat <<EOF
MNINonLinear/*
MNINonLinear/Native/*
MNINonLinear/fsaverage_LR32k/*
MNINonLinear/xfms/acpc_dc2standard.nii.gz
MNINonLinear/xfms/NonlinearRegJacobians.nii.gz
MNINonLinear/xfms/standard2acpc_dc.nii.gz
T1w/Native/*
T1w/T1w_acpc_dc.nii.gz
T1w/T1w_acpc_dc_restore.nii.gz
T1w/T1w_acpc_dc_restore_brain.nii.gz
T1w/T2w_acpc_dc.nii.gz
T1w/T2w_acpc_dc_restore.nii.gz
T1w/T2w_acpc_dc_restore_brain.nii.gz
T1w/T1wDividedByT2w.nii.gz
T1w/T1wDividedByT2w_ribbon.nii.gz
T1w/brainmask_fs.nii.gz
T1w/wmparc.nii.gz
T1w/BiasField_acpc_dc.nii.gz
EOF
	); do
	    for session in strc xtra xtrb; do
		basedir="${archive}/${subject}_${session}/RESOURCES/Details"
		# if component ends in *, take all contained files
		# but don't descend into subdirectories
		echo $h | grep '/\*$' >/dev/null
		if [ $? -eq 0 ]; then
		    name=$(echo $h | sed 's!/\*$!!')
		    dir="${basedir}/${name}"
		    mkdir -p "${outdir}/${name}";
		    count=0
		    for file in $(ls -p "$dir" | grep -v /); do
			cp $verbose "${dir}/$file" "${outdir}/${name}/$file"
			((count++))
		    done
		    if [ $count -gt 0 ]; then
			break;
		    fi
		elif [ -f "${basedir}/${h}" ]; then
		    mkdir -p $(dirname "${outdir}/${h}")
		    cp $verbose "${basedir}/${h}" "${outdir}/${h}"
		    break;
		else
		    if [ -n "$verbose" ]; then
			echo $h not found in ${subject}_${session}
		    fi
		fi
	    done
	done
	;;

    functional)
	if [ "x$fMRIName" == "x" ]; then
	    echo 'Error: Must use -F to specify an fMRI packet' >&2
	    exit 1
	fi
	for h in $(cat <<EOF
MNINonLinear/Results/${fMRIName}/${fMRIName}.nii.gz
MNINonLinear/Results/${fMRIName}/${fMRIName}_Atlas.dtseries.nii
MNINonLinear/Results/${fMRIName}/Movement_Regressors.txt
MNINonLinear/Results/${fMRIName}/Movement_Regressors_dt.txt
MNINonLinear/Results/${fMRIName}/${fMRIName}_s2.atlasroi.L.32k_fs_LR.func.gii
MNINonLinear/Results/${fMRIName}/${fMRIName}_s2.atlasroi.R.32k_fs_LR.func.gii
MNINonLinear/Results/${fMRIName}/${fMRIName}_AtlasSubcortical_s2.nii.gz
MNINonLinear/Results/${fMRIName}/${fMRIName}_SBRef.nii.gz
MNINonLinear/Results/${fMRIName}/RibbonVolumeToSurfaceMapping/goodvoxels.nii.gz
EOF
	); do
	    for session in fnca fncb xtra xtrb; do
		basedir="${archive}/${subject}_${session}/RESOURCES/${fMRIName}"
		# if component ends in *, take all contained files
		# but don't descend into subdirectories
		echo $h | grep '/\*$' >/dev/null
		if [ $? -eq 0 ]; then
		    name=$(echo $h | sed 's!/\*$!!')
		    dir="${basedir}/${name}"
		    mkdir -p "${outdir}/${name}";
		    declare -i count=0
		    for file in $(ls -p "$dir" | grep -v /); do
			cp $verbose "${dir}/$file" "${outdir}/${name}/$file"
			((count++))
		    done
		    if [ $count -gt 0 ]; then
			break;
		    fi
		elif [ -f "${basedir}/${h}" ]; then
		    mkdir -p $(dirname "${outdir}/${h}")
		    cp $verbose "${basedir}/${h}" "${outdir}/${h}"
		    break;
		else
		    if [ -n "$verbose" ]; then
			echo $(basename $h) not found in ${subject}_${session}
		    fi
		fi
	    done
	done
	;;

    *)
	echo 'Error: -K argument must be Structural or Functional.'
	exit 1;
esac
