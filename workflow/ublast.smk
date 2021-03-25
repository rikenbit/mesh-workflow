import pandas as pd
from snakemake.utils import min_version

min_version("6.0.5")
configfile: "config.yaml"

UBLAST_PATH = config['UBLAST_PATH']

# Organsisms
ORG_115 = pd.read_csv(config['ORG_115'], dtype='string')
ORG_100 = pd.read_csv(config['ORG_100'], dtype='string')
ORG_15 = pd.read_csv(config['ORG_15'], dtype='string')
ORG_14 = pd.read_csv(config['ORG_14'], dtype='string')

TAXID_115 = ORG_115['Taxon.ID']
TAXID_100 = ORG_100['Taxon.ID']
TAXID_15 = ORG_15['Taxon.ID']
TAXID_14 = ORG_14['Taxon.ID']

THREENAME_115 = ORG_115['Abbreviation']
THREENAME_100 = ORG_100['Abbreviation']
THREENAME_15 = ORG_15['Abbreviation']
THREENAME_14 = ORG_14['Abbreviation']

rule all:
	input:
		expand('data/{t100}_vs_{t15}/{t100}_vs_{t15}.txt',
			t100=THREENAME_100, t15=THREENAME_15),
		expand('data/{t14}_vs_Hsa/{t14}_vs_Hsa.txt',
			t14=THREENAME_14)

#############################################
# UBLAST
#############################################

rule ublast_db_100:
	input:
		'data/gene/{t100}.filtered.fasta'
	output:
		'data/gene/{t100}.udb'
	wildcard_constraints:
			t100='|'.join([re.escape(x) for x in THREENAME_100])
	resources:
		mem_gb=500
	benchmark:
		'benchmarks/ublast_db_{t100}.txt'
	log:
		'logs/ublast_db_{t100}.log'
	shell:
		'src/ublast_db.sh {UBLAST_PATH} {input} {output} >& {log}'

rule ublast_db_15:
	input:
		'data/gene/{t15}.filtered.fasta'
	output:
		'data/gene/{t15}.udb'
	wildcard_constraints:
			t15='|'.join([re.escape(x) for x in THREENAME_15])
	resources:
		mem_gb=500
	benchmark:
		'benchmarks/ublast_db_{t15}.txt'
	log:
		'logs/ublast_db_{t15}.log'
	shell:
		'src/ublast_db.sh {UBLAST_PATH} {input} {output} >& {log}'

# 100 organisms vs 15 organisms
rule ublast_run_forward_100_vs_15:
	input:
		in1='data/gene/{t15}.udb',
		in2='data/gene/{t100}.udb',
		in3='data/gene/{t100}.filtered.fasta',
	output:
		'data/{t100}_vs_{t15}/{t100}_to_{t15}.txt'
	wildcard_constraints:
			t15='|'.join([re.escape(x) for x in THREENAME_15]),
			t100='|'.join([re.escape(x) for x in THREENAME_100])
	resources:
		mem_gb=500
	benchmark:
		'benchmarks/ublast_run_forward_{t100}_to_{t15}.txt'
	log:
		'logs/ublast_run_forward_{t100}_to_{t15}.log'
	shell:
		'src/ublast_run.sh {UBLAST_PATH} {input.in1} {input.in3} {output} >& {log}'

rule ublast_run_backward_100_vs_15:
	input:
		in1='data/gene/{t100}.udb',
		in2='data/gene/{t15}.udb',
		in3='data/gene/{t15}.filtered.fasta',
	output:
		'data/{t100}_vs_{t15}/{t15}_to_{t100}.txt'
	wildcard_constraints:
			t15='|'.join([re.escape(x) for x in THREENAME_15]),
			t100='|'.join([re.escape(x) for x in THREENAME_100])
	resources:
		mem_gb=500
	benchmark:
		'benchmarks/ublast_run_forward_{t15}_to_{t100}.txt'
	log:
		'logs/ublast_run_forward_{t15}_to_{t100}.log'
	shell:
		'src/ublast_run.sh {UBLAST_PATH} {input.in1} {input.in3} {output} >& {log}'

# 14 organisms vs Human (for LRBase.XXX.eg.db)
rule ublast_run_forward_14_vs_Hsa:
	input:
		in1='data/gene/Hsa.udb',
		in2='data/gene/{t14}.udb',
		in3='data/gene/{t14}.filtered.fasta',
	output:
		'data/{t14}_vs_Hsa/{t14}_to_Hsa.txt'
	wildcard_constraints:
			t14='|'.join([re.escape(x) for x in THREENAME_14])
	resources:
		mem_gb=500
	benchmark:
		'benchmarks/ublast_run_forward_{t14}_vs_Hsa.txt'
	log:
		'logs/ublast_run_forward_{t14}_vs_Hsa.log'
	shell:
		'src/ublast_run.sh {UBLAST_PATH} {input.in1} {input.in3} {output} >& {log}'

rule ublast_run_backward_14_vs_Hsa:
	input:
		in1='data/gene/{t14}.udb',
		in2='data/gene/Hsa.udb',
		in3='data/gene/Hsa.filtered.fasta',
	output:
		'data/{t14}_vs_Hsa/Hsa_to_{t14}.txt'
	wildcard_constraints:
			t14='|'.join([re.escape(x) for x in THREENAME_14])
	resources:
		mem_gb=500
	benchmark:
		'benchmarks/ublast_run_backward_{t14}_vs_Hsa.txt'
	log:
		'logs/ublast_run_backward_{t14}_vs_Hsa.log'
	shell:
		'src/ublast_run.sh {UBLAST_PATH} {input.in1} {input.in3} {output} >& {log}'

rule ublast_summary_100_to_15:
	input:
		'data/{t100}_vs_{t15}/{t100}_to_{t15}.txt'
	output:
		'data/{t100}_vs_{t15}/{t100}_to_{t15}.unique.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	wildcard_constraints:
			t15='|'.join([re.escape(x) for x in THREENAME_15]),
			t100='|'.join([re.escape(x) for x in THREENAME_100])
	benchmark:
		'benchmarks/ublast_summary_{t100}_to_{t15}.txt'
	log:
		'logs/ublast_summary_{t100}_to_{t15}.log'
	shell:
		'src/ublast_summary.sh {input} {output} >& {log}'

rule ublast_summary_15_to_100:
	input:
		'data/{t100}_vs_{t15}/{t15}_to_{t100}.txt'
	output:
		'data/{t100}_vs_{t15}/{t15}_to_{t100}.unique.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	wildcard_constraints:
			t15='|'.join([re.escape(x) for x in THREENAME_15]),
			t100='|'.join([re.escape(x) for x in THREENAME_100])
	benchmark:
		'benchmarks/ublast_summary_{t15}_to_{t100}.txt'
	log:
		'logs/ublast_summary_{t15}_to_{t100}.log'
	shell:
		'src/ublast_summary.sh {input} {output} >& {log}'

rule ublast_summary_14_to_Hsa:
	input:
		'data/{t14}_vs_Hsa/{t14}_to_Hsa.txt'
	output:
		'data/{t14}_vs_Hsa/{t14}_to_Hsa.unique.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	wildcard_constraints:
			t14='|'.join([re.escape(x) for x in THREENAME_14])
	benchmark:
		'benchmarks/ublast_summary_{t14}_to_Hsa.txt'
	log:
		'logs/ublast_summary_{t14}_to_Hsa.log'
	shell:
		'src/ublast_summary.sh {input} {output} >& {log}'

rule ublast_summary_Hsa_to_14:
	input:
		'data/{t14}_vs_Hsa/Hsa_to_{t14}.txt'
	output:
		'data/{t14}_vs_Hsa/Hsa_to_{t14}.unique.txt'
	container:
		"docker://logiqx/python-lxml:3.8-slim-buster"
	wildcard_constraints:
			t14='|'.join([re.escape(x) for x in THREENAME_14])
	benchmark:
		'benchmarks/ublast_summary_Hsa_to_{t14}.txt'
	log:
		'logs/ublast_summary_Hsa_to_{t14}.log'
	shell:
		'src/ublast_summary.sh {input} {output} >& {log}'

rule rbbh_100_vs_15:
	input:
		in1='data/{t100}_vs_{t15}/{t100}_to_{t15}.unique.txt',
		in2='data/{t100}_vs_{t15}/{t15}_to_{t100}.unique.txt'
	output:
		'data/{t100}_vs_{t15}/{t100}_vs_{t15}.txt'
	container:
		"docker://nouchka/sqlite3:latest"
	wildcard_constraints:
			t15='|'.join([re.escape(x) for x in THREENAME_15]),
			t100='|'.join([re.escape(x) for x in THREENAME_100])
	benchmark:
		'benchmarks/rbbh_{t100}_vs_{t15}.txt'
	log:
		'logs/rbbh_{t100}_vs_{t15}.log'
	shell:
		'src/ublast_rbbh.sh {input.in1} {input.in2} {output} >& {log}'

rule rbbh_14_vs_Hsa:
	input:
		in1='data/{t14}_vs_Hsa/{t14}_to_Hsa.unique.txt',
		in2='data/{t14}_vs_Hsa/Hsa_to_{t14}.unique.txt'
	output:
		'data/{t14}_vs_Hsa/{t14}_vs_Hsa.txt'
	container:
		"docker://nouchka/sqlite3:latest"
	wildcard_constraints:
			t14='|'.join([re.escape(x) for x in THREENAME_14])
	benchmark:
		'benchmarks/rbbh_{t14}_vs_Hsa.txt'
	log:
		'logs/rbbh_{t14}_vs_Hsa.log'
	shell:
		'src/ublast_rbbh.sh {input.in1} {input.in2} {output} >& {log}'
