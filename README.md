# mesh-workflow

Workflow to construct  [MeSH.db](https://bioconductor.org/packages/release/data/annotation/html/MeSH.db.html), [MeSH.AOR.db](https://bioconductor.org/packages/release/data/annotation/html/MeSH.AOR.db.html), [MeSH.PCR.db](https://bioconductor.org/packages/release/data/annotation/html/MeSH.PCR.db.html), and [MeSH.XXX.eg.db-type packages](https://bioconductor.org/packages/release/data/annotation/html/MeSH.Hsa.eg.db.html).

# Pre-requisites
- Bash: GNU bash, version 4.2.46(1)-release (x86_64-redhat-linux-gnu)
- Snakemake: 6.0.5
- Anaconda: 4.9.2
- Singularity: 3.5.3

# Summary
![](https://github.com/rikenbit/mesh-workflow/blob/master/plot/summary.png)
![](https://github.com/rikenbit/mesh-workflow/blob/master/plot/summary_percentage.png)

# How to reproduce this workflow
## 1. Configuration
- **NCBI API Key**: For the detail, check [A General Introduction to the E-utilities](https://www.ncbi.nlm.nih.gov/books/NBK25497/).
- **USEARCH**: This workflow needs ublast command. Download and install from [USEARCH download](https://drive5.com/usearch/download.html).
- **config.yaml**:
  - *UBLAST_PATH*: Set the path you downloaded USEARCH
  - *THIS_YEAR*: Update when the year changes
  - *METADATA_VERSION*: Update like v001 -> v002 -> ...and so on.
  - *MESH_VERSION*: Update as needed (check the latest [NLM MeSH](https://www.nlm.nih.gov/databases/download/mesh.html))
  - *BIOC_VERSION*: Set next version of see [Bioconductor](https://www.bioconductor.org)

## 2. Perform snakemake command
The workflow consists of seven snakemake workflows.

In local machine:
```bash
export NCBI_API_KEY=ABCDE12345 # Your API Key
snakemake -s workflow/download.smk -j 4 --use-singularity
snakemake -s workflow/ublast.smk -j 4 --use-singularity
snakemake -s workflow/preprocess.smk -j 4 --use-singularity
snakemake -s workflow/categorize.smk -j 4 --use-singularity
snakemake -s workflow/sqlite.smk -j 4 --use-singularity
snakemake -s workflow/metadata.smk -j 4 --use-singularity
snakemake -s workflow/report.smk -j 4 --use-singularity
```

In parallel environment (GridEngine):
```bash
export NCBI_API_KEY=ABCDE12345
snakemake -s workflow/download.smk -j 4 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
snakemake -s workflow/ublast.smk -j 96 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
snakemake -s workflow/preprocess.smk -j 96 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
snakemake -s workflow/categorize.smk -j 96 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
snakemake -s workflow/sqlite.smk -j 96 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
snakemake -s workflow/metadata.smk -j 96 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
snakemake -s workflow/report.smk -j 96 --cluster "qsub -l nc=4 -p -50 -r yes -q node.q" --latency-wait 600 --use-singularity
```

In parallel environment (Slurm):
```bash
export NCBI_API_KEY=ABCDE12345
snakemake -s workflow/download.smk -j 4 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
snakemake -s workflow/ublast.smk -j 96 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
snakemake -s workflow/preprocess.smk -j 96 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
snakemake -s workflow/categorize.smk -j 96 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
snakemake -s workflow/sqlite.smk -j 96 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
snakemake -s workflow/metadata.smk -j 96 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
snakemake -s workflow/report.smk -j 96 --cluster "sbatch -n 4 --nice=50 --requeue -p node03-06" --latency-wait 600 --use-singularity
```

# License
Copyright (c) 2021 Koki Tsuyuzaki and RIKEN Bioinformatics Research Unit Released under the [Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0).

# Authors
- Koki Tsuyuzaki
- Manabu Ishii
- Itoshi Nikaido