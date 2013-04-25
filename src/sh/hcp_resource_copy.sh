#!/bin/sh
# hcp_resource_copy.sh
# Copyright (c) 2013 Washington University School of Medicine
# Author: Kevin A. Archie <karchie@wustl.edu>

if [ 0 -eq $# ]; then
    cat <<EOF
hcp_resource_copy : Copy resource contents from HCP intradb archive
                   to local disk
  git ident $Id: dc4575bc7949abeb1ba0e9ee2cf7da25c2613388 $

Usage:
hcp_resource_copy [OPTIONS]
  -o output-dir    Sets directory into which files will be copied
  -u username      XNAT username (optional; defaults to UNIX username)
  -p password      XNAT password
  -P project       Project label (optional; defaults to HCP_Phase2)
  -S subject       Subject label (optional)
  -X experiment    Experiment label (optional)
  -R resource      Resource label; if omitted, prints list of
                   available resources

Example:

hcp_resource_copy -o ~/data -p zzyxy -S 792564 -R T2w

EOF
    exit 1
fi

SERVER_XNAT_ROOT=/data/intradb/archive
LOCAL_XNAT_ROOT=/HCP/BlueArc/chpc/intradb/archive1

XNAT=https://intradb.humanconnectome.org
user=$USER
project=HCP_Phase2
outdir=$(pwd)

while getopts "o:p:u:v:P:R:S:X:" opt; do
    case $opt in
	o)
	    outdir=$OPTARG
	    ;;

	p)
	    password=$OPTARG
	    ;;

	u)
	    user=$OPTARG
	    ;;

	P)
	    project=$OPTARG
	    ;;

	R)
	    resource=$OPTARG
	    ;;

	S)
	    subject=$OPTARG
	    ;;

	X)
	    experiment=$OPTARG
	    ;;
    esac
done

if [ -z "$password" ]; then
    # TODO: get password from .xnatpass?
    echo 'Error: must set password with -p'
    exit 1
fi

url=${XNAT}/data/projects/${project}
if [ -n "$subject" ]; then
    url=${url}/subjects/${subject}
fi
if [ -n "$experiment" ]; then
    url=${url}/experiments/${experiment}
fi

if [ -n "$resource" ]; then
    server_path=$(curl -sf -u $user:$password ${url}?format=xml |
	grep "^<xnat:resource label=\"$resource\" " |
	tr ' ' '\n' |
	grep '^URI=' |
	cut -f 2 -d '"' |
	xargs dirname)
    if [ $? -ne 0 ]; then
	echo 'unable to retrieve session document'
	exit -1
    fi
    
    local_path=$(echo $server_path | sed -e "s!^$SERVER_XNAT_ROOT!$LOCAL_XNAT_ROOT!")
    
    mkdir -p $outdir
    cp -r $local_path $outdir
else
    curl -sf -u $user:$password ${url}?format=xml | \
	grep "^<xnat:resource " | \
	tr ' ' '\n' | \
	grep '^label=' | \
	cut -f 2 -d '"'
fi
