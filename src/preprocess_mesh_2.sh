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

/usr/bin/perl src/preprocess_parse_ascii2.pl $1 $2 $3 $4

cd data/mesh
sort -i mesh_term.txt | uniq > pre_mesh_term.txt
sort -i mesh_synonym.txt | uniq > pre_mesh_synonym.txt
cat pre_mesh_term.txt > mesh_term.txt
cat pre_mesh_synonym.txt > mesh_synonym.txt
rm pre_mesh_term.txt
rm pre_mesh_synonym.txt
