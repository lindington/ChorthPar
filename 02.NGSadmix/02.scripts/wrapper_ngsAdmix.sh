#!/bin/bash
set -e
shopt -s extglob

### ngsAdmix wrapper script to avoid local maxima
# Version: v0.0.2
# - runs ngsAdmix N_REP times
# - picks REP with highest LKL
#
# Usage:
#    wrapper_ngsAdmix.sh [ngsAdmix OPTIONS]



#################
### Variables ###
#################
#Set programs folder
if [[ ! $NGSADMIX_BIN ]] || [[ ! -f $NGSADMIX_BIN ]] || [[ ! -x $NGSADMIX_BIN ]]; then
    if [[ ! `type -P ngsAdmix` ]]; then
	if [[ ! `type -P NGSadmix` ]]; then
	    echo "ERROR: ngsAdmix binary not found in \$PATH or in \$NGSADMIX_BIN."
	    exit -1
	else
	    NGSADMIX_BIN=`type -P NGSadmix`
	fi
    else
	NGSADMIX_BIN=`type -P ngsAdmix`
    fi
fi



# Set TMP folder
if [ -z $TMP_DIR ]; then
    TMP_DIR=$HOME/scratch
fi
TMP_DIR=$TMP_DIR/ngsAdmix_$USER

# Set number of replicates
if [[ ! $N_REP ]]; then
#    N_REP=20
    N_REP=50
fi



#################
### Functions ###
#################
in_array() {
    idx=""
    local CNT=0
    local hay needle=$1
    shift
    for hay; do
        CNT=$((CNT+1))
        if [[ $hay == $needle ]]; then
            idx=$CNT
            return 0
        fi
    done
    return 0
}



#######################
### Check arguments ###
#######################
args=( $@ )
mkdir -p $TMP_DIR
ID=$TMP_DIR/ngsAdmix_$RANDOM

# find -outgenos argument
in_array "-outgenos" "${args[@]}"
if [[ $idx -eq 0 ]]; then
    in_array "-g" "${args[@]}"
fi
GENO_idx=$idx

# find -outfiles argument
in_array "-outfiles" "${args[@]}"
if [[ $idx -eq 0 ]]; then
    in_array "-o" "${args[@]}"
fi
if [[ $idx -eq 0 ]]; then
    echo "ERROR: could not find argument for output files (-o / -outfiles)"
    exit -1
fi
OUT_idx=$idx
OUT=${args[$OUT_idx]}

# DEBUG mode; does not remove files when it ends
# -debug 0 = disables debug mode
# -debug 1 = debug mode (does not delete temp files)
in_array "-debug" "${args[@]}"
DEBUG=0
if [[ $idx -ne 0 ]]; then
    DEBUG=${args[$idx]}
    args[$((idx-1))]=""
    args[$idx]=""
fi


##########################
### Run each replicate ###
##########################
for REP in `seq -w 1 $N_REP`
do
    args[$OUT_idx]=$ID.REP_$REP
    $NGSADMIX_BIN ${args[@]}
done
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; then
    echo "ERROR: ngsAdmix terminated with errors"
    exit $EXIT_CODE
fi



##########################
### Get best replicate ###
##########################
if [ -s $ID.REP_*(0)1.log ]; then
    fgrep 'best like=' $ID.REP_*.log | perl -p -e 's/[:=]/ /g' | awk '{print $1"\t"$4}' | sort -k 2,2gr > $ID.log
    BEST=`awk 'NR==1{sub(".[^.]*$","",$1); print $1}' $ID.log`

    if [ -s $BEST.log ]; then
	mv $BEST.log $OUT.log
	mv $BEST.filter $OUT.filter
	mv $BEST.fopt.gz $OUT.fopt.gz
	if [[ $GENO_idx -ne 0 ]]; then
	    mv $BEST.geno.gz $OUT.geno.gz
	fi
	mv $BEST.qopt $OUT.qopt
    else
	echo "ERROR: invalid BEST output files"
	exit -1
    fi
else
    echo "ERROR: no output files found"
    exit -1
fi

# Clean-up
#if [[ $DEBUG -eq 0 ]]; then
#    rm -f $ID.REP_*
#fi
