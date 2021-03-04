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

Rscript src/qualifier.R $@

cd data/mesh
sort -i qualifier.txt | uniq > pre_qualifier.txt
cat pre_qualifier.txt > qualifier.txt
rm pre_qualifier.txt