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

cd data/pubmed
lftp -c mirror ftp://ftp.nlm.nih.gov/nlmdata/.medleasebaseline/zip
cd zip
unzip -o \*.zip

CountZIP=`ls zip/*.zip | wc -l`
CountMD5=`ls zip/*.zip.md5 | wc -l`
if [ $CountZIP -eq $CountMD5 ]; then
    echo ZIP file is properly unzipped
    touch ../../check/download_pubmed
else
    echo ZIP file is not properly unzipped...
    exit 1
fi
