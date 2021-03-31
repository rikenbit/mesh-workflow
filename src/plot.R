library("ggplot2")
library("RSQLite")

sqlitefiles <-  commandArgs(trailingOnly = TRUE)

species <- c("Arabidopsis thaliana",
	"Bacillus subtilis subsp. subtilis str. 168",
	"Bos taurus", "Caenorhabditis elegans", "Drosophila melanogaster",
	"Danio rerio", "Escherichia coli str. K-12 substr. MG1655",
	"Gallus gallus", "Homo sapiens", "Mus musculus",
	"Rattus norvegicus", "Saccharomyces cerevisiae S288C",
	"Schizosaccharomyces pombe 972h-",
	"Sus scrofa", "Xenopus laevis")

threename <- gsub("sqlite/MeSH.", "",
	gsub(".eg.db.sqlite", "", sqlitefiles))

sample_sheet <- read.csv("sample_sheet/120.csv")

taxid <- sapply(threename, function(x){
	sample_sheet[which(sample_sheet$Abbreviation == x), "Taxon.ID"]
})
sname <- sapply(threename, function(x){
	sample_sheet[which(sample_sheet$Abbreviation == x), "Scientific.name"]
})

gdata <- as.vector(sapply(threename, function(x){
	filename <- paste0("sqlite/MeSH.", x, ".eg.db.sqlite")
	con <- dbConnect(SQLite(), filename)
	# gene2pubmed
	target.gene2pubmed <- dbGetQuery(con,
		"SELECT COUNT(*) FROM DATA WHERE SOURCEDB == 'gene2pubmed'")
	# Gendoo
	target.gendoo <- dbGetQuery(con,
		"SELECT COUNT(*) FROM DATA WHERE SOURCEDB == 'gendoo'")
	# RBBH
	target.rbbh <- unlist(sapply(species, function(x){
		query <- paste0("SELECT COUNT(*) FROM DATA WHERE SOURCEDB == '",
			x, "'")
		dbGetQuery(con, query)
	}))
	# Close
	dbDisconnect(con)
	# Output
	out <- unlist(c(target.gene2pubmed, target.gendoo, target.rbbh))
	names(out) <- NULL
	out
}))

gdata <- data.frame(
	Name=unlist(lapply(sname, function(x){rep(x,17)})),
	Value=gdata,
	Type=rep(c("gene2pubmed", "gendoo", species), length(sname)))

gdata2 <- gdata
gdata2$Value <- unlist(lapply(unique(as.character(gdata$Name)), function(x){
	tmp <- gdata[which(gdata$Name == x), ]
	100 * tmp$Value / sum(tmp$Value)
}))

# Order Fix
orderOrg <- order(sapply(as.character(sname), function(x){
	target <- which(gdata$Name == x)
	sum(gdata$Value[target])
}), decreasing=TRUE)
gdata$Name <- factor(gdata$Name, levels=sname[orderOrg])
gdata2$Name <- factor(gdata$Name, levels=sname[orderOrg])

# Plot
g <- ggplot(gdata, aes(x = Name, y = Value, fill = Type)) +
    geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Species") + ylab("# Gene ID - MeSH ID pairs") + theme(plot.margin= unit(c(1, 1, -1, 1), "lines"))

g2 <- ggplot(gdata2, aes(x = Name, y = Value, fill = Type)) +
    geom_bar(stat = "identity") + theme(axis.text.x = element_text(angle = 60, hjust = 1)) + xlab("Species") + ylab("Percentage (%)") + theme(plot.margin= unit(c(1, 1, -1, 1), "lines"))

ggsave(file='plot/summary.png', plot=g,
	dpi=500, width=20.0, height=7.0)

ggsave(file='plot/summary_percentage.png', plot=g2,
dpi=500, width=20.0, height=7.0)