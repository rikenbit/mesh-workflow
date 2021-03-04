import pandas as pd
from snakemake.utils import min_version

min_version("5.3.0")
configfile: "config.yaml"

DATABASES=['gene2pubmed', 'mesh', 'pubmed', 'gendoo', 'gene']
MESHCATEGORY=['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'V', 'Z']
THIS_YEAR = config['THIS_YEAR']
UBLAST_PATH = config['UBLAST_PATH']

rule all:
	input:
		'data/sqlite/MeSH.db.sqlite',
		'data/sqlite/MeSH.PCR.db.sqlite',
		'data/sqlite/MeSH.AOR.db.sqlite'

#############################################
# Data download
#############################################
rule download:
	output:
		'check/download_{database}'
	benchmark:
		'benchmarks/download_{database}.txt'
	log:
		'logs/download_{database}.log'
	shell:
		'src/download_{wildcards.database}.sh {THIS_YEAR} >& {log}'

#############################################
# Preprocess
#############################################

rule preprocess_mesh_perl_1:
	input:
		in1='data/mesh/d' + str(THIS_YEAR) + '.bin',
		in2='data/mesh/q' + str(THIS_YEAR) + '.bin',
		in3='check/download_mesh'
	output:
		out1='data/mesh/qual1.txt',
		out2='data/mesh/qual2.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_mesh_perl_1.txt'
	log:
		'logs/preprocess_mesh_perl_1.log'
	shell:
		'src/preprocess_mesh_perl_1.sh {input.in1} {input.in2} {output.out1} {output.out2} >& {log}'

rule preprocess_mesh_perl_2:
	input:
		in1='data/mesh/d' + str(THIS_YEAR) + '.bin',
		in2='check/download_mesh'
	output:
		out1='data/mesh/mesh_term.txt',
		out2='data/mesh/mesh_synonym.txt',
		out3='data/mesh/for_R.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	benchmark:
		'benchmarks/preprocess_mesh_perl_2.txt'
	log:
		'logs/preprocess_mesh_perl_2.log'
	shell:
		'src/preprocess_mesh_perl_2.sh {input.in1} {output.out1} {output.out2} {output.out3} >& {log}'

rule preprocess_mesh_r_qualifier:
	input:
		in1='data/mesh/qual1.txt',
		in2='data/mesh/qual2.txt'
	output:
		'data/mesh/qualifier.txt'
	container:
		"docker://koki/biocdev:latest"
	benchmark:
		'benchmarks/preprocess_mesh_r_qualifier.txt'
	log:
		'logs/preprocess_mesh_r_qualifier.log'
	shell:
		'src/preprocess_mesh_r_qualifier.sh {input.in1} {input.in2} {output} >& {log}'

rule preprocess_mesh_r_parents:
	input:
		'data/mesh/for_R.txt'
	output:
		'data/mesh/mesh_{mc}_parents.txt'
	container:
		"docker://koki/biocdev:latest"
	benchmark:
		'benchmarks/preprocess_mesh_r_{mc}_parents.txt'
	log:
		'logs/preprocess_mesh_r_{mc}_parents.log'
	shell:
		'src/preprocess_mesh_r_parents.sh {input} {output} >& {log}'

rule preprocess_mesh_r_offspring:
	input:
		'data/mesh/for_R.txt'
	output:
		'data/mesh/mesh_{mc}_offspring.txt'
	container:
		"docker://koki/biocdev:latest"
	benchmark:
		'benchmarks/preprocess_mesh_r_{mc}_offspring.txt'
	log:
		'logs/preprocess_mesh_r_{mc}_offspring.log'
	shell:
		'src/preprocess_mesh_r_offspring.sh {input} {output} >& {log}'

rule preprocess_mesh_r_merge_as_threefiles:
	input:
		'data/mesh/mesh_term.txt',
		'data/mesh/mesh_synonym.txt',
		'data/mesh/qualifier.txt',
		expand('data/mesh/mesh_{mc}_parents.txt',
			mc=MESHCATEGORY),
		expand('data/mesh/mesh_{mc}_offspring.txt',
			mc=MESHCATEGORY)
	output:
		'data/mesh/MeSH.db.tsv',
		'data/mesh/MeSH.PCR.db.tsv',
		'data/mesh/MeSH.AOR.db.tsv'
	container:
		"docker://koki/biocdev:latest"
	benchmark:
		'benchmarks/preprocess_mesh_r_merge_as_threefiles.txt'
	log:
		'logs/preprocess_mesh_r_merge_as_threefiles.log'
	shell:
		'src/preprocess_mesh_r_merge_as_threefiles.sh {input} {output} >& {log}'

# rule preprocess_pubmed:

# rule preprocess_gendoo:

# rule preprocess_gene:

#############################################
# UBLAST
#############################################
# {UBLAST_PATH}

# rule ublast_db:

# rule ublast_run:

# rule ublast_summary:

#############################################
# SQLite
#############################################

rule sqlite_meshdb:
	input:
		'data/mesh/MeSH.db.tsv'
	output:
		'data/sqlite/MeSH.db.sqlite'
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_meshdb.txt'
	log:
		'logs/sqlite_meshdb.log'
	shell:
		'src/sqlite_meshdb.sh >& {log}'

rule sqlite_mesh_pcr_db:
	input:
		'data/mesh/MeSH.PCR.db.tsv'
	output:
		'data/sqlite/MeSH.PCR.db.sqlite'
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_pcr_db.txt'
	log:
		'logs/sqlite_mesh_pcr_db.log'
	shell:
		'src/sqlite_mesh_pcr_db.sh >& {log}'

rule sqlite_mesh_aor_db:
	input:
		'data/mesh/MeSH.AOR.db.tsv'
	output:
		'data/sqlite/MeSH.AOR.db.sqlite'
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_aor_db.txt'
	log:
		'logs/sqlite_mesh_aor_db.log'
	shell:
		'src/sqlite_mesh_aor_db.sh >& {log}'

# rule sqlite_type1:

# rule sqlite_type2:

# rule sqlite_type3:

# rule sqlite_type4:

# rule sqlite_type5:

#############################################
# METADATA
#############################################

# rule metadata:

#############################################
# Report
#############################################
# container: "docker://koki/biocdev:latest"
# rule plot:
# Rとが必要
