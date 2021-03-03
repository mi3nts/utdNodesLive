 
clc
clear all
close all 
% liveRun('4',)
% '/media/teamlary/teamlary1/gitHubRepos/utdNodesLive/firmware/mintsDefinitions.yaml'
    display("---------------------MINTS---------------------")
    nodeIndex = 4
    yamlFile ='/media/teamlary/teamlary1/gitHubRepos/utdNodesLive/firmware/mintsDefinitions.yaml'
%     addpath("../functions/");
%     addpath("YAMLMatlab_0.4.3");
    currentDate = datetime('now') - days(30)
    display(newline)
    display("---------------------MINTS---------------------")

    mintsDefinitions   = ReadYaml(yamlFile);

    nodeIDs            = mintsDefinitions.nodeIDs;
    dataFolder         = mintsDefinitions.dataFolder;
    mintsTargets       = mintsDefinitions.mintsTargets;

    rawFolder          =  dataFolder + "/raw";
    rawMatsFolder      =  dataFolder + "/rawMats";
    updateFolder       =  dataFolder + "/update/UTDNodes";
    modelsFolder       =  "/media/teamlary/teamlary3/air930/europa/mintsData/modelsMats/UTDNodes/";

    timeSpan           =  seconds(mintsDefinitions.timeSpan);
    nodeID             =  nodeIDs{nodeIndex}.nodeID;
    
    todaysNodeFolder      = strcat(rawFolder,"/",nodeID,"/",...
                                string(year(currentDate)),"/",...
                                string(month(currentDate)),"/",...
                                string(day(currentDate)))    ;                                
                            
    resultsFile        = modelsFolder+ "resultsNow.csv";

    nodeIndex = 3 ;
    display(newline);
    display("Data Folder Located      @ :"+ dataFolder);
    display("Raw Data Located         @ :"+ rawFolder );
    display("Raw DotMat Data Located  @ :"+ rawMatsFolder);
    display("Update Data Located      @ :"+ updateFolder);

    tic
%     fileName  = strcat(dataFiles.folder,"/",dataFiles.name);
    %AS7262Files      =  dir(strcat(currentFolder,'/*AS7262*.csv'))
%     BME280Files      =  dir(strcat(todaysNodeFolder,'/*BME280*.csv'));
    GPSGPGGA2Files   =  dir(strcat(todaysNodeFolder,'/*GPSGPGGA2*.csv'));
    fileName  = strcat(GPSGPGGA2Files.folder,"/",GPSGPGGA2Files.name);
%     lk = tabularTextDatastore(strcat(dataFiles.folder,"/",dataFiles.name),'OutputType', 'timetable')
    
%    
   lk =  sensorReadSolo(GPSGPGGA2Files,@GPGGAReadFast,timeSpan);
    toc
    [status,cmdout] = system(strcat("cat ",fileName," | wc -l"))
    
    
    