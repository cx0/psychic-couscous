#!/usr/bin/bash
#$ -cwd
#$ -l h_vmem=8G
#$ -l h_rt=01:00:00

####################################################################################
## create virtual environment to run `svtyper`
## onuralp@tako:~$ conda create -n svtyper_env python=2.7
## onuralp@tako:~$ conda install -n svtyper_env -c bioconda svtyper
## onuralp@tako:~$ source activate svtyper_env
## (svtyper_env) onuralp@tako:~$ svtyper
## usage: svtyper [-h] [-i FILE] [-o FILE] -B FILE [-T FILE] [-l FILE] [-m INT]
##             [-n INT] [-q] [--max_reads INT] [--max_ci_dist INT]
##             [--split_weight FLOAT] [--disc_weight FLOAT] [-w FILE]
##             [--verbose]
## svtyper: error: argument -B/--bam is required
###################################################################################

# if you want to call & genotype structural variants in a single sample with
# sample id "case001a1" submit this job as `qsub -v SAMPLE="case001a1" call_and_genotype_sv.sh

# directory with processed BAMs (e.g., cases/case001_wes/results/)
BAM_DIR="~/cases/case001_wes/results/"

# set the directory where `lumpy` is located
LUMPY_HOME="~/lumpy-sv/"

# generate discordants and splitters using `samtools`
samtools view -b -F 1294 $BAM_DIR\/$SAMPLE\.bam > $SAMPLE\.discordants.unsorted.bam
samtools view -h $BAM_DIR\/$SAMPLE\.bam | $LUMPY_HOME\/scripts/extractSplitReads_BwaMem -i stdin | samtools view -Sb - > $SAMPLE\.splitters.unsorted.bam

# sort BAMs
samtools sort $SAMPLE\.discordants.unsorted.bam > $SAMPLE\.discordants.sorted.bam
samtools sort $SAMPLE\.splitters.unsorted.bam > $SAMPLE\.splitters.sorted.bam

# run `lumpyexpress` if you do not know what you are doing (otherwise tinker with `lumpy`)

$LUMPY_HOME\/scripts/lumpyexpress -B $BAM_DIR\/$SAMPLE\.bam -S $SAMPLE\.splitters.sorted.bam -D $SAMPLE\.discordants.sorted.bam -o $SAMPLE\.events.vcf

##################################################################################
## troubleshoot: in case there is a path issue with executables when calling 
## either `lumpy` or its dependencies such as `sambamba` 
## export PATH=$PATH:/net/home/onuralp/lumpy-sv/bin/
## export PATH=$PATH:/net/home/onuralp/sambamba/bin/
## source ~/.bashrc
#################################################################################

# run `svtyper` using output files generated by `lumpyexpress`
# note: you probably don't need the splitters for this step
svtyper -i $SAMPLE\.events.vcf -B $BAM_DIR\/$SAMPLE\.bam -S $SAMPLE\.splitters.sorted.bam > $SAMPLE\.gt.vcf

