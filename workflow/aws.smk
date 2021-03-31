import pandas as pd
from snakemake.utils import min_version

min_version("6.0.5")
configfile: "config.yaml"

SQLITE, = glob_wildcards('sqlite/MeSH.{sqlite}.eg.db.sqlite')
METADATA_VERSION = config['METADATA_VERSION']

rule all:
	input:
		'check/aws'

#############################################
# Data deploy on AWS S3 bucket server
#############################################
rule aws:
	input:
		expand('sqlite/MeSH.{sqlite}.eg.db.sqlite',
			sqlite=SQLITE)
	output:
		'check/aws'
	container:
		"docker://amazon/aws-cli:2.1.32"
	benchmark:
		'benchmarks/aws.txt'
	log:
		'logs/aws.log'
	shell:
		'src/aws.sh {METADATA_VERSION} >& {log}'