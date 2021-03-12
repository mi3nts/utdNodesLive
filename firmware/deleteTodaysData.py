#!/usr/bin/python
import os
import sys
import shutil
import datetime
#from mintsPi import mintsSensorReader as mSR
#from mintsPi import mintsDefinitions as mD
import yaml


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

nodeIDs = mintsDefinitions['nodeIDs']
dataFolder = mintsDefinitions['dataFolder']+ "/liveUpdate/results"


for nodes in nodeIDs:
    nodeID =  nodes['nodeID']
    deleteDate = datetime.datetime.utcnow()
    print("Deleting data for Node: "+ nodeID)
    deletePath = dataFolder+"/"+nodeID+"/"+str(deleteDate.year).zfill(4)  + \
    "/" + str(deleteDate.month).zfill(2)+ "/"+str(deleteDate.day).zfill(2)
    print(deletePath)

    try:
        shutil.rmtree(deletePath)
    except OSError as e:
        print ("Error: %s - %s." % (e.filename, e.strerror))









