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

Rscript src/preprocess_mesh_offspring.R $@

sort -i $2 | uniq > $2_pre
cat $2_pre > $2
rm $2_pre