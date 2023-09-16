# HTML
mkdir -p report
mkdir -p report/v006
snakemake -s workflow/download.smk --report report/v006/download.html
snakemake -s workflow/ublast.smk --report report/v006/ublast.html
snakemake -s workflow/preprocess.smk --report report/v006/preprocess.html
snakemake -s workflow/categorize.smk --report report/v006/categorize.html
snakemake -s workflow/sqlite.smk --report report/v006/sqlite.html
snakemake -s workflow/metadata.smk --report report/v006/metadata.html
snakemake -s workflow/plot.smk --report report/v006/plot.html

