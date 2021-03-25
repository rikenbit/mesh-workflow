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

# Search all journal
ls -dF ${CURRENTDIRECTORY}/data/pubmed/zip/zip/*.xml > xml.txt

rm ${CURRENTDIRECTORY}/data/pubmed/*_pubmed*.txt

rm ${CURRENTDIRECTORY}/data/pubmed/pubmed.txt
rm ${CURRENTDIRECTORY}/data/pubmed/pmc.txt
rm ${CURRENTDIRECTORY}/data/pubmed/mesh.txt

counter=0
# Parse XML
while read line
do
	txt=${line}
	echo $txt

	counter=`expr $counter + 1`
	echo $counter
	sed -e "s|XXXXX|$txt|g" template/program/PubMed_Template | sed -e "s|DDIIRR|$CURRENTDIRECTORY|g"  > pre_PubMed_$counter.sh
	sed -e "s|YYYYY|$counter|g" pre_PubMed_$counter.sh > PubMed_$counter.sh
	chmod +x PubMed_$counter.sh
	qsub PubMed_$counter.sh
	#rm PubMed_$counter.sh
	rm pre_PubMed_$counter.sh
done<xml.txt

# ジョブ監視
sed -e "s|XXXXX|PubMed_|g" template/program/Sleep_Template > Sleep_PubMed.sh
chmod +x Sleep_PubMed.sh
./Sleep_PubMed.sh
rm Sleep_PubMed.sh

cd ${CURRENTDIRECTORY}/data/pubmed

cat pubmed_pubmed*.txt > pubmed.txt
cat pmc_pubmed*.txt > pmc.txt
cat mesh_pubmed*.txt > mesh.txt

# Remove duplicated row
for FILE in pubmed.txt pmc.txt mesh.txt
do
  mkdir -p ${CURRENTDIRECTORY}/tmppremesh
  sort -i ${FILE} -T ${CURRENTDIRECTORY}/tmppremesh > sorted_${FILE}
  uniq sorted_${FILE} > pre_${FILE}
  rm -rf ${CURRENTDIRECTORY}/tmppremesh
done


# Extract 1-3 columns
sed -e "s|DDIIRR|$CURRENTDIRECTORY|g" ${CURRENTDIRECTORY}/template/program/extract_1to3.query_Template > extract_1to3.query
sqlite3 ${CURRENTDIRECTORY}/data/SQLite/MeSH.db.sqlite < extract_1to3.query

sort pre_meshterm2.uniq.txt | uniq > meshterm2.uniq.txt

# Join 3 table (gene2pubmed, pre_mesh.txt, meshterm2.uniq.txt)
python ${CURRENTDIRECTORY}/src/join.py ${CURRENTDIRECTORY}

cd ${CURRENTDIRECTORY}/data/gene2pubmed

while read line
do
	txt=${line}
	echo $txt
	sort pre_${line}.txt | uniq | sed -e "s/$/\tgene2pubmed/g" > ${line}.txt

done<${CURRENTDIRECTORY}/ID/115ID/threename.txt

rm pre_*