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

mkdir -p data/pubmed
cd data/pubmed
lftp -c mirror ftp://ftp.ncbi.nlm.nih.gov/pubmed/baseline
cd baseline
md5sum -c *.md5
if [ $? -ne 0 ]; then
    echo MD5sum does not match
    exit 1
fi
gzip -d *.gz

CountZIP=`ls *.xml | wc -l`
CountMD5=`ls *.gz.md5 | wc -l`
if [ $CountZIP -eq $CountMD5 ]; then
    echo ZIP file is properly unzipped
    touch ../../../check/download_pubmed
else
    echo ZIP file is not properly unzipped...
    exit 1
fi
