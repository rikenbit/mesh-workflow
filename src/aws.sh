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

# Setting
# docker run --rm -it amazon/aws-cli:2.1.32 configure --profile AnnotationContributor
# AWS Access Key ID [****************4F6N]:
# AWS Secret Access Key [****************ENMF]:
# Default region name [ap-northeast-1]:
# Default output format [text]:


# cp
aws --profile AnnotationContributor s3 cp sqlite s3://annotation-contributor/AHMeSHDbs/$1 --recursive --acl public-read

# ls
check=`aws --profile AnnotationContributor s3 ls s3://annotation-contributor/ --recursive`
if [ -n $check ]; then
	touch check/aws
else
	exit 1
fi
