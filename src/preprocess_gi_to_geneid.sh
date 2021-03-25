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

if [ ! -s $1 ] || [ ! -s $2 ] || [ ! -s $3 ] || [ ! -s $4 ]; then
	touch $5
else
	sqlitefile=`echo $RANDOM`.sqlite
	sqlitequery=`echo $RANDOM`.query
	sname=`echo $4 | sed -e "s|_| |g"`
	sed -e "s|XXXXX|$1|g" src/gi_to_geneid.query | sed -e "s|YYYYY|$2|g" | sed -e "s|ZZZZZ|$3|g" | sed -e "s|SSSSS|$sname|g" | sed -e "s|TTTTT|$6 $7|g" | sed -e "s|UUUUU|$5_pre|g" > $sqlitequery
	sqlite3 $sqlitefile < $sqlitequery
	sort $5_pre | uniq > $5
	rm -rf $sqlitefile $sqlitequery $5_pre
fi
