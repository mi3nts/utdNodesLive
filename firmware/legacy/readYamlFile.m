function [] = readYamlFile(yamlFile)

    addpath("YAMLMatlab_0.4.3");
    mintsDefinitions   = ReadYaml(yamlFile);
    nodeIDs            = mintsDefinitions.nodeIDs;
    dataFolder         = mintsDefinitions.dataFolder;
    mintsTargets       = mintsDefinitions.mintsTargets;
    
    display(dataFolder)

end 