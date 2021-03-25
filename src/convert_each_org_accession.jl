taxid = ARGS[1]
outfile = ARGS[2]

regex = "^$taxid\t(.*?)\t.*?\t.*?\t.*?\t(.*?)\t(.*?)\t.*"

open(outfile, "w") do fp
	open("data/gene/gene2accession", "r") do fp2
		for line in eachline(fp2)
		  	m = match(Regex(regex), line)
			if !isnothing(m)
				if m[1] != "-" && m[3] != "-"
					write(fp, "$(m[1])\t$(m[2])\n")
				end
			end
		end
	end
end
