#!/bin/sh
#SBATCH --job-name=R4u_C012
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=100
#SBATCH --mem=500g
#SBATCH --time=900:00:00

date

threads=100
famID="C012-CHA-E12"
hifi=`ls /slurm/home/zju/zhanglab/wudongya/APG/PB/CCS/${famID}-01/*.filt.fastq.gz |xargs`
ont=`ls /slurm/home/zju/zhanglab/wudongya/APG/Nanopore/${famID}-01/*pass_100k.fastq.gz |xargs | sed "s/ /,/g"`
yak2="/slurm/home/zju/zhanglab/wudongya/APG/NGS/${famID}-02/2update.yak"
yak3="/slurm/home/zju/zhanglab/wudongya/APG/NGS/${famID}-03/3update.yak"

echo `hifiasm --version`
echo $famID
echo $hifi
echo $ont
if [ ! -f "$yak2"]; then 
echo "Error: no trio information!"
fi

/slurm/home/zju/zhanglab/wudongya/software/anaconda/bin/hifiasm -1 ${yak2} -2 ${yak3} -o ${famID}_hifiasm_trio_ont -t ${threads} --ul ${ont} ${hifi}

echo "hifiasm_trio_ont done!"
date

##################
### CONVERT GFA to FA && N50 STATISTICS
for i in `ls | grep "p_ctg.gfa" | perl -npe "s/.p_ctg.gfa//"`; do awk '/^S/{print ">"$2"\n"$3}' ${i}.p_ctg.gfa | fold > ${i}_ctg.fa ; N50 ${i}_ctg.fa ${i}_ctg.n50 10000 ; done

for i in `ls | grep "p_ctg.gfa" | perl -npe "s/.p_ctg.gfa//"`; do yak trioeval ${yak2} ${yak3} ${i}_ctg.fa > ${i}_ctg.ye ; done

###################
###SYNTENY PLOT
for hap in `seq 1 2`
do
	echo "print Syntent for Hap${hap}!"
	#CHM13v2
	ref="/slurm/home/zju/zhanglab/wudongya/APG/reference/CHM13v2m.fasta"
	que=$famID"_hifiasm_trio_ont.dip.hap${hap}_ctg.fa"
	output_prefix=$famID"_hifiasm_trio_ont.dip.hap${hap}"
	##unimap
	sh /slurm/home/zju/zhanglab/wudongya/software/asm2ref/unimap/run_unimap_dotplot.sh  $ref $que $output_prefix
	cat $output_prefix.unimap.paf | sort -k6,6 -k8,8n | awk '$2>10000 && $10>500' > $output_prefix.unimap.sort.fil.paf
done

rm -f *bin
