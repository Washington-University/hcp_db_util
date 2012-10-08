#!/bin/sh
# hcp_copy : make copy of data from HCP archive
# Copyright (c) 2012 Washington University
# Author: Kevin A. Archie <karchie@wustl.edu>

archive=/data/intradb/archive/HCP_Phase2/arc001

while getopts "S:K:o:" opt; do
    case $opt in
	S)
	    subject=$OPTARG
	    ;;

	K)
	    input_packet=$OPTARG
	    ;;

	o)
	    outdir=$OPTARG
	    ;;

	\?)
	    echo 'Usage: arc_session -S subject -K Structural|Functional [-o output-directory]' >&2
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
declare outdir=${outdir:-$subject}
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
T1w/Native/
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
	)
	do
	    for session in strc xtra xtrb; do
		declare basedir="${archive}/${subject}_${session}/RESOURCES/Details"
		# if component ends in *, take all contained files
		# but don't descend into subdirectories
		echo $h | grep '/\*$' >/dev/null
		if [ $? -eq 0 ]; then
		    declare name=$(echo $h | sed 's!/\*$!!')
		    echo "listing $h as ${name}";
		    declare dir="${basedir}/${name}"
		    mkdir -p "${outdir}/${name}";
		    for file in $(ls -p "$dir" | grep -v /); do
			cp -v "${dir}/$file" "${outdir}/${name}/$file"
		    done
		else
		    declare path="${basedir}/${h}"
		    if [ -d "$path" ]; then # is this ever valid anymore?
			tar c -C "$basedir" "$h" | tar xv -C "$outdir"
			break
		    elif [ -f "$path" ]; then
			mkdir -p $(dirname "${outdir}/${h}")
			cp -v "$path" "${outdir}/${h}"
			break;
		    else
			echo $path not found
		    fi
		fi
	    done
	done
	;;

    functional)
	echo 'Error: functional retrieval not yet implemented.'
	exit 2;
	;;

    *)
	echo 'Error: -K argument must be Structural or Functional.'
	exit 1;
esac
