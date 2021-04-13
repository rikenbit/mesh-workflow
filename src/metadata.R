# Command line arguments
metadata_version <- commandArgs(trailingOnly=TRUE)[1]
bioc_version <- commandArgs(trailingOnly=TRUE)[2]
outfile <- commandArgs(trailingOnly=TRUE)[3]

# Setting
nonzero_sqlites <- list.files("sqlite")
nonspecies_sqlites <- c("MeSH.db.sqlite", "MeSH.AOR.db.sqlite", "MeSH.PCR.db.sqlite")
nonzero_sqlites <- nonzero_sqlites[-which(nonzero_sqlites %in% nonspecies_sqlites)]
sample_sheet <- read.csv("sample_sheet/120.csv", stringsAsFactors=FALSE)
threename <- gsub("MeSH.", "", gsub(".eg.db.sqlite", "", nonzero_sqlites))

target <- unlist(sapply(threename, function(x){
	which(x == sample_sheet$Abbreviation)
}))
sname <- c(sample_sheet[target, "Scientific.name"], rep(NA, 3))
cname <- c(sample_sheet[target, "Common.name"], rep(NA, 3))
taxid <- c(sample_sheet[target, "Taxon.ID"], rep(NA, 3))

title <- c()
description <- c()
tags <- c()
for(i in seq(sname)){
	sn <- sname[i]
	cn <- cname[i]
	if(!is.na(sn) && !is.na(cn)){
		title <- c(title,
			paste0("MeSHDb for ", sn, " (", cn, ", ", metadata_version, ")"))
		description <- c(description,
			paste0("Correspondence table between NCBI Gene ID and MeSH ID for ", sn, " (", cn, ")"))
		tags <- c(tags, paste0(paste0("MeSHDb:MeSH:NCBI:DBCLS:Gendoo:Gene:NCBI Gene:gene2accession:Annotation:MeSH.", threename[i], ".eg.db:"),
			sn, ":", cn, ":", metadata_version))
	}else if(is.na(sn) && !is.na(cn)){
		title <- c(title,
			paste0("MeSHDb for ", cn, " (", metadata_version, ")"))
		description <- c(description,
			paste0("Correspondence table between NCBI Gene ID and MeSH ID for ", cn))
		tags <- c(tags, paste0(paste0("MeSHDb:MeSH:NCBI:DBCLS:Gendoo:Gene:NCBI Gene:gene2accession:Annotation:MeSH.", threename[i], ".eg.db:"),
			cn, ":", metadata_version))
	}else if(!is.na(sn) && is.na(cn)){
		title <- c(title,
			paste0("MeSHDb for ", sn, " (", metadata_version, ")"))
		description <- c(description,
			paste0("Correspondence table between NCBI Gene ID and MeSH ID for ", sn))
		tags <- c(tags, paste0(paste0("MeSHDb:MeSH:NCBI:DBCLS:Gendoo:Gene:NCBI Gene:gene2accession:Annotation:MeSH.", threename[i], ".eg.db:"),
			metadata_version))
	}else{
		title <- c(title, NA)
		description <- c(description, NA)
		tags <- c(tags, NA)
	}
}

title[which(is.na(title))] <- paste0("MeSHDb for ",
	c("MeSH.db", "MeSH.AOR.db", "MeSH.PCR.db"), " (", metadata_version, ")")

description[which(is.na(description))] <- c("Correspondence table for MeSH ID, MeSH Term, MeSH Category, Synonym, Qualifier ID, and Qualifier Term",
"MeSH Hierarchical structure (Ancestor-Offspring relationship)",
"MeSH Hierarchical structure (Parent-Child relationship)")

tags[which(is.na(tags))] <- paste0("MeSHDb:MeSH:NCBI:DBCLS:Gendoo:Gene:NCBI Gene:gene2accession:Annotation:",
	c("MeSH.db", "MeSH.AOR.db", "MeSH.PCR.db"),
	":", metadata_version)

# sourceurl <- paste0("ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz,ftp://nlmpubs.nlm.nih.gov/online/mesh/MESH_FILES/asciimesh/d", format(Sys.time(), "%Y"), ".bin,ftp://nlmpubs.nlm.nih.gov/online/mesh/MESH_FILES/asciimesh/q", format(Sys.time(), "%Y"), ".bin,ftp://ftp.nlm.nih.gov/nlmdata/.medleasebaseline/zip, http://gendoo.dbcls.jp/data/,ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz")
sourceurl <- "https://github.com/rikenbit/mesh-workflow"

rdatapath <- paste0("AHMeSHDbs/", metadata_version, "/",
		c(nonzero_sqlites, nonspecies_sqlites))

# Merge
Sys.setlocale("LC_TIME", "C")
out <- data.frame(
	Title = title,
	Description = description,
	BiocVersion = bioc_version,
	Genome = NA,
	SourceType = "TSV",
	SourceUrl = sourceurl,
	SourceVersion = format(Sys.time(), "%d-%b-%Y"),
	Species = sname,
	TaxonomyId = taxid,
	Coordinate_1_based = NA,
	DataProvider = "NCBI,DBCLS",
	Maintainer = "Koki Tsuyuzaki <k.t.the-answer@hotmail.co.jp>",
	RDataClass = "SQLiteFile",
	DispatchClass = "FilePath",
	RDataPath = rdatapath,
	Tags = tags
	)

# output
write.csv(out, outfile, row.names=FALSE)