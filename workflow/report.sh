# HTML
mkdir -p report
mkdir -p report/v010
snakemake -s workflow/download.smk --report report/v010/download.html
snakemake -s workflow/ublast.smk --report report/v010/ublast.html
snakemake -s workflow/preprocess.smk --report report/v010/preprocess.html
snakemake -s workflow/categorize.smk --report report/v010/categorize.html
snakemake -s workflow/sqlite.smk --report report/v010/sqlite.html
snakemake -s workflow/metadata.smk --report report/v010/metadata.html
snakemake -s workflow/plot.smk --report report/v010/plot.html

