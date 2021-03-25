import pandas as pd
from snakemake.utils import min_version

min_version("6.0.5")
configfile: "config.yaml"

# Organsisms
ORG_115 = pd.read_csv(config['ORG_115'], dtype='string')
TAXID_115 = ORG_115['Taxon.ID']
THREENAME_115 = ORG_115['Abbreviation']

DATABASES=['gene2pubmed', 'mesh', 'pubmed', 'gendoo', 'gene2accession']
THIS_YEAR = config['THIS_YEAR']

envvars: 'NCBI_API_KEY'

rule all:
	input:
		expand('check/download_{database}', database=DATABASES),
		expand('data/gene/{t115}.filtered.fasta', t115=THREENAME_115)

#############################################
# Data download
#############################################
rule download:
	output:
		'check/download_{database}'
	benchmark:
		'benchmarks/download_{database}.txt'
	container:
		'docker://koki/lwp_pl:latest'
	log:
		'logs/download_{database}.log'
	shell:
		'src/download_{wildcards.database}.sh {THIS_YEAR} >& {log}'

def taxid_115(wld):
	idx=THREENAME_115.to_numpy().tolist().index(wld[0])
	return(TAXID_115[idx])

rule convert_each_org_accession:
	input:
		'check/download_gene2accession'
	params:
		taxid_115
	output:
		'data/gene/{t115}.txt'
	container:
		'docker://julia:1.6.0-rc1-buster'
	benchmark:
		'benchmarks/convert_each_org_accession_{t115}.txt'
	log:
		'logs/convert_each_org_accession_{t115}.log'
	shell:
		'src/convert_each_org_accession.sh {params} {output} >& {log}'

rule convert_gi:
	input:
		'data/gene/{t115}.txt'
	output:
		'data/gene/{t115}.gi'
	container:
		'docker://koki/lwp_pl:latest'
	benchmark:
		'benchmarks/convert_gi_{t115}.txt'
	log:
		'logs/convert_gi_{t115}.log'
	shell:
		'src/convert_gi.sh {input} {output} >& {log}'

rule download_fasta:
	input:
		'data/gene/{t115}.gi'
	output:
		'data/gene/{t115}.fasta'
	wildcard_constraints:
			t115='|'.join([re.escape(x) for x in THREENAME_115])
	params:
		ncbi_api_key=os.environ["NCBI_API_KEY"]
	container:
		'docker://koki/lwp_pl:latest'
	benchmark:
		'benchmarks/download_fasta_{t115}.txt'
	log:
		'logs/download_fasta_{t115}.log'
	shell:
		'src/download_fasta.sh {input} {params} {output} >& {log}'

rule filter_fasta:
	input:
		'data/gene/{t115}.fasta'
	output:
		'data/gene/{t115}.filtered.fasta'
	wildcard_constraints:
			t115='|'.join([re.escape(x) for x in THREENAME_115])
	container:
		'docker://koki/lwp_pl:latest'
	benchmark:
		'benchmarks/filter_fasta_{t115}.txt'
	log:
		'logs/filter_fasta_{t115}.log'
	shell:
		'src/filter_fasta.sh {input} {output} >& {log}'
