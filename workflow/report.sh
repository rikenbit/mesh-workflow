# HTML
mkdir -p report
mkdir -p report/v011
snakemake -s workflow/download.smk --report report/v011/download.html
snakemake -s workflow/ublast.smk --report report/v011/ublast.html
snakemake -s workflow/preprocess.smk --report report/v011/preprocess.html
snakemake -s workflow/categorize.smk --report report/v011/categorize.html
snakemake -s workflow/sqlite.smk --report report/v011/sqlite.html
snakemake -s workflow/metadata.smk --report report/v011/metadata.html
snakemake -s workflow/plot.smk --report report/v011/plot.html

