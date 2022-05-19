#!/bin/bash

FASTQ=$1
FASTA=$2

BASE_DIR=/home/mdh/shared/software_modules/dryad/3.0
WORKING_DIR=`realpath $(pwd)`
NEXTFLOW_CONFIG=$BASE_DIR/nextflow_mdh.config
CGSE_PATH=$BASE_DIR/singularity/core-genome-size-estimation_1.2.0-cv1-191023.sif
DRYAD_DIR=$WORKING_DIR/dryad_results
BAM_DIR=$WORKING_DIR/dryad_results/mapping/bams
DEPTH=10
CGSE_OUT=$WORKING_DIR/dryad_results/cgse

module load nextflow/21.04.3

export NXF_ANSI_LOG=false

# Run Dryad using FASTA reference:
if [ $FASTA ]; then

	dryad.nf \
		-c $NEXTFLOW_CONFIG \
		--reads $FASTQ \
		--snp_reference $FASTA \
		-resume 

	# Make a directory for only reference BAM files:
	mkdir $BAM_DIR/reference

	# Make links to BAM files in new reference directory:
	cp $BAM_DIR/*reference.sorted* $BAM_DIR/reference

	# Run core-genome-size-estimation script:
	singularity exec \
		-e \
		-B $WORKING_DIR,.:/data \
		--pwd /data \
		$CGSE_PATH estimate_core_genome_from_bam.pl \
		-bam $BAM_DIR/reference \
		-genome $FASTA \
		-depth $DEPTH \
		-out $CGSE_OUT


# Otherwise run reference-free:
else

	dryad.nf \
		-c $NEXTFLOW_CONFIG \
		--reads $FASTQ \
	-resume

fi

chmod -R 770 ./
