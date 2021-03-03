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


dataFolder = mintsDefinitions['dataFolder']+ "/modelsMats/UTDNodes/"
csvNow     = "resultsNowXT_ONN_1.csv"
csvWS      = "WS.csv"

print("Assigning Model File")
sysStr = "cp " + dataFolder +  csvNow +" " + dataFolder +  csvWS
print(sysStr)
os.system(sysStr)





