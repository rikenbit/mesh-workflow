file1 <- commandArgs(trailingOnly=TRUE)[1]
file2 <- commandArgs(trailingOnly=TRUE)[2]
file3 <- commandArgs(trailingOnly=TRUE)[3]

# QA - qualifier_id
data1 <- as.matrix(read.delim(file1, sep="\t", header=FALSE))
#QA - mesh_id
data2 <- as.matrix(read.delim(file2, sep="\t", header=FALSE))

#格納用マトリックス
newdata <- matrix(nrow=0,ncol=3)

l <- nrow(data1)

for(j in 1:l){
#同じQAをもつmesh_idの場所
locus <- which(data2[,1] == data1[j,2])
#親がいる場合は、親のmesh_idを格納
	if(length(locus)!=0){
	#qualifier - mesh
	newdata <- rbind(newdata,
		cbind(data1[j,3], data1[j,1], data2[locus,2]))
	}
}

# 保存
write.table(file=file3, newdata, sep="\t", quote=FALSE,
	row.names=FALSE, col.names=FALSE)