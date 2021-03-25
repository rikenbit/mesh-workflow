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

if [ ! -s $1 ]; then
	touch $2
else
	sqlitequery=`echo $RANDOM`.query
	today=`date +%d-%b-%Y`
	sname=`echo $5 | sed -e "s|_| |g" | sed -e "s|LLLLL|(|g" | sed -e "s|RRRRR|)|g"`
	cname=`echo $6 | sed -e "s|_| |g"`
	sed -e "s|SSSSS|$today|g" $3 | sed -e "s|TTTTT|$1|g" | sed -e "s|UUUUU|$4|g" | sed -e "s|YYYYY|$sname|g" | sed -e "s|ZZZZZ|$cname|g" | sed -e "s|XXXXX|$7|g" > $sqlitequery
	sqlite3 $2 < $sqlitequery
	rm -rf $sqlitequery
fi

