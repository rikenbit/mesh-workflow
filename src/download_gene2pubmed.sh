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

export LC_ALL=C

cd data/gene2pubmed
wget ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz
gzip -d gene2pubmed.gz

if [ -f gene2pubmed ]; then
    echo gene2pubmed is saved
    touch ../../check/download_gene2pubmed
else
    echo gene2pubmed is not found...
    exit 1
fi