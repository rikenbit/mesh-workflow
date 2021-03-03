# mesh-workflow

Workflow to construct  [MeSH.db](https://bioconductor.org/packages/release/data/annotation/html/MeSH.db.html), [MeSH.AOR.db](https://bioconductor.org/packages/release/data/annotation/html/MeSH.AOR.db.html), [MeSH.PCR.db](https://bioconductor.org/packages/release/data/annotation/html/MeSH.PCR.db.html), and [MeSH.XXX.eg.db-type packages](https://bioconductor.org/packages/release/data/annotation/html/MeSH.Hsa.eg.db.html).

# Pre-requisites
- Bash: GNU bash, version 4.2.46(1)-release (x86_64-redhat-linux-gnu)
- Snakemake: 5.3.0
- Anaconda: 4.8.3
- Singularity: 3.5.3

# How to reproduce this workflow
## 1. Configuration
XXXXXX

## 2. Perform snakemake command
XXXXXX

In local machine:
```
snakemake -j 4 --use-conda
snakemake -j 4 --use-singularity
```

In parallel environment (GridEngine):
```
snakemake -j 32 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-conda
snakemake -j 32 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
```

In parallel environment (Slurm):
```
snakemake -j 32 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-conda
snakemake -j 32 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
```

# License
Copyright (c) 2021 Koki Tsuyuzaki and RIKEN Bioinformatics Research Unit Released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

# Authors
- Koki Tsuyuzaki
- Manabu Ishii
- Itoshi Nikaido
