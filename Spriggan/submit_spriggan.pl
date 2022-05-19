#!/usr/bin/perl

use strict;
use warnings;

# --------------------------------------------------------------------------- #

# File:                 submit_spriggan.pl
# Date created:         04 November 2021
# Date last modified:   08 December 2021
# Author:               Eliot Stanton (eliot.stanton@state.mn.us)
# Description:          Wrapper for submission of jobs using Spriggan workflow.

# --------------------------------------------------------------------------- #

# Define help string to be printed when needed:

# Variables passed to this script from the command-line:
my $dir_in	= $ARGV[0];
my $var_email	= $ARGV[1];

# Variables used by this script:
my $var_help    = "\nsubmit_spriggan.pl [DIRECTORY IN] [EMAIL]\n
\tDIRECTORY IN: Directory containing fastq.gz files
\tEMAIL: Email address for job notifications (optional)\n";

my $var_date    = `date +%Y-%m-%d`;
chomp $var_date;
my $var_out     = "submit_spriggan-$var_date.out";
my $var_err     = "submit_spriggan-$var_date.err";

my $var_cpu     = "1";
my $var_mem     = "4gb";
my $var_tmp	= "20gb";

# Data structures used by this script:
my @array_in;
my %hash_in;

# --------------------------------------------------------------------------- #

# If $dir_in is undefined print help message and exit:
unless ( $dir_in ) {

        print "$var_help\nERROR! Please specify directory containing paired FASTQ files.\n";
        exit;

}

# Import list of files in $dir_in to @array_in:
opendir my $dir_read, "$dir_in" or die "$var_help\nCannot open directory $dir_in!";

# Import contents of $dir_read into @array_fastq:
@array_in = readdir $dir_read;

# Close $dir_read;
closedir $dir_read;

# Remove . and .. from @array_in:
splice @array_in, 0, 2;

# Check the contents of @array_in:
for ( my $i = 0; $i < scalar @array_in; $i++ ) {

	# Define $file_fastq:
	my $file_fastq	= $array_in[$i];

	# Skip if the file doesn't end in .fastq or fastq.gz:
	next unless $file_fastq =~ /.fastq$/ || $file_fastq =~ /.fastq.gz$/;

	# Grab the accession number from the file:
	my $var_accession	= ( split /\_/, $file_fastq )[0]; 

	# Store the filename in an array stored in %hash_in using accession
	# as the key:
	push @{ $hash_in{ $var_accession } }, $file_fastq;

#	print "$i: $array_in[$i] - $var_accession\n";

}

# Check that each array in %hash_in contains two entries:
foreach my $var_key ( keys %hash_in ) {

	my @array_temp	= @{ $hash_in { $var_key } };

	my $var_scalar	= scalar @array_temp;

	if ( $var_scalar != 2 ) {

		print "ERROR: unequal number of FASTQ files found!\n";

		exit;

	}

}

# --------------------------------------------------------------------------- #

# Submit job to slurm using sbatch:
if ( $var_email ) {
	print "sbatch \\
		--mail-type=BEGIN,END,FAIL \\
		--mail-user=$var_email \\
		--time=8:00:00 \\
		--nodes=1 \\
		--ntasks=$var_cpu \\
		--mem=$var_mem \\
		--tmp=$var_tmp \\
		--partition small \\
		--output $var_out \\
		--error $var_err \\
		submit_spriggan.sh $dir_in\n";

	system ( "sbatch --mail-type=BEGIN,END,FAIL --mail-user=$var_email \\
	--time=8:00:00 --nodes=1 --ntasks=$var_cpu --mem=$var_mem --tmp=$var_tmp \\
	--partition small --output $var_out --error $var_err submit_spriggan.sh \\
	$dir_in" );
}

else {

        print "sbatch \\
                --time=8:00:00 \\
                --nodes=1 \\
                --ntasks=$var_cpu \\
                --mem=$var_mem \\
		--tmp=$var_tmp \\
                --partition small \\
                --output $var_out \\
                --error $var_err \\
                submit_spriggan.sh $dir_in\n";

        system ( "sbatch --time=8:00:00 --nodes=1 --ntasks=$var_cpu --mem=$var_mem \\
	--tmp=$var_tmp --partition small --output $var_out --error $var_err \\
	submit_spriggan.sh $dir_in" )

}
