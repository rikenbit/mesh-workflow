import pandas as pd
import glob
from snakemake.utils import min_version

min_version("6.0.5")
configfile: "config.yaml"

# Organsisms
ORG_Type1 = pd.read_csv(config['Type1'], dtype='string')
ORG_Type2 = pd.read_csv(config['Type2'], dtype='string')
ORG_Type3 = pd.read_csv(config['Type3'], dtype='string')
ORG_Type4 = pd.read_csv(config['Type4'], dtype='string')
ORG_Type5 = pd.read_csv(config['Type5'], dtype='string')

THREENAME_Type1 = ORG_Type1['Abbreviation']
THREENAME_Type2 = ORG_Type2['Abbreviation']
THREENAME_Type3 = ORG_Type3['Abbreviation']
THREENAME_Type4 = ORG_Type4['Abbreviation']
THREENAME_Type5 = ORG_Type5['Abbreviation']

rule all:
	input:
		expand('output/type1/{t1}.txt', t1=THREENAME_Type1),
		expand('output/type2/{t2}.txt', t2=THREENAME_Type2),
		expand('output/type3/{t3}.txt', t3=THREENAME_Type3),
		expand('output/type4/{t4}.txt', t4=THREENAME_Type4),
		expand('output/type5/{t5}.txt', t5=THREENAME_Type5)

#############################################
# Categorize
#############################################
# gene2pubmed + gendoo
rule categorize_type1:
	input:
		in1='output/gene2pubmed/{t1}.txt',
		in2='output/gendoo/{t1}.txt'
	output:
		'output/type1/{t1}.txt'
	wildcard_constraints:
		t1='|'.join([re.escape(x) for x in THREENAME_Type1])
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_categorize_type1_{t1}.txt'
	log:
		'logs/preprocess_categorize_type1_{t1}.log'
	shell:
		'(cat {input.in1} {input.in2} > {output}) >& {log}'

# Only gene2pubmed
rule categorize_type2:
	input:
		'output/gene2pubmed/{t2}.txt'
	output:
		'output/type2/{t2}.txt'
	wildcard_constraints:
		t2='|'.join([re.escape(x) for x in THREENAME_Type2])
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_categorize_type2_{t2}.txt'
	log:
		'logs/preprocess_categorize_type2_{t2}.log'
	shell:
		'(cp {input} {output}) >& {log}'

# gene2pubmed + RBBH
rule categorize_type3:
	input:
		in1='output/gene2pubmed/{t3}.txt',
		in2='output/rbbh/{t3}.txt'
	output:
		'output/type3/{t3}.txt'
	wildcard_constraints:
		t3='|'.join([re.escape(x) for x in THREENAME_Type3])
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_categorize_type3_{t3}.txt'
	log:
		'logs/preprocess_categorize_type3_{t3}.log'
	shell:
		'(cat {input.in1} {input.in2} > {output}) >& {log}'

# Only gendoo
rule categorize_type4:
	input:
		'output/gendoo/{t4}.txt'
	output:
		'output/type4/{t4}.txt'
	wildcard_constraints:
		t4='|'.join([re.escape(x) for x in THREENAME_Type4])
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_categorize_type4_{t4}.txt'
	log:
		'logs/preprocess_categorize_type4_{t4}.log'
	shell:
		'(cp {input} {output}) >& {log}'

# Only RBBH
rule categorize_type5:
	input:
		'output/rbbh/{t5}.txt'
	output:
		'output/type5/{t5}.txt'
	wildcard_constraints:
		t5='|'.join([re.escape(x) for x in THREENAME_Type5])
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_categorize_type5_{t5}.txt'
	log:
		'logs/preprocess_categorize_type5_{t5}.log'
	shell:
		'(cp {input} {output}) >& {log}'