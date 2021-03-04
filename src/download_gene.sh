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

cd data/gene
# wget ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz
# gunzip gene2accession.gz
# split -l 5000000 gene2accession gene2accession

CountG2A=`ls gene2accession[a-z][a-z] | wc -l`
if [ $CountG2A -gt 0 ]; then
    echo GENE2ACCESSION files are saved
    touch ../../check/download_gene
else
    echo GENE2ACCESSION files are not found...
    exit 1
fi
