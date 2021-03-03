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

cd data/gene
wget ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz
gunzip gene2accession.gz
split -l 5000000 gene2accession gene2accession
