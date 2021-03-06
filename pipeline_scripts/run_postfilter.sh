#!/bin/bash

# specify a sequencing run directory
RUN=$1

# get known directory names
DIR="/home/idies/workspace/covid19/sequencing_runs/$RUN/artic-pipeline/4-draft-consensus"

# make and save output directory
outdir="/home/idies/workspace/covid19/sequencing_runs/$RUN/artic-pipeline/5-post-filter/"
if [ ! -d $outdir ]; then
        mkdir $outdir
fi

# save path to NTC depthfile and mpileup
ntc_depthfile="/home/idies/workspace/covid19/sequencing_runs/$RUN/artic-pipeline/4-draft-consensus/NTC*nanopolish.primertrimmed.rg.sorted.del.depth"
ntc_bamfile="/home/idies/workspace/covid19/sequencing_runs/$RUN/artic-pipeline/4-draft-consensus/NTC*nanopolish.primertrimmed.rg.sorted.bam"

# save path to nextstrain vcf
vcf_next="/home/idies/workspace/covid19/nextstrain/latest/alpha/alignments.vcf"

# save path to case definitions
case_defs="/home/idies/workspace/covid19/code/ncov/pipeline_scripts/variant_case_definitions.csv"

# save path to reference genome
reference="/home/idies/workspace/covid19/ncov_reference/sequence.fasta"

# save path to amplicon sites data
amplicons="/home/idies/workspace/covid19/sequencing_runs/amplicons"

for consfile in $DIR/*nanopolish.consensus.fasta; do

	sample=${consfile##*/}
	samplename=${sample%%_*}

	# loop through all NTC samples
	if [ ! "$samplename" = "NTC" ]; then

		echo $samplename

		vcffile=$DIR/$samplename*all_callers.combined.vcf
		mpileup="$DIR/$samplename*mpileup"
		depth="$DIR/$samplename*nanopolish.primertrimmed.rg.sorted.del.depth"
		consensus="$DIR/$samplename*nanopolish.consensus.fasta"
		prefix=`echo $consensus`
		prefix=${prefix##*/}
		prefix=${prefix%%.*}

		# run script
		python /home/idies/workspace/covid19/code/ncov/pipeline_scripts/vcf_postfilter.py \
		--vcffile $vcffile \
		--mpileup $mpileup \
		--depthfile $depth \
		--consensus $consensus \
		--ntc-bamfile $ntc_bamfile \
		--ntc-depthfile $ntc_depthfile \
		--vcf-nextstrain $vcf_next \
		--case-defs $case_defs \
		--ref-genome $reference \
		--amplicons $amplicons \
		--ns-snp-threshold 2 \
		--outdir $outdir \
		--prefix $prefix
	fi
done

