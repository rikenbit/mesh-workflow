# HTML
mkdir -p report
mkdir -p report/v007
snakemake -s workflow/download.smk --report report/v007/download.html
snakemake -s workflow/ublast.smk --report report/v007/ublast.html
snakemake -s workflow/preprocess.smk --report report/v007/preprocess.html
snakemake -s workflow/categorize.smk --report report/v007/categorize.html
snakemake -s workflow/sqlite.smk --report report/v007/sqlite.html
snakemake -s workflow/metadata.smk --report report/v007/metadata.html
snakemake -s workflow/plot.smk --report report/v007/plot.html

