# HTML
mkdir -p report
mkdir -p report/v004
snakemake -s workflow/download.smk --report report/v004/download.html
snakemake -s workflow/ublast.smk --report report/v004/ublast.html
snakemake -s workflow/preprocess.smk --report report/v004/preprocess.html
snakemake -s workflow/categorize.smk --report report/v004/categorize.html
snakemake -s workflow/sqlite.smk --report report/v004/sqlite.html
snakemake -s workflow/metadata.smk --report report/v004/metadata.html
snakemake -s workflow/plot.smk --report report/v004/plot.html

