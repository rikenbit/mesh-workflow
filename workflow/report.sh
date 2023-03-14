# HTML
mkdir -p report
mkdir -p report/v005
snakemake -s workflow/download.smk --report report/v005/download.html
snakemake -s workflow/ublast.smk --report report/v005/ublast.html
snakemake -s workflow/preprocess.smk --report report/v005/preprocess.html
snakemake -s workflow/categorize.smk --report report/v005/categorize.html
snakemake -s workflow/sqlite.smk --report report/v005/sqlite.html
snakemake -s workflow/metadata.smk --report report/v005/metadata.html
snakemake -s workflow/plot.smk --report report/v005/plot.html

