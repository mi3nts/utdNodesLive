#!/bin/sh
# D0wnloading Model Files from Europa 
#
#
# Downlaoding Model Files 
rsync -avzrtu -e ssh --include='*.mat' --include='*/' --exclude='*' lhw150030@europa.circ.utdallas.edu:/home/lhw150030/mintsData/modelsMats/ /mfs/io/groups/lary/mintsData/modelsMats/

# Dowloading Model Information 
#rsync -avzrtu -e ssh --include='*.csv' --include='*/' --exclude='*' lhw150030@europa.circ.utdallas.edu:/home/lhw150030/mintsData/modelsMats/ /mfs/io/groups/lary/mintsData/modelsMats/

