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

if [ ! -s $1 ] || [ ! -s $2 ]; then
	touch $3
else
	sqlitefile=`echo $RANDOM`.sqlite
	sqlitequery=`echo $RANDOM`.query
	sed -e "s|XXXXX|$1|g" src/rbbh.query | sed -e "s|YYYYY|$2|g" | sed -e "s|ZZZZZ|$3|g" > $sqlitequery
	sqlite3 $sqlitefile < $sqlitequery
	rm -rf $sqlitefile $sqlitequery
fi
