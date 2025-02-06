# HTML
mkdir -p report
mkdir -p report/v009
snakemake -s workflow/download.smk --report report/v009/download.html
snakemake -s workflow/ublast.smk --report report/v009/ublast.html
snakemake -s workflow/preprocess.smk --report report/v009/preprocess.html
snakemake -s workflow/categorize.smk --report report/v009/categorize.html
snakemake -s workflow/sqlite.smk --report report/v009/sqlite.html
snakemake -s workflow/metadata.smk --report report/v009/metadata.html
snakemake -s workflow/plot.smk --report report/v009/plot.html

