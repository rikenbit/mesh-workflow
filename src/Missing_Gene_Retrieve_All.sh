#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Usage: specie(3letter)"
  exit 1
fi
export CURRENTDIRECTORY=$PWD

SPECIE=$1
FORJOINGI=${SPECIE}.forjoin.gi
FORJOINFASTA=${SPECIE}.forjoin.fasta

OUTPUTDIR=data/newgene

cat data/gene/${SPECIE}.gi |sort -u|uniq > ${FORJOINGI}
cat data/gene/${SPECIE}.fasta | grep ^\> | cut  -d' ' -f1 | cut -d'>' -f2 | cut -d'|' -f2 | sort -u|uniq > ${FORJOINFASTA}

#
rm ${OUTPUTDIR}/${SPECIE}.1
rm ${OUTPUTDIR}/${SPECIE}.2

diff -s ${FORJOINGI} ${FORJOINFASTA} > /dev/null
RET=$?

if [ ${RET} -ne 0 ];
then
  echo "SOMETHING DIFF ${SPECIE}"

  join -v 1 ${FORJOINGI} ${FORJOINFASTA} > ${OUTPUTDIR}/${SPECIE}.1
  join -v 2 ${FORJOINGI} ${FORJOINFASTA} > ${OUTPUTDIR}/${SPECIE}.2

  sed -e "s|XXXXX|$SPECIE|g" Missing_Gene_Retrieve_fasta_sh_Template | sed -e "s|DDIIRR|$CURRENTDIRECTORY|g" > Missing_Gene_Retrieve_fasta_sh_$SPECIE.sh
  chmod +x Missing_Gene_Retrieve_fasta_sh_$SPECIE.sh
  #qsub Missing_Gene_Retrieve_fasta_sh_$SPECIE.sh
  exit
else
  touch ${OUTPUTDIR}/${SPECIE}.1
  touch ${OUTPUTDIR}/${SPECIE}.2
fi


