file1 <- commandArgs(trailingOnly=TRUE)[1]
file2 <- commandArgs(trailingOnly=TRUE)[2]
CATEGORY <- gsub('data/mesh/mesh_', '',
	gsub('_parents.txt', '', 'data/mesh/mesh_A_parents.txt'))

#一列目はmesh_id、二列目はtree_no、三列目はcategory、4列目はparent_tree_no
data <- as.matrix(read.delim(file1, sep="\t", header=FALSE))

#格納用マトリックス
newdata <- matrix(nrow=0, ncol=2)

#category毎に切り出し
predata <- data[which(data[,3] == CATEGORY),]
l <- nrow(predata)
for(j in 1:l){
	#親の居場所
	locus <- which(predata[,2] == predata[j,4])
	#親がいる場合は、親のmesh_idを格納
	if(length(locus)!=0){
	#親のID - 自分のID
	newdata <- rbind(newdata, cbind(predata[locus,1], predata[j,1]))
	locus = 0
	}
}

# 保存
write.table(file=paste(file2, sep=""), newdata,
	sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
