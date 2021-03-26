import pandas as pd
import glob
from snakemake.utils import min_version

min_version("6.0.5")
configfile: "config.yaml"

MEDLINES, = glob_wildcards('data/pubmed/zip/zip/{m}.xml')

# Organsisms
ORG_115 = pd.read_csv(config['ORG_115'], dtype='string')
ORG_100 = pd.read_csv(config['ORG_100'], dtype='string')
ORG_15 = pd.read_csv(config['ORG_15'], dtype='string')
ORG_14 = pd.read_csv(config['ORG_14'], dtype='string')
ORG_9 = pd.read_csv(config['ORG_9'], dtype='string')

TAXID_115 = ORG_115['Taxon.ID']

THREENAME_115 = ORG_115['Abbreviation']
THREENAME_100 = ORG_100['Abbreviation']
THREENAME_15 = ORG_15['Abbreviation']
THREENAME_14 = ORG_14['Abbreviation']
THREENAME_9 = ORG_9['Abbreviation']

SCIENTIFICNAME_15 = ORG_15['Scientific.name']

GENDOONAME_9 = ORG_9['Gendoo.name']

MESHCATEGORY = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
	'I', 'J', 'K', 'L', 'M', 'N', 'V', 'Z']
THIS_YEAR = config['THIS_YEAR']

rule all:
	input:
		'output/mesh/MeSH.db.tsv',
		'output/mesh/MeSH.PCR.db.tsv',
		'output/mesh/MeSH.AOR.db.tsv',
		expand('output/gene2pubmed/{t115}.txt', t115=THREENAME_115),
		expand('output/gendoo/{t9}.txt', t9=THREENAME_9),
		expand('output/rbbh/{t100}.txt', t100=THREENAME_100),
		expand('output/rbbh/{t14}_vs_Hsa.txt', t14=THREENAME_14)

#############################################
# Preprocess (PubMed)
#############################################
rule preprocess_pubmed_parsexml:
	input:
		'data/pubmed/zip/zip/{m}.xml'
	output:
		'data/pubmed/mesh_{m}.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_pubmed_parsexml_{m}.txt'
	log:
		'logs/preprocess_pubmed_parsexml_{m}.log'
	shell:
		'src/preprocess_pubmed_parsexml.sh {input} >& {log}'

rule preprocess_pubmed_merge_unique_sort:
	input:
		expand('data/pubmed/mesh_{m}.txt', m=MEDLINES)
	output:
		'data/pubmed/pre_mesh.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_pubmed_merge_unique_sort.txt'
	log:
		'logs/preprocess_pubmed_merge_unique_sort.log'
	shell:
		'src/preprocess_pubmed_merge_unique_sort.sh >& {log}'

def taxid_115(wld):
	idx=THREENAME_115.to_numpy().tolist().index(wld[0])
	return(TAXID_115[idx])

rule preprocess_join:
	input:
		'output/mesh/MeSH.db.tsv',
		'data/gene2pubmed/gene2pubmed',
		'data/pubmed/pre_mesh.txt'
	output:
		'output/gene2pubmed/{t115}.txt'
	wildcard_constraints:
			t115='|'.join([re.escape(x) for x in THREENAME_115])
	params:
		taxid_115
	container:
		"docker://rocker/tidyverse:4.0.0"
	benchmark:
		'benchmarks/preprocess_join_{t115}.txt'
	log:
		'logs/preprocess_join_{t115}.log'
	shell:
		'src/preprocess_join.sh {params} {output} >& {log}'

#############################################
# Preprocess (MeSH)
#############################################
rule preprocess_mesh_1:
	input:
		in1='data/mesh/d' + str(THIS_YEAR) + '.bin',
		in2='data/mesh/q' + str(THIS_YEAR) + '.bin',
		in3='check/download_mesh'
	output:
		out1='data/mesh/qual1.txt',
		out2='data/mesh/qual2.txt'
	container:
		'docker://koki/lwp_pl:latest'
	benchmark:
		'benchmarks/preprocess_mesh_1.txt'
	log:
		'logs/preprocess_mesh_1.log'
	shell:
		'src/preprocess_mesh_1.sh {input.in1} {input.in2} {output.out1} {output.out2} >& {log}'

rule preprocess_mesh_2:
	input:
		in1='data/mesh/d' + str(THIS_YEAR) + '.bin',
		in2='check/download_mesh'
	output:
		out1='data/mesh/mesh_term.txt',
		out2='data/mesh/mesh_synonym.txt',
		out3='data/mesh/for_R.txt'
	container:
		'docker://koki/lwp_pl:latest'
	benchmark:
		'benchmarks/preprocess_mesh_2.txt'
	log:
		'logs/preprocess_mesh_2.log'
	shell:
		'src/preprocess_mesh_2.sh {input.in1} {output.out1} {output.out2} {output.out3} >& {log}'

rule preprocess_mesh_qualifier:
	input:
		in1='data/mesh/qual1.txt',
		in2='data/mesh/qual2.txt'
	output:
		'data/mesh/qualifier.txt'
	container:
		"docker://rocker/tidyverse:4.0.0"
	benchmark:
		'benchmarks/preprocess_mesh_qualifier.txt'
	log:
		'logs/preprocess_mesh_qualifier.log'
	shell:
		'src/preprocess_mesh_qualifier.sh {input.in1} {input.in2} {output} >& {log}'

rule preprocess_mesh_parents:
	input:
		'data/mesh/for_R.txt'
	output:
		'data/mesh/mesh_{mc}_parents.txt'
	container:
		"docker://rocker/tidyverse:4.0.0"
	benchmark:
		'benchmarks/preprocess_mesh_{mc}_parents.txt'
	log:
		'logs/preprocess_mesh_{mc}_parents.log'
	shell:
		'src/preprocess_mesh_parents.sh {input} {output} >& {log}'

rule preprocess_mesh_offspring:
	input:
		'data/mesh/for_R.txt'
	output:
		'data/mesh/mesh_{mc}_offspring.txt'
	container:
		"docker://rocker/tidyverse:4.0.0"
	benchmark:
		'benchmarks/preprocess_mesh_{mc}_offspring.txt'
	log:
		'logs/preprocess_mesh_{mc}_offspring.log'
	shell:
		'src/preprocess_mesh_offspring.sh {input} {output} >& {log}'

rule preprocess_mesh_merge_as_threefiles:
	input:
		'data/mesh/mesh_term.txt',
		'data/mesh/mesh_synonym.txt',
		'data/mesh/qualifier.txt',
		expand('data/mesh/mesh_{mc}_parents.txt',
			mc=MESHCATEGORY),
		expand('data/mesh/mesh_{mc}_offspring.txt',
			mc=MESHCATEGORY)
	output:
		'output/mesh/MeSH.db.tsv',
		'output/mesh/MeSH.PCR.db.tsv',
		'output/mesh/MeSH.AOR.db.tsv'
	container:
		"docker://rocker/tidyverse:4.0.0"
	benchmark:
		'benchmarks/preprocess_mesh_merge_as_threefiles.txt'
	log:
		'logs/preprocess_mesh_merge_as_threefiles.log'
	shell:
		'src/preprocess_mesh_merge_as_threefiles.sh {input} {output} >& {log}'

#############################################
# Preprocess (Gendoo)
#############################################
def gendoo_threename_file(wld):
	idx=THREENAME_9.to_numpy().tolist().index(wld[0])
	FILES = glob.glob('data/gendoo/score.gene.' + GENDOONAME_9[idx] + '*.tab')
	return(FILES)

rule preprocess_gendoo:
	input:
		in1='check/download_gendoo',
		in2=gendoo_threename_file
	output:
		'output/gendoo/{t9}.txt'
	wildcard_constraints:
			t9='|'.join([re.escape(x) for x in THREENAME_9])
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_gendoo_{t9}.txt'
	log:
		'logs/preprocess_gendoo_{t9}.log'
	shell:
		'src/preprocess_gendoo.sh {output} {input.in2} >& {log}'

#############################################
# Preprocess (UBLAST)
#############################################
def sname_15(wld):
	idx=THREENAME_15.to_numpy().tolist().index(wld.t15)
	return(SCIENTIFICNAME_15[idx].replace(' ', '_'))

rule preprocess_gi_to_geneid_100_vs_15:
	input:
		'data/{t100}_vs_{t15}/{t100}_vs_{t15}.txt',
		'data/gene/{t100}.txt',
		'data/gene/{t15}.txt',
		'output/gene2pubmed/{t15}.txt'
	output:
		'output/rbbh/{t100}_vs_{t15}.txt'
	params:
		sname_15
	wildcard_constraints:
			t15='|'.join([re.escape(x) for x in THREENAME_15]),
			t100='|'.join([re.escape(x) for x in THREENAME_100])
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/preprocess_gi_to_geneid_{t100}_vs_{t15}.txt'
	log:
		'logs/preprocess_gi_to_geneid_{t100}_vs_{t15}.log'
	shell:
		'src/preprocess_gi_to_geneid.sh {input} {output} {params} >& {log}'

rule preprocess_gi_to_geneid_14_vs_Hsa:
	input:
		'data/{t14}_vs_Hsa/{t14}_vs_Hsa.txt',
		'data/gene/{t14}.txt',
		'data/gene/Hsa.txt',
		'output/gene2pubmed/Hsa.txt'
	output:
		'output/rbbh/{t14}_vs_Hsa.txt'
	params:
		'Homo sapiens'
	wildcard_constraints:
			t14='|'.join([re.escape(x) for x in THREENAME_14])
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/preprocess_gi_to_geneid_{t14}_vs_Hsa.txt'
	log:
		'logs/preprocess_gi_to_geneid_{t14}_vs_Hsa.log'
	shell:
		'src/preprocess_gi_to_geneid.sh {input} {output} {params} >& {log}'

rule preprocess_merge_100:
  input:
    expand('output/rbbh/{{t100}}_vs_{t15}.txt', t15=THREENAME_15)
  output:
    'output/rbbh/{t100}.txt'
  wildcard_constraints:
      t15='|'.join([re.escape(x) for x in THREENAME_15]),
      t100='|'.join([re.escape(x) for x in THREENAME_100])
  container:
    "docker://nouchka/sqlite3:latest"
  benchmark:
    'benchmarks/preprocess_merge_{t100}.txt'
  log:
    'logs/preprocess_merge_{t100}.log'
  shell:
    '(cat {input} > {output}) >& {log}'

rule preprocess_merge_14:
  input:
    'output/rbbh/{t14}_vs_Hsa.txt'
  output:
    'output/rbbh/{t14}.txt'
  wildcard_constraints:
      t14='|'.join([re.escape(x) for x in THREENAME_14])
  container:
    "docker://nouchka/sqlite3:latest"
  benchmark:
    'benchmarks/preprocess_merge_{t14}.txt'
  log:
    'logs/preprocess_merge_{t14}.log'
  shell:
    '(cat {input} > {output}) >& {log}'
