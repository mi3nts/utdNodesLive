#!/bin/bash
ml load matlab
echo "MINTS Init ;)"
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('1','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('2','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('3','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('4','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('5','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('6','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('7','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('8','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('9','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('10','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('11','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('12','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('13','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('14','mintsDefinitions.yaml');quit"&
matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('15','mintsDefinitions.yaml');quit"
echo "MINTS Done :)"
#matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('16','mintsDefinitions.yaml');quit"
#matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('17','mintsDefinitions.yaml');quit"
#matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('18','mintsDefinitions.yaml');quit"
#matlab -nodesktop -nodisplay -nosplash -r "addpath('functions','YAMLMatlab_0.4.3') ; liveRunDynamicM('19','mintsDefinitions.yaml');quit"

