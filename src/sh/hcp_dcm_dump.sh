#!/bin/sh

host=intradb.humanconnectome.org

while getopts "f:p:r:s:u:" opt; do
    case $opt in
	f)
	    fields="${fields}&field=$OPTARG";
	    ;;

	p)
	    project=$OPTARG
	    ;;

	r)
	    scan=$OPTARG
	    ;;
	s)
	    session=$OPTARG
	    ;;

	u)
	    OIFS=$IFS
	    IFS=":"
	    declare -a creds=($OPTARG)
	    IFS=$OIFS
	    user=${creds[0]}
	    pass=${creds[1]}
	    if [ "x$pass" == "x" ]; then
		read -rs -p "Password for ${user}@${host}: " pass
		echo
	    fi
	    ;;

	\?)
	    echo 'Usage: hcp_dcm_dump -u USER -s SESSION [-p PROJECT] [-r SCAN] [-f FIELD]...' >&2
	    exit 1
	    ;;

	:)
	    echo 'Option -$OPTARG requires an argument.' >&2
	    exit 1
	    ;;

    esac
done


url="https://${host}/data/services/dicomdump?src=/archive"

project="HCP_Phase2"


if [ "x$user" == "x" ]; then
    echo "Must specify HCP username (-u option)."
    exit 2
fi
if [ "x$session" == "x" ]; then
    echo "Must specify session ID (-s option)."
    exit 2
fi

url="${url}/projects/${project}/experiments/${session}"
if [ "x$scan" != "x" ]; then
    url="${url}/scans/${scan}"
fi

curl -fsS -u $user:$pass "${url}${fields}&format=csv" | sed -e 's/^"//' -e 's/"$//' | awk -F '(",")|(,")|(",)' '{printf("%s %s %-41s # %s %s\n",$1,$3,sprintf("[%s]",$4),$5,$2)}'
if [ $? != 0 ]; then
    echo request failed: $?
    exit 3
fi
