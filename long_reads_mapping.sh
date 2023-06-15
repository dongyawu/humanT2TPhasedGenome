#!/usr/bin/bash
#SBATCH --job-name=C010cor
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=80
#SBATCH --mem=200g
#SBATCH --time=900:00:00

date

threads=80
famID="C010-CHA-E10"

Patref="${famID}_Pat_R4_R5_R3_R6.paf.fasta"
#meryl count threads=${threads} k=15 output Pat_merylDB $Patref
#meryl print threads=${threads} greater-than distinct=0.9998 Pat_merylDB > ${famID}_Pat_repetitive_k15.txt

#date
#echo "hifi mapping start!"
#winnowmap -W ${famID}_Pat_repetitive_k15.txt -t ${threads} -ax map-pb $Patref <(zcat ${hifidir}/binning/haplotype/haplotype-Pat.fasta.gz ${hifidir}/binning/haplotype/haplotype-unknown.part_001.fasta.gz) | samtools view -bh -@ ${threads} > ${famID}_Pat_hifi.bam
#echo "hifi mapping done!"
date
samtools view -q 30 -F 256 -bh ${famID}_Pat_hifi.bam -@ ${threads} > ${famID}_Pat_hifi_q30F256.bam
samtools sort -@ ${threads} ${famID}_Pat_hifi_q30F256.bam  > ${famID}_Pat_hifi_q30F256.sort.bam
rm -f ${famID}_Pat_hifi_q30F256.bam
samtools depth -@ ${threads} ${famID}_Pat_hifi_q30F256.sort.bam > ${famID}_Pat_hifi_q30F256.depth
#perl /slurm/users/wudongya/APG/assembly/00_get_fasta_length.pl ${famID}_Pat_R4_R5_R3_R6.paf.fasta
#perl /slurm/users/wudongya/APG/assembly/01_generation_windows.pl ${famID}_Pat_R4_R5_R3_R6.paf.fasta_length 10000 
perl /slurm/users/wudongya/APG/assembly/02_depth_stat_windows.pl ${famID}_Pat_R4_R5_R3_R6.paf.fasta_length.10000.windows ${famID}_Pat_hifi_q30F256.depth

#date
#echo "ONT mapping start!"
#winnowmap -W ${famID}_Pat_repetitive_k15.txt -t ${threads} -ax map-ont $Patref ${ontdir}/binning_100k/haplotype/haplotype-Pat.fasta.gz | samtools view -bh -@ ${threads} > ${famID}_Pat_ONT.bam
#echo "ONT mapping done!"
date
samtools view -q 30 -F 256 -bh ${famID}_Pat_ONT.bam -@ ${threads} > ${famID}_Pat_ONT_q30F256.bam
samtools sort -@ ${threads} ${famID}_Pat_ONT_q30F256.bam > ${famID}_Pat_ONT_q30F256.sort.bam
rm -f ${famID}_Pat_ONT_q30F256.bam
samtools depth -@ ${threads} ${famID}_Pat_ONT_q30F256.sort.bam > ${famID}_Pat_ONT_q30F256.depth
perl /slurm/users/wudongya/APG/assembly/02_depth_stat_windows.pl ${famID}_Pat_R4_R5_R3_R6.paf.fasta_length.10000.windows ${famID}_Pat_ONT_q30F256.depth

