#!/bin/sh
#SBATCH --job-name=flyeC019_binONT
#SBATCH --partition=all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100g
#SBATCH --time=900:00:00

date
threads=20
famID="C019-CHA-E19"
yak2="/slurm/home/zju/zhanglab/wudongya/APG/NGS/${famID}-02/2update.yak"
yak3="/slurm/home/zju/zhanglab/wudongya/APG/NGS/${famID}-03/3update.yak"
dir="/slurm/home/zju/zhanglab/wudongya/APG/Nanopore/${famID}-01/binning_100k/haplotype"

#rm -rf $dir/0-kmers

#echo $dir/haplotype-Pat.fasta.gz
#flye --nano-raw $dir/haplotype-Pat.fasta.gz --genome-size 3g --threads ${threads} --out-dir Pat

#echo $dir/haplotype-Mat.fasta.gz
#flye --nano-raw $dir/haplotype-Mat.fasta.gz --genome-size 3g --threads ${threads} --out-dir Mat

echo "flye done!"
date

for i in {"Mat","Pat"};
do
echo "${i}"
mv ${i}/assembly.fasta ${famID}_flye_${i}_ctg.fasta
N50 ${famID}_flye_${i}_ctg.fasta ${famID}_flye_${i}_ctg.n50 10000
yak trioeval ${yak2} ${yak3} ${famID}_flye_${i}_ctg.fasta -t ${threads} > ${famID}_flye_${i}_ctg.ye
echo "print Syntent for ${i}!"
sh /slurm/home/zju/zhanglab/wudongya/software/asm2ref/unimap/run_unimap_dotplot.sh /slurm/home/zju/zhanglab/wudongya/APG/reference/CHM13v2m.fasta ${famID}_flye_${i}_ctg.fasta ${famID}_flye_${i}_ctg
done

