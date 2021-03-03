#!/bin/bash
while :
do
	
	echo "===============MINTS================"
	echo "Syncing Raw files From UTD:"
	python3 syncWithPythonLocal.py mintsDefinitions.yaml
	echo "Halting Sync Operation:"
	sleep 1m
	echo "====================================="
done
