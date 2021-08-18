file1 <- commandArgs(trailingOnly=TRUE)[1]
file2 <- commandArgs(trailingOnly=TRUE)[2]
CATEGORY <- gsub('data/mesh/mesh_', '',
	gsub('_offspring.txt', '', file2))

#一列目はmesh_id、二列目はtree_no、三列目はcategory、4列目はparent_tree_no
data <- as.matrix(read.delim(file1, sep="\t", header=FALSE))

#格納用マトリックス
newdata <- matrix(nrow=0, ncol=2)

#category毎に切り出し
predata <- data[which(data[,3] == CATEGORY),]
l <- nrow(predata)
for(j in 1:l){
	#子孫の居場所
	locus <- grep(predata[j,2],predata[,2])
	#自分自身は除く
	locus <- setdiff(locus,j)
	#子孫がいる場合は、子孫のmesh_idを格納
	if(length(locus)!=0){
	#自分のID - 子孫のID
	newdata <- rbind(newdata, cbind(predata[j,1], predata[locus,1]))
	locus = 0
	}
}

# 保存
write.table(file=paste(file2, sep=""), newdata,
	sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)
