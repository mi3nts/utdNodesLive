

clc
clear all
close all

datetime('now')
display(newline)
display("---------------------MINTS---------------------")

addpath("../functions/")

addpath("YAMLMatlab_0.4.3")
mintsDefinitions  = ReadYaml('mintsDefinitions.yaml');

nodeIDs            = mintsDefinitions.nodeIDs;
dataFolder         = mintsDefinitions.dataFolder;
mintsTargets       = mintsDefinitions.mintsTargets;

rawFolder          =  dataFolder + "/raw";
rawMatsFolder      =  dataFolder + "/rawMats";
updateFolder       =  dataFolder + "/update/UTDNodes";
modelsFolder       =  "/media/teamlary/teamlary3/air930/europa/mintsData/modelsMats/UTDNodes/";

timeSpan           =  seconds(mintsDefinitions.timeSpan);

currentFolder = "/media/teamlary/teamlary3/air930/mintsData/raw/001e06305a61/2020/11/01";

resultsFile =modelsFolder+ "resultsNow.csv";
nodeID = "001e06305a61";


nodeIndex = 3 ;
display(newline);
display("Data Folder Located      @ :"+ dataFolder);
display("Raw Data Located         @ :"+ rawFolder );
display("Raw DotMat Data Located  @ :"+ rawMatsFolder);
display("Update Data Located      @ :"+ updateFolder);

tic
%AS7262Files      =  dir(strcat(currentFolder,'/*AS7262*.csv'))
BME280Files      =  dir(strcat(currentFolder,'/*BME280*.csv'));
GPSGPGGA2Files   =  dir(strcat(currentFolder,'/*GPSGPGGA2*.csv'));
GPSGPRMC2Files   =  dir(strcat(currentFolder,'/*GPSGPRMC2*.csv'));
MGS001Files      =  dir(strcat(currentFolder,'/*MGS001*.csv'));
OPCN2Files       =  dir(strcat(currentFolder,'/*OPCN2*.csv'));
OPCN3Files       =  dir(strcat(currentFolder,'/*OPCN3*.csv'));
PPD42NSDuoFiles  =  dir(strcat(currentFolder,'/*PPD42NSDuo*.csv'));
SCD30Files       =  dir(strcat(currentFolder,'/*SCD30*.csv'));
% TSL2591Files     =  dir(strcat(currentFolder,'/*TSL2591*.csv'))
% VEML6075Files    =  dir(strcat(currentFolder,'/*VEML6075*.csv'))
    

[BME280,GPSGPGGA2,GPSGPRMC2,MGS001,OPCN2,OPCN3,PPD42NSDuo,SCD30]...
                        = pmInputDataParFor(BME280Files,GPSGPGGA2Files,GPSGPRMC2Files,...
                                MGS001Files,OPCN2Files,OPCN3Files,PPD42NSDuoFiles,SCD30Files,...
                                    @readFast,@GPGGAReadFast,@GPGRMCReadFast,...
                                        timeSpan);


toc
%% Choosing Input Stack

eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
eval(strcat("inputStack       = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"));
eval(strcat("latestStack      = mintsDefinitions.latestStack",string(nodeIDs{nodeIndex}.inputStack),";"));
;


%% Getting Inputs for calibration  

display("Saving UTD Nodes Data");
concatStr  =  "latestDataAll   = synchronize(";
for stackIndex = 1: length(latestStack)
    concatStr = strcat(concatStr,latestStack{stackIndex},",");
end
concatStr  = strcat(concatStr,"'union');")   
eval(concatStr)
% toc     


nodeIDs{nodeIndex}.inputStack

%% Correction of Column names 
if nodeIDs{nodeIndex}.inputStack == 1 
   latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature ;
end     

if nodeIDs{nodeIndex}.inputStack == 2
   latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature_BME280 ;
   latestDataAll.humidity_mintsDataBME280 = latestDataAll.humidity_BME280 ;
end     


In  =  table2array(latestDataAll(:,mintsInputs));


%% Loading the appropriate models 

[bestModels,bestModelsLabels] = readResultsNow(resultsFile,nodeID,mintsTargets,modelsFolder)

for n = 1: length(bestModels)
    
   eval(strcat(mintsTargets{n},"_predicted= " , "predictrsuper(bestModels{n},In);"));
    
end

predictedTablePre = latestDataAll(:,contains(latestDataAll.Properties.VariableNames,"binCount"));



strCombine = "predictedTablePost = timetable(latestDataAll.dateTime"



for n = 1: length(bestModels)
    
   strCombine = strcat(strCombine,",",mintsTargets{n},"_predicted");
    
end
eval(strcat(strCombine,");"));


predictedTablePost.Properties.VariableNames =  strrep(strrep(mintsTargets+"_Predicted","_palas",""),"_Airmar","");

predictedTable = [predictedTablePre,predictedTablePost];

datetime('now')


% 
% close all
% figure
% plot(predictedTable.dateTime,predictedTable.pm1_Predicted,'r-')
% hold on 
% plot(predictedTable.dateTime,predictedTable.pm2_5_Predicted,'g-')
% plot(predictedTable.dateTime,predictedTable.pm4_Predicted,'b-')
% plot(predictedTable.dateTime,predictedTable.pm10_Predicted,'k-')



     
    display("Gaining Prediction")
    predictedTablePre  = predictedTable;
    predictionCorrection = zeros(height(predictedTable),1);

    %% Zero Correction 
    %sum(predictedTable.pm1_Predicted<0)
    predictionCorrection = predictionCorrection |(predictedTable.pm1_Predicted<0);
    predictedTable.pm1_Predicted((predictedTable.pm1_Predicted<0),:)=0;

    %sum(predictedTable.pm2_5_Predicted<0)
    predictionCorrection = predictionCorrection | (predictedTable.pm2_5_Predicted<0);
    predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted<0),:)=0;

    %sum(predictedTable.pm4_Predicted<0)
    predictionCorrection = predictionCorrection | (predictedTable.pm4_Predicted<0);
    predictedTable.pm4_Predicted((predictedTable.pm4_Predicted<0),:)=0;

    %sum(predictedTable.pm10_Predicted<0)
    predictionCorrection = predictionCorrection | (predictedTable.pm10_Predicted<0);
    predictedTable.pm10_Predicted((predictedTable.pm10_Predicted<0),:)=0;
    
    predictionCorrection = predictionCorrection | (predictedTable.pmTotal_Predicted<0);
    predictedTable.pmTotal_Predicted((predictedTable.pmTotal_Predicted<0),:)=0;

    %% PM Corrections 

    %sum((predictedTable.pm2_5_Predicted>predictedTable.pm10_Predicted))
    predictionCorrection = predictionCorrection | (predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted);
    predictedTable.pm4_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) =...
                               predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) ;  

    %sum((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted))                       
    predictionCorrection = predictionCorrection | (predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted);                       
    predictedTable.pm1_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) =...
                                predictedTable.pm2_5_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) ;

    %sum((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted))                          
    predictionCorrection = predictionCorrection | (predictedTable.pm4_Predicted>predictedTable.pm10_Predicted);  
    predictedTable.pm10_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) =...
                                predictedTable.pm4_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) ;

    %sum((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted))                          
    predictionCorrection = predictionCorrection | (predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted);  
    predictedTable.pmTotal_Predicted((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted),:) =...
                                predictedTable.pm10_Predicted((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted),:) ;

%% Checks                      

predictedTable.Corrected   =  predictionCorrection;
predictedTablePre.Validity =  ~predictionCorrection;

close all
figure
plot(predictedTable.dateTime,predictedTable.pm1_Predicted,'r-')
hold on 
plot(predictedTable.dateTime,predictedTable.pm2_5_Predicted,'g-')
plot(predictedTable.dateTime,predictedTable.pm4_Predicted,'b-')
plot(predictedTable.dateTime,predictedTable.pm10_Predicted,'k-')


predictedTableFN ='Predicted.csv';
writetimetable(predictedTable,predictedTableFN);


statsTableFN ='stats.csv';
writetable(bestModelsLabels,statsTableFN);

