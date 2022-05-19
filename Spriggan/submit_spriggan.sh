#!/bin/bash

FASTQ=$1

BASEDIR=/home/mdh/shared/software_modules/spriggan/1.1.2
NEXTFLOW_CONFIG=$BASEDIR/nextflow_mdh.config
SPRIGGAN_DIR=`pwd`/spriggan_results
module load nextflow/21.04.3

export NXF_ANSI_LOG=false

spriggan.nf \
	-c $NEXTFLOW_CONFIG \
	--reads $FASTQ \
	-resume

chmod -R 770 ./
