
import pandas as pd
import time
import os
import csv

dataFolder         = "/media/teamlary/teamlary3/air930/mintsData/"
rawFolder          =  dataFolder + "/raw";
rawMatsFolder      =  dataFolder + "/rawMats";
updateFolder       =  dataFolder + "/update/UTDNodes";
modelsFolder       =  "/media/teamlary/teamlary3/air930/europa/mintsData/modelsMats/UTDNodes/";

# directory = os.path.join("c:\\","path")
# for root,dirs,files in os.walk(directory):
#     for file in files:
#        if "BME280" in file:
#            f=open(file, 'r')
#            #  perform calculation
#            f.close()

fileName = 'MINTS_001e063239e6_BME280_2020_09_13.csv'

with open(fileName, newline='') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader[-10:]:
        print(row)


df = pd.read_csv('filename', skiprows = row_count - N)


