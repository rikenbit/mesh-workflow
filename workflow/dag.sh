# DAG graph
snakemake -s workflow/download.smk --rulegraph | dot -Tpng > plot/download.png
snakemake -s workflow/ublast.smk --rulegraph | dot -Tpng > plot/ublast.png
snakemake -s workflow/preprocess.smk --rulegraph | dot -Tpng > plot/preprocess.png
snakemake -s workflow/categorize.smk --rulegraph | dot -Tpng > plot/categorize.png
snakemake -s workflow/sqlite.smk --rulegraph | dot -Tpng > plot/sqlite.png
snakemake -s workflow/metadata.smk --rulegraph | dot -Tpng > plot/metadata.png
snakemake -s workflow/plot.smk --rulegraph | dot -Tpng > plot/plot.png