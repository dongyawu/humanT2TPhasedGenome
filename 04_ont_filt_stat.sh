#!/bin/sh
#SBATCH --job-name=ontC081
#SBATCH --partition all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

ID="C081-CHA-C01-01"
threads=50

###Note the file suffix
mv */*pass.fastq.gz ./
mv */*/*pass.fastq.gz ./
mv */*/*/*pass.fastq.gz ./
mv */*/*/*/*pass.fastq.gz ./

ls *pass.fastq.gz|while read a
do
        pre=`echo $a|sed 's/.pass.fastq.gz//g'`
        echo $pre
        gunzip -c $pre\.pass.fastq.gz | ~/anaconda3/bin/NanoFilt -l 100000 | gzip > $pre.pass_100k.fastq.gz
done

cat slurm* | grep "over" | cut -f8 -d" " | perl -npe "s/‘//" | perl -npe "s/’//" > left_bam
i=1
for bam in `cat left_bam`
do
        mv $bam ${i}.pass.fastq.gz
        echo $bam
        echo ${i}
        gunzip -c ${i}\.pass.fastq.gz | ~/anaconda3/bin/NanoFilt -l 100000 | gzip > ${i}.pass_100k.fastq.gz
        let i+=1
done

nanofq=`ls *pass_100k.fastq.gz |xargs`
~/anaconda3/bin/NanoStat --fastq ${nanofq} -t ${threads} --tsv -o ./ > ${ID}_ont100k.stat
###seqkit is Alternative

