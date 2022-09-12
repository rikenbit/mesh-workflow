#!/bin/bash

METADATA_VERSION=$1
OUTPUT=$2

mkdir -p Azure/AHMeSHDbs/${METADATA_VERSION}
cp -rf sqlite/*  Azure/AHMeSHDbs/${METADATA_VERSION}/
echo "" > ${OUTPUT}
