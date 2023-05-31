#!/bin/sh
#SBATCH --job-name=ontC020
#SBATCH --partition all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

ID="C020-CHA-E20-01"
threads=50

mv */*pass.fastq.gz ./
mv */*/*pass.fastq.gz ./
mv */*/*/*pass.fastq.gz ./
mv */*/*/*/*pass.fastq.gz ./

ls *pass.fastq.gz|while read a
do
        pre=`echo $a|sed 's/.pass.fastq.gz//g'`
        echo $pre
        gunzip -c $pre\.pass.fastq.gz | ~/software/anaconda/bin/NanoFilt -l 100000 | gzip > $pre.pass_100k.fastq.gz
done

cat slurm* | grep "over" | cut -f8 -d" " | perl -npe "s/‘//" | perl -npe "s/’//" > left_bam
i=1
for bam in `cat left_bam`
do
        mv $bam ${i}.pass.fastq.gz
        echo $bam
        echo ${i}
        gunzip -c ${i}\.pass.fastq.gz | ~/software/anaconda/bin/NanoFilt -l 100000 | gzip > ${i}.pass_100k.fastq.gz
        let i+=1
done

nanofq=`ls *pass_100k.fastq.gz |xargs`
~/software/anaconda/envs/verkko/bin/NanoStat --fastq ${nanofq} -t ${threads} --tsv -o ./ > ${ID}_ont100k.stat
date
