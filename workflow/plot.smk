import pandas as pd
from snakemake.utils import min_version

min_version("6.0.5")
configfile: "config.yaml"

SQLITE, = glob_wildcards('sqlite/MeSH.{sqlite}.eg.db.sqlite')

rule all:
	input:
		'plot/summary.png',
		'plot/summary_percentage.png'

#############################################
# Plot
#############################################

rule plot:
	input:
		expand('sqlite/MeSH.{sqlite}.eg.db.sqlite',
			sqlite=SQLITE)
	output:
		'plot/summary.png',
		'plot/summary_percentage.png'
	container:
		"docker://koki/biocdev:20211020"
	benchmark:
		'benchmarks/plot.txt'
	log:
		'logs/plot.log'
	shell:
		'src/plot.sh {input} >& {log}'
