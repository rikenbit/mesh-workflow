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

DFILE="d"$1".bin"
QFILE="q"$1".bin"

cd data/mesh
wget ftp://nlmpubs.nlm.nih.gov/online/mesh/MESH_FILES/asciimesh/$DFILE
wget ftp://nlmpubs.nlm.nih.gov/online/mesh/MESH_FILES/asciimesh/$QFILE

ls {$DFILE,$QFILE} >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo d2021.bin/q2021.bin are saved
    touch ../../check/download_mesh
else
    echo d2021.bin/12021.bin are not found...
    exit 1
fi
