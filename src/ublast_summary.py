#!/usr/bin/env python

import sys
import re

argvs = sys.argv
argc = len(argvs)
if (argc != 2):
    print("USAGE: %s filename" % sys.argv[0])
    quit()
filename = sys.argv[1]

def getAccession(tempvalue):
    if tempvalue.find("|") == -1:
        return tempvalue
    if tempvalue.find("pir||") != -1:
        return tempvalue.split("pir||")[1]
    if tempvalue.find("|") != -1:
        return tempvalue.split("|")[1]
    return tempvalue


f = open(argvs[1])
line = f.readline()
data={}
data2={}
while line:
    line = line[:-1]
    field = line.split("\t")
    if len(field) != 12:
        continue
    key = getAccession(field[0].split(" ")[0])

    value = float(field[10])
    value2 =   getAccession(field[1].split(" ")[0])

    if not key in data.keys():
        data[key] = value
        data2[key] = value2
    elif value < data[key]:
        data[key]=value
        data2[key] = value2

    line = f.readline()

f.close()

for key in data.keys():
    result = key+"\t"+data2[key]
    print(result)