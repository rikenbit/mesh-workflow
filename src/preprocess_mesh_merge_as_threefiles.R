CATEGORY = LETTERS[c(1:14, 22,26)]

######################################
# MeSH.db
######################################
file1 <- commandArgs(trailingOnly=TRUE)[1]
file2 <- commandArgs(trailingOnly=TRUE)[2]
file3 <- commandArgs(trailingOnly=TRUE)[3]

mesh_term <- as.matrix(read.delim(file1, sep="\t", header=FALSE))
mesh_synonym <- as.matrix(read.delim(file2, sep="\t", header=FALSE))
qualifier <- as.matrix(read.delim(file3, sep="\t", header=FALSE))

colnames(mesh_term) <- c("MESHID","MESHTERM","CATEGORY")
colnames(mesh_synonym) <- c("MESHID","SYNONYM")
colnames(qualifier) <- c("QUALIFIERID","QUALIFIER","MESHID")

out1 <- merge(mesh_term, mesh_synonym, by="MESHID")
out1 <- merge(out1, qualifier, by="MESHID")

######################################
# MeSH.PCR.db
######################################
filename <- commandArgs(trailingOnly=TRUE)[4]
out2 <- as.matrix(read.delim(filename, sep="\t", header=FALSE))
out2 <- cbind(out2, "A")
for(i in 2:length(CATEGORY)){
	filename <- commandArgs(trailingOnly=TRUE)[i+3]
	mesh_parents <- as.matrix(read.delim(filename,
		sep="\t", header=FALSE))
	out2 <- rbind(out2, cbind(mesh_parents, CATEGORY[i]))
}
colnames(out2) <- c("ParentID", "MESHID", "CATEGORY")

######################################
# MeSH.AOR.db
######################################
filename <- commandArgs(trailingOnly=TRUE)[20]
out3 <- as.matrix(read.delim(filename, sep="\t", header=FALSE))
out3 <- cbind(out3, "A")
for(i in 2:length(CATEGORY)){
	filename <- commandArgs(trailingOnly=TRUE)[i+19]
	mesh_offspring <- as.matrix(read.delim(filename,
		sep="\t", header=FALSE))
	out3 <- rbind(out3, cbind(mesh_offspring, CATEGORY[i]))
}
colnames(out3) <- c("MESHID", "OFFSPRING", "CATEGORY")

######################################
# 保存
######################################
file4 <- commandArgs(trailingOnly=TRUE)[36]
file5 <- commandArgs(trailingOnly=TRUE)[37]
file6 <- commandArgs(trailingOnly=TRUE)[38]

write.table(out1, file4, sep="@",
	quote=FALSE, col.names = FALSE, row.names=FALSE)
write.table(out2, file5, sep="@",
	quote=FALSE, col.names = FALSE, row.names=FALSE)
write.table(out3, file6, sep="@",
	quote=FALSE, col.names = FALSE, row.names=FALSE)