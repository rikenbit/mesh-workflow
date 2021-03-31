# HTML
mkdir report
mkdir report/v001
snakemake -s workflow/download.smk --report report/v001/download.html
snakemake -s workflow/ublast.smk --report report/v001/ublast.html
snakemake -s workflow/preprocess.smk --report report/v001/preprocess.html
snakemake -s workflow/categorize.smk --report report/v001/categorize.html
snakemake -s workflow/sqlite.smk --report report/v001/sqlite.html
snakemake -s workflow/metadata.smk --report report/v001/metadata.html
snakemake -s workflow/plot.smk --report report/v001/plot.html

