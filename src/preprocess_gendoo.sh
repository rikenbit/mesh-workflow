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

output=$1
threename=`echo $output | sed -e 's|output/gendoo/||' | sed -e 's|.txt||'`
ARRAY=$@
size=${#ARRAY[@]}

for((i=0;i<$size;i++))
do
	tabfile=${ARRAY[$i]}
	if [[ $tabfile =~ ".A.tab" ]]; then
		cat $tabfile | grep -v Gene | awk 'BEGIN{OFS="\t"}{print $1,$4,"A","NA","gendoo"}' | sort -i | uniq \
		> "output/gendoo/"$threename"_A"
	fi
	if [[ $tabfile =~ ".B.tab" ]]; then
		cat $tabfile | grep -v Gene | awk 'BEGIN{OFS="\t"}{print $1,$4,"B","NA","gendoo"}' | sort -i | uniq \
		> "output/gendoo/"$threename"_B"
	fi
	if [[ $tabfile =~ ".C.tab" ]]; then
		cat $tabfile | grep -v Gene | awk 'BEGIN{OFS="\t"}{print $1,$4,"C","NA","gendoo"}' | sort -i | uniq \
		> "output/gendoo/"$threename"_C"
	fi
	if [[ $tabfile =~ ".D.tab" ]]; then
		cat $tabfile | grep -v Gene | awk 'BEGIN{OFS="\t"}{print $1,$4,"D","NA","gendoo"}' | sort -i | uniq \
		> "output/gendoo/"$threename"_D"
	fi
	if [[ $tabfile =~ ".F.tab" ]]; then
		cat $tabfile | grep -v Gene | awk 'BEGIN{OFS="\t"}{print $1,$4,"G","NA","gendoo"}' | sort -i | uniq \
		> "output/gendoo/"$threename"_F"
	fi
	if [[ $tabfile =~ ".G.tab" ]]; then
		cat $tabfile | grep -v Gene | awk 'BEGIN{OFS="\t"}{print $1,$4,"G","NA","gendoo"}' | sort -i | uniq \
		> "output/gendoo/"$threename"_G"
	fi
done

# マージ
cat "output/gendoo/"$threename"_"* > $output
rm -rf "output/gendoo/"$threename"_"*
