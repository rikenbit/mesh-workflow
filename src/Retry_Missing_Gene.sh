#!/bin/bash


for SPECIE in $(ls data/gene/*.gi | sed -e 's/\.gi//' | sed -e 's/^data\/gene\///')
do
  echo ${SPECIE}
  ./Missing_Gene_Retrieve_All.sh ${SPECIE}
done
