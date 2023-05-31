#!/bin/sh
#SBATCH --job-name=C044-01
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

threads=40
##1, offspring;2, maternal; 3, paternal
ID=1

mv */*fq.gz ./

echo "DATA QC and FILTERING..."
ls *_1.fq.gz|while read a
do
        pre=`echo $a|sed 's/_1.fq.gz//g'`
        echo $pre
        ~/software/anaconda/bin/fastp -i $pre\_1.fq.gz -o $pre\_1.clean.fq.gz -I $pre\_2.fq.gz -O $pre\_2.clean.fq.gz -j $pre.json -h $pre.html -u 30 -q 20 -w $threads
done
echo "QC Finished!"

echo "Yak K-mer..."
################
#1.yak offspring  #2.yak paternal  #3.yak maternal
~/software/anaconda/bin/yak count -k31 -b37 -o ${ID}.yak $all -t ${threads} <(zcat *.clean.fq.gz) <(zcat *.clean.fq.gz)
echo "yak K-mer Finished!"

echo "Meryl K-mer..."
mem="200g"
ls *.clean.fq.gz|while read a
do
        pre=`echo $a|sed 's/.clean.fq.gz//g'`
        /slurm/soft/meryl/1.3/bin/meryl k=30 threads=${threads} memory=$mem count compress output $pre\.meryl $pre\.clean.fq.gz
done
/slurm/soft/meryl/1.3/bin/meryl threads=${threads} memory=$mem union-sum output ${ID}\.merys *.meryl
rm -rf *.meryl
mv ${ID}\.merys ${ID}\.meryl
echo "Meryl K-mer Finished!"

echo "Finished!"
date
