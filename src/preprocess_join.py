#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import linecache
args = sys.argv

# import taxid and taxname
# filelist = {}
# taxidlist=[]
# counter=1

targettaxid = args[1]
outfile = args[2]
# targettaxid = "9606"
# outfile = "data/gene2pubmed/Hsa.txt"

# for line in open(basedirectory+'/ID/115ID/taxid.txt', 'r'):
#     line = line[:-1]
#     taxidlist.append(line)
#     filelist[line] = open(basedirectory+'/data/gene2pubmed/pre_'+linecache.getline(basedirectory+'/ID/115ID/threename.txt', counter).rstrip()+'.txt', 'w')
#     counter = counter + 1

# meshterm2
meshterm2 = {}
for line in open('data/mesh/mesh_term.txt', 'r'):
    if line[0] != "#":
      fields = line[:-1].split("|")
      meshid = fields[0]
      meshterm = fields[1]
      meshcategory = fields[2]
      if meshterm in meshterm2:
        pairlist = meshterm2[meshterm]
        pairlist.append( (meshid, meshcategory) )
      else:
        pairlist = []
        pairlist.append( (meshid, meshcategory) )
        meshterm2[meshterm] = pairlist

# gene2pubmed
gene2pubmed = {}
for line in open('data/gene2pubmed/gene2pubmed', 'r'):
    if line[0] != "#":
      fields = line[:-1].split("\t")
      taxid = fields[0]
      geneid = fields[1]
      pubmedid = fields[2]
      if not taxid in targettaxid:
        continue
      if pubmedid in gene2pubmed:
        pairlist = gene2pubmed[pubmedid]
        pairlist.append( (taxid, geneid,) )
      else:
        pairlist = []
        pairlist.append( (taxid, geneid,) )
        gene2pubmed[pubmedid] = pairlist

#meshterm1
count = 0
for line in open('data/pubmed/pre_mesh.txt', 'r'):
    count = count + 1
    if count%100000 == 0:
      print count
    if line[0] != "#":
      fields = line[:-1].split("|||")
      pubmedid = fields[0]
      meshterm = fields[1]
      if not pubmedid in gene2pubmed:
        continue
      if not meshterm in meshterm2:
        continue
      p1 = gene2pubmed[pubmedid]
      p2 = meshterm2[meshterm]
      for v1 in p1:
        for v2 in p2:
          # outfile
          filelist[v1[0]].write(v1[1]+"\t"+v2[0]+"\t"+v2[1]+"\t"+pubmedid+"\n")