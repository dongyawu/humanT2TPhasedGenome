#!/bin/sh
#SBATCH --job-name=C081
#SBATCH --partition all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem=250g
#SBATCH --time=900:00:00

date

ID="C081-CHA-C01-01"
threads=60

###Note the bam file suffix!!!
mv */*hifi_reads.bam* ./
mv */*/*hifi_reads.bam* ./

ls *.hifi_reads.bam|while read a
do
	pre=`echo $a|sed 's/.hifi_reads.bam//g'`
	hifiadapterfilt.sh -l 44 -m 97 -t ${threads} -p $pre
	rm -f ${pre}.hifi_reads.contaminant.blastout
done

list=`ls *filt.fastq.gz | xargs`
zcat $list | ~/anaconda3/bin/seqkit stats -aT -j ${threads} -t dna > $ID\_hifi.stat

