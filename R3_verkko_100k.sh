#!/bin/sh
#SBATCH --job-name=verkko_C012_100k
#SBATCH --partition=all
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=60
#SBATCH --mem=100g
#SBATCH --time=900:00:00

threads=60
famID="C012-CHA-E12"

date

##build specific k-mer db
#hapmers.sh /YOUR_PATH/NGS/${famID}-02/2.meryl /YOUR_PATH/NGS/${famID}-03/3.meryl /YOUR_PATH/NGS/${famID}-01/1.meryl

##verkko run
hifi=`ls /YOUR_PATH/PB/CCS/${famID}-01/*.filt.fastq.gz |xargs`
ont=`ls /YOUR_PATH/Nanopore/${famID}-01/*pass_100k.fastq.gz |xargs`

dir='verkko'

#verkko -d $dir --hifi $hifi --nano $ont --threads ${threads} --hap-kmers 2.hapmer.meryl 3.hapmer.meryl trio

echo "verkko done!"
date

###statistic and synteny plot

yak2="/YOUR_PATH/NGS/${famID}-02/2update.yak"
yak3="/YOUR_PATH/NGS/${famID}-03/3update.yak"

for i in `ls ${dir}/| grep "fasta" | grep "haplotype"|perl -npe "s/.fasta//"`;
do
echo $dir/${i} ;
N50 $dir/${i}.fasta $dir/$famID"_"${i}.n50 10000 ;
cat $dir/${i}.fasta | seqkit fx2tab | cut -f 2 | sed -r 's/n+/\n/gi'  | cat -n | seqkit tab2fx | seqkit replace -p "(.+)" -r "Contig{nr}" > $dir/${famID}_${i}_contig.fasta
yak trioeval ${yak2} ${yak3} $dir/${famID}_${i}_contig.fasta -t ${threads} > $dir/$famID"_"${i}.ye
echo "print Syntent for ${i}!"
sh /YOUR_PATH/software/asm2ref/unimap/run_unimap_dotplot.sh /slurm/users/wudongya/APG/reference/CHM13v2m.fasta $dir/${famID}_${i}_contig.fasta $dir/${famID}"_"${i} ;
done

rm -rf 1*
rm -rf 2*
rm -rf 3*
rm -rf read.only.meryl
rm -rf shrd*
rm -f cutoffs.txt
rm -f inherited_hapmers.hist
rm -rf ${dir}/1-buildGraph
rm -rf ${dir}/2-processGraph
rm -rf ${dir}/3-align
rm -rf ${dir}/4-processONT
rm -rf ${dir}/5-untip
rm -rf ${dir}/6-layoutContigs
rm -rf ${dir}/6-rukki
rm -rf ${dir}/7-consensus
date
