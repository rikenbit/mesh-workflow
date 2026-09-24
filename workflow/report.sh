# HTML
mkdir -p report
mkdir -p report/v012
snakemake -s workflow/download.smk --report report/v012/download.html
snakemake -s workflow/ublast.smk --report report/v012/ublast.html
snakemake -s workflow/preprocess.smk --report report/v012/preprocess.html
snakemake -s workflow/categorize.smk --report report/v012/categorize.html
snakemake -s workflow/sqlite.smk --report report/v012/sqlite.html
snakemake -s workflow/metadata.smk --report report/v012/metadata.html
snakemake -s workflow/plot.smk --report report/v012/plot.html

