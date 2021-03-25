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

perl src/download_fasta.pl $1 $2 >> $3

# sed "/</d" $3 > $3_pre
# mv $3_pre $3
