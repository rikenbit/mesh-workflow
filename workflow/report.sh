# HTML
mkdir -p report
mkdir -p report/v002
snakemake -s workflow/download.smk --report report/v002/download.html
snakemake -s workflow/ublast.smk --report report/v002/ublast.html
snakemake -s workflow/preprocess.smk --report report/v002/preprocess.html
snakemake -s workflow/categorize.smk --report report/v002/categorize.html
snakemake -s workflow/sqlite.smk --report report/v002/sqlite.html
snakemake -s workflow/metadata.smk --report report/v002/metadata.html
snakemake -s workflow/plot.smk --report report/v002/plot.html

