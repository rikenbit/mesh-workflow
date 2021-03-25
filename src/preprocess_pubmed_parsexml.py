#!/usr/bin/python
# -*- coding: utf_8 -*-
import re
import sys

from xml.dom.pulldom import END_ELEMENT, START_ELEMENT, parse

# XML file name
xml_file = sys.argv[1]

doc = parse(xml_file)

PMID=""
MeSH_Term_List=[]

# open output file
p1 = re.compile("zip/zip/")
p2 = re.compile(".xml")
file1 = p2.sub("", p1.sub("mesh_", xml_file)) + ".txt"
out1 = open(file1, 'a')

# parse XML
for event, node in doc:
  if event == START_ELEMENT and node.localName == "MedlineCitation":
    PMID=""
    MeSH_Term_List=[]
    try:
      doc.expandNode(node)
      # PMID / 6. Pumbed URL
      for t in node.childNodes:
        if t.localName=='PMID':
          PMID="".join(tt.nodeValue for tt in t.childNodes if tt.nodeType == tt.TEXT_NODE)
      # remove duplicate
      PMID = PMID.replace("|||","")
      PMID = PMID.replace("\n","")
    except IndexError:
      pass
    except AttributeError:
      pass
    try:
      mhl=node.getElementsByTagName('MeshHeadingList')[0].getElementsByTagName('MeshHeading')
      for mh in mhl:
        m=mh.getElementsByTagName('DescriptorName')[0]
        MeSH_Term="".join(t.nodeValue for t in m.childNodes if t.nodeType == t.TEXT_NODE)
        MeSH_Term_List.append(MeSH_Term)
      for MeSH_Term in MeSH_Term_List:
        MeSH_Term = MeSH_Term.replace("|||","")
        MeSH_Term = MeSH_Term.replace("\n","")
        # output
        out1.write(PMID)
        out1.write("|||")
        out1.write(MeSH_Term)
        out1.write("\n")
    except IndexError:
      pass
    except AttributeError:
      pass
out1.close()