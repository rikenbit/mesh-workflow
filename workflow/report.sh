# HTML
mkdir -p report
mkdir -p report/v003
snakemake -s workflow/download.smk --report report/v003/download.html
snakemake -s workflow/ublast.smk --report report/v003/ublast.html
snakemake -s workflow/preprocess.smk --report report/v003/preprocess.html
snakemake -s workflow/categorize.smk --report report/v003/categorize.html
snakemake -s workflow/sqlite.smk --report report/v003/sqlite.html
snakemake -s workflow/metadata.smk --report report/v003/metadata.html
snakemake -s workflow/plot.smk --report report/v003/plot.html

