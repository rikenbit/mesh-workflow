import pandas as pd
from snakemake.utils import min_version

min_version("6.0.5")
configfile: "config.yaml"

MESH_VERSION = config['MESH_VERSION']

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

SCIENTIFICNAME_Type1 = ORG_Type1['Scientific.name']
SCIENTIFICNAME_Type2 = ORG_Type2['Scientific.name']
SCIENTIFICNAME_Type3 = ORG_Type3['Scientific.name']
SCIENTIFICNAME_Type4 = ORG_Type4['Scientific.name']
SCIENTIFICNAME_Type5 = ORG_Type5['Scientific.name']

COMMONNAME_Type1 = ORG_Type1['Common.name']
COMMONNAME_Type2 = ORG_Type2['Common.name']
COMMONNAME_Type3 = ORG_Type3['Common.name']
COMMONNAME_Type4 = ORG_Type4['Common.name']
COMMONNAME_Type5 = ORG_Type5['Common.name']

def sname_Type1(wld):
	idx=THREENAME_Type1.to_numpy().tolist().index(wld[0])
	return(SCIENTIFICNAME_Type1[idx].replace(' ', '_'))
def sname_Type2(wld):
	idx=THREENAME_Type2.to_numpy().tolist().index(wld[0])
	return(SCIENTIFICNAME_Type2[idx].replace(' ', '_'))
def sname_Type3(wld):
	idx=THREENAME_Type3.to_numpy().tolist().index(wld[0])
	return(SCIENTIFICNAME_Type3[idx].replace(' ', '_').replace('(', 'LLLLL').replace(')', 'RRRRR'))
def sname_Type4(wld):
	idx=THREENAME_Type4.to_numpy().tolist().index(wld[0])
	return(SCIENTIFICNAME_Type4[idx].replace(' ', '_'))
def sname_Type5(wld):
	idx=THREENAME_Type5.to_numpy().tolist().index(wld[0])
	return(SCIENTIFICNAME_Type5[idx].replace(' ', '_'))

def cname_Type1(wld):
	idx=THREENAME_Type1.to_numpy().tolist().index(wld[0])
	if idx != int:
		return("_")
	else:
		return(COMMONNAME_Type1[idx].replace(' ', '_'))
def cname_Type2(wld):
	idx=THREENAME_Type2.to_numpy().tolist().index(wld[0])
	if idx != int:
		return("_")
	else:
		return(COMMONNAME_Type2[idx].replace(' ', '_'))
def cname_Type3(wld):
	idx=THREENAME_Type3.to_numpy().tolist().index(wld[0])
	if idx != int:
		return("_")
	else:
		return(COMMONNAME_Type3[idx].replace(' ', '_'))
def cname_Type4(wld):
	idx=THREENAME_Type4.to_numpy().tolist().index(wld[0])
	if idx != int:
		return("_")
	else:
		return(COMMONNAME_Type4[idx].replace(' ', '_'))
def cname_Type5(wld):
	idx=THREENAME_Type5.to_numpy().tolist().index(wld[0])
	if idx != int:
		return("_")
	else:
		return(COMMONNAME_Type5[idx].replace(' ', '_'))

rule all:
	input:
		'sqlite/MeSH.db.sqlite',
		'sqlite/MeSH.PCR.db.sqlite',
		'sqlite/MeSH.AOR.db.sqlite',
		expand('sqlite/MeSH.{t1}.eg.db.sqlite', t1=THREENAME_Type1),
		expand('sqlite/MeSH.{t2}.eg.db.sqlite', t2=THREENAME_Type2),
		expand('sqlite/MeSH.{t3}.eg.db.sqlite', t3=THREENAME_Type3),
		expand('sqlite/MeSH.{t4}.eg.db.sqlite', t4=THREENAME_Type4),
		expand('sqlite/MeSH.{t5}.eg.db.sqlite', t5=THREENAME_Type5)

#############################################
# SQLite
#############################################

rule sqlite_meshdb:
	input:
		'output/mesh/MeSH.db.tsv'
	output:
		'sqlite/MeSH.db.sqlite'
	params:
		'src/MeSH.db.query',
		MESH_VERSION
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_meshdb.txt'
	log:
		'logs/sqlite_meshdb.log'
	shell:
		'src/sqlite.sh {input} {output} {params} >& {log}'

rule sqlite_mesh_pcr_db:
	input:
		'output/mesh/MeSH.PCR.db.tsv'
	output:
		'sqlite/MeSH.PCR.db.sqlite'
	params:
		'src/MeSH.PCR.db.query',
		MESH_VERSION
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_pcr_db.txt'
	log:
		'logs/sqlite_mesh_pcr_db.log'
	shell:
		'src/sqlite.sh {input} {output} {params} >& {log}'

rule sqlite_mesh_aor_db:
	input:
		'output/mesh/MeSH.AOR.db.tsv'
	output:
		'sqlite/MeSH.AOR.db.sqlite'
	params:
		'src/MeSH.AOR.db.query',
		MESH_VERSION
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_aor_db.txt'
	log:
		'logs/sqlite_mesh_aor_db.log'
	shell:
		'src/sqlite.sh {input} {output} {params} >& {log}'

# Type1 SQLite（Gendoo + gene2pubmed）
rule sqlite_mesh_xxx_eg_db_type1:
	input:
		'output/type1/{t1}.txt'
	output:
		'sqlite/MeSH.{t1}.eg.db.sqlite'
	params:
		'src/MeSH.XXX.eg.db_type1.query',
		MESH_VERSION,
		sname_Type1,
		cname_Type1
	wildcard_constraints:
		t1='|'.join([re.escape(x) for x in THREENAME_Type1])
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_xxx_eg_db_{t1}.txt'
	log:
		'logs/sqlite_mesh_xxx_eg_db_{t1}.log'
	shell:
		'src/sqlite.sh {input} {output} {params} {wildcards.t1} >& {log}'

# Type2 SQLite（Only gene2pubmed）
rule sqlite_mesh_xxx_eg_db_type2:
	input:
		'output/type2/{t2}.txt'
	output:
		'sqlite/MeSH.{t2}.eg.db.sqlite'
	params:
		'src/MeSH.XXX.eg.db_type2.query',
		MESH_VERSION,
		sname_Type2,
		cname_Type2
	wildcard_constraints:
		t2='|'.join([re.escape(x) for x in THREENAME_Type2])
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_xxx_eg_db_{t2}.txt'
	log:
		'logs/sqlite_mesh_xxx_eg_db_{t2}.log'
	shell:
		'src/sqlite.sh {input} {output} {params} {wildcards.t2} >& {log}'

# Type3 SQLite（RBBH + gene2pubmed）
rule sqlite_mesh_xxx_eg_db_type3:
	input:
		'output/type3/{t3}.txt'
	output:
		'sqlite/MeSH.{t3}.eg.db.sqlite'
	params:
		'src/MeSH.XXX.eg.db_type3.query',
		MESH_VERSION,
		sname_Type3,
		cname_Type3
	wildcard_constraints:
		t3='|'.join([re.escape(x) for x in THREENAME_Type3])
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_xxx_eg_db_{t3}.txt'
	log:
		'logs/sqlite_mesh_xxx_eg_db_{t3}.log'
	shell:
		'src/sqlite.sh {input} {output} {params} {wildcards.t3} >& {log}'

# Type4 SQLite（Only Gendoo）
rule sqlite_mesh_xxx_eg_db_type4:
	input:
		'output/type4/{t4}.txt'
	output:
		'sqlite/MeSH.{t4}.eg.db.sqlite'
	params:
		'src/MeSH.XXX.eg.db_type4.query',
		MESH_VERSION,
		sname_Type4,
		cname_Type4
	wildcard_constraints:
		t4='|'.join([re.escape(x) for x in THREENAME_Type4])
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_xxx_eg_db_{t4}.txt'
	log:
		'logs/sqlite_mesh_xxx_eg_db_{t4}.log'
	shell:
		'src/sqlite.sh {input} {output} {params} {wildcards.t4} >& {log}'

# Type5 SQLite（Only RBBH）
rule sqlite_mesh_xxx_eg_db_type5:
	input:
		'output/type5/{t5}.txt'
	output:
		'sqlite/MeSH.{t5}.eg.db.sqlite'
	params:
		'src/MeSH.XXX.eg.db_type5.query',
		MESH_VERSION,
		sname_Type5,
		cname_Type5
	wildcard_constraints:
		t5='|'.join([re.escape(x) for x in THREENAME_Type5])
	container:
		"docker://nouchka/sqlite3:latest"
	benchmark:
		'benchmarks/sqlite_mesh_xxx_eg_db_{t5}.txt'
	log:
		'logs/sqlite_mesh_xxx_eg_db_{t5}.log'
	shell:
		'src/sqlite.sh {input} {output} {params} {wildcards.t5} >& {log}'
