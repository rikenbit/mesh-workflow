#!/bin/bash
#$ -l nc=4
#$ -p -50
#$ -r yes
#$ -q node.q

#SBATCH -n 4
#SBATCH --nice=50
#SBATCH --requeue
#SBATCH -p node03-06
SLURM_RESTART_COUNT=2

cd data/pubmed
lftp -c mirror ftp://ftp.nlm.nih.gov/nlmdata/.medleasebaseline/zip
cd zip
unzip -o \*.zip