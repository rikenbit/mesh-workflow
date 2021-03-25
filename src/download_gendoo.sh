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

mkdir -p data/gendoo
cd data/gendoo
wget http://gendoo.dbcls.jp/data/score.gene.anabaena.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.anabaena.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.anabaena.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.anabaena.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.anabaena.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.arabi.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.arabi.other.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.other.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.other.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.other.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.arabi.other.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.human.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.human.other.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.other.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.other.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.other.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.human.other.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.meso.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.meso.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.meso.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.meso.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.miyako.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.miyako.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.miyako.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.miyako.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.miyako.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.mouse.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.mouse.other.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.other.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.other.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.other.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.mouse.other.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.rat.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.rat.other.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.other.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.other.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.other.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.rat.other.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.silkworm.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.coding.F.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.coding.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.silkworm.other.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.other.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.other.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.other.F.tab
wget http://gendoo.dbcls.jp/data/score.gene.silkworm.other.G.tab

wget http://gendoo.dbcls.jp/data/score.gene.synecho.coding.A.tab
wget http://gendoo.dbcls.jp/data/score.gene.synecho.coding.B.tab
wget http://gendoo.dbcls.jp/data/score.gene.synecho.coding.C.tab
wget http://gendoo.dbcls.jp/data/score.gene.synecho.coding.D.tab
wget http://gendoo.dbcls.jp/data/score.gene.synecho.coding.F.tab
wget http://gendoo.dbcls.jp/data/score.gene.synecho.coding.G.tab

CountGENDOO=`ls *.tab | wc -l`
if [ $CountGENDOO -eq 70 ]; then
    echo GENDOO files are saved
    touch ../../check/download_gendoo
else
    echo GENDOO files are not found...
    exit 1
fi
