#!/usr/bin/python

import sys
import yaml
import os

print()
print("MINTS")
print()

yamlFile =  str(sys.argv[1])
print("YAML File: " + yamlFile)
print()

with open(yamlFile) as file:
    # The FullLoader parameter handles the conversion from YAML
    # scalar values to Python the dictionary format
    mintsDefinitions = yaml.load(file, Loader=yaml.FullLoader)

dataFolder = mintsDefinitions['dataFolder']+ "/liveUpdate/results/"

syncStr  = "rsync -avzrtu -e ssh --include='*.csv' --include='*/' --exclude='*' lhw150030@europa.circ.utdallas.edu:/scratch/lhw150030/mintsData/liveUpdate/UTDNodes/ "+ dataFolder 
print(syncStr)
os.system(syncStr)


