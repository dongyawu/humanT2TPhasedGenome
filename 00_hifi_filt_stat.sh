#!/bin/sh
#SBATCH --job-name=C049
#SBATCH --partition all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem=250g
#SBATCH --time=900:00:00

date

ID="C049-CHA-N09-01"
threads=60

mv */*hifi_reads.bam* ./

ls *.hifi_reads.bam|while read a
do
	pre=`echo $a|sed 's/.hifi_reads.bam//g'`
	sh /slurm/users/wudongya/software/HiFiAdapterFilt-master/hifiadapterfilt.sh -l 44 -m 97 -t ${threads} -p $pre
	rm -f ${pre}.hifi_reads.contaminant.blastout
done

list=`ls *filt.fastq.gz | xargs`
zcat $list | ~/software/anaconda/bin/seqkit stats -aT -j ${threads} -t dna > $ID\_hifi.stat

