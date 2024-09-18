# HTML
mkdir -p report
mkdir -p report/v008
snakemake -s workflow/download.smk --report report/v008/download.html
snakemake -s workflow/ublast.smk --report report/v008/ublast.html
snakemake -s workflow/preprocess.smk --report report/v008/preprocess.html
snakemake -s workflow/categorize.smk --report report/v008/categorize.html
snakemake -s workflow/sqlite.smk --report report/v008/sqlite.html
snakemake -s workflow/metadata.smk --report report/v008/metadata.html
snakemake -s workflow/plot.smk --report report/v008/plot.html

