println(DEPOT_PATH)
# Local Singularity Image
# ["/home/koki/.julia", "/usr/local/julia/local/share/julia", "/usr/local/julia/share/julia"]

# Job Schedular (Slurm)
# ["/home/koki/Dev/mesh-workflow/.julia", "/usr/local/julia/local/share/julia", "/usr/local/julia/share/julia"]

println(LOAD_PATH)
# Local Singularity Image
# ["@", "@v#.#", "@stdlib"]

# Job Schedular (Slurm)
# ["@", "@v#.#", "@stdlib"]

println(Base.load_path())
# Local Singularity Image
# ["/home/koki/.julia/environments/v1.6/Project.toml", "/usr/local/julia/share/julia/stdlib/v1.6"]

# Job Schedular (Slurm)
# ["/home/koki/Dev/mesh-workflow/.julia/environments/v1.6/Project.toml", "/usr/local/julia/share/julia/stdlib/v1.6"]

using GZip
println(pathof(GZip))
# Local Singularity Image
# /home/koki/.julia/packages/GZip/JNmGn/src/GZip.jl
# Job Schedular (Slurm)
# ERROR: LoadError: ArgumentError: Package GZip not found in current

taxid = ARGS[1]
outfile = ARGS[2]

regex = "^" * "$taxid" * "\t" * "(.*?)" * "\t" * "(.*?)" * "\t" * "(.*?)" * "\t" * "(.*?)" * "\t" * "(.*?)" * "\t" * "(.*?)" * "\t.*"

open(outfile, "w") do fp
	GZip.open("data/gene/test.gz", "r") do fp2
		for line in eachline(fp2)
		  	m = match(Regex(regex), line)
			if !isnothing(m)
				if m[1] != "-" && m[6] != "-"
					write(fp, "$(m[1])\t$(m[6])\n")
				end
			end
		end
	end
end
