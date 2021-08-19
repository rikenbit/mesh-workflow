library("data.table")

taxid = commandArgs(trailingOnly=TRUE)[1]
outfile = commandArgs(trailingOnly=TRUE)[2]

# == pre_meshterm2.uniq.txt
mesh_term <- fread('output/mesh/MeSH.db.tsv', sep="@", header=FALSE)
gene2pubmed <- fread("data/gene2pubmed/gene2pubmed", sep="\t")
pre_mesh <- fread('data/pubmed/pre_mesh.txt')

# Filtering
mesh_term <- mesh_term[,c(1:3)]
mesh_term <- unique(mesh_term)
colnames(mesh_term) <- c("meshid", "meshterm", "category")

colnames(gene2pubmed)[1] <- "tax_id"
gene2pubmed <- gene2pubmed[tax_id == taxid]
gene2pubmed <- gene2pubmed[,2:3]
gene2pubmed <- unique(gene2pubmed)
colnames(gene2pubmed) <- c("geneid", "pubmedid")

pre_mesh <- pre_mesh[,c(1,4)]
colnames(pre_mesh) <- c("pubmedid", "meshterm")

# Output
if(nrow(gene2pubmed) != 0){
	if(nrow(pre_mesh) <= 1000000){
		print("Small data")
		tmp <- merge(mesh_term, pre_mesh, by="meshterm", allow.cartesian=TRUE)
		tmp2 <- merge(tmp, gene2pubmed, by="pubmedid")
		if(nrow(tmp2) == 0){
			print("No match")
		}else{
			tmp2 <- tmp2[, c("geneid", "meshid", "category", "pubmedid")]
			tmp2 <- cbind(tmp2, "gene2pubmed")
			fwrite(tmp2, outfile, append=FALSE, sep="\t", col.names=FALSE)
		}
	}else{
		print("Large data")
		start <- seq(1, nrow(pre_mesh), 1000000)
		end <- start + 999999
		end[length(end)] <- nrow(pre_mesh)
		for(i in seq_along(start)){
			print(paste0(i, " / ", length(start)))
			target <- start[i]:end[i]
			tmp <- merge(mesh_term, pre_mesh[target, ], by="meshterm", allow.cartesian=TRUE)
			tmp2 <- merge(tmp, gene2pubmed, by="pubmedid")
			if(nrow(tmp2) == 0){
				print("No match")
			}else{
				tmp2 <- tmp2[, c("geneid", "meshid", "category", "pubmedid")]
				tmp2 <- cbind(tmp2, "gene2pubmed")
				fwrite(tmp2, outfile, append=TRUE, sep="\t", col.names=FALSE)
			}
		}
	}
}
