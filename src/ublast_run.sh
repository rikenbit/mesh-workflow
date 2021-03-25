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
export OMP_NUM_THREADS=4

if [ ! -s $2 ] || [ ! -s $3 ]; then
	touch $4
else
	$1 -ublast $3 -db $2 -evalue 1e-30 -blast6out $4 -threads 4
fi
