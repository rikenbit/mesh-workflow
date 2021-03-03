DATABASES=['gene2pubmed', 'mesh', 'pubmed', 'gendoo', 'gene']

rule all:
	input:
		expand('data/{database}/{database}.tsv', dataset=DATABASES)

rule download:
	output:
		'data/{database}/{database}.tsv'
	benchmark:
		'benchmarks/download_{database}.txt'
	log:
		'logs/download_{database}.log'
	shell:
		'src/download_{wildcards.dataset}.sh >& {log}'

rule preprocess:
	input:
		'data/{database}/{database}.tsv'
	output:
		'data/{}'
	benchmark:
		'benchmarks/preprocess_{database}.txt'
	log:
		'logs/preprocess_{database}.log'
	shell:
		'src/preprocess_{wildcards.dataset}.sh >& {log}'
