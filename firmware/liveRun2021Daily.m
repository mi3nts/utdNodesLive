function [] = liveRun2021Daily(nodeIndex,yamlFile,resultsFileName,predictorStr)

% Uses the raw mats folder to get data and puclich the results and
% hence ytake time
addpath("functions/");
addpath("YAMLMatlab_0.4.3");

display("---------------------MINTS---------------------")
%     nodeIndex = round(str2double(nodeIndex))
display(newline)
%     display("---------------------MINTS---------------------")

mintsDefinitions   = ReadYaml(yamlFile);

nodeIDs            = mintsDefinitions.nodeIDs;
dataFolder         = mintsDefinitions.dataFolder;
mintsTargets       = mintsDefinitions.mintsTargets;

rawFolder          =  dataFolder + "/raw";
rawMatsFolder      =  dataFolder + "/rawMats";
updateFolder       =  dataFolder + "/liveUpdate/UTDNodes";
modelsFolder       =  dataFolder + "/modelsMats/UTDNodes/";

timeSpan           =  seconds(mintsDefinitions.timeSpan);
nodeID             =  nodeIDs{nodeIndex}.nodeID;
resultsFile        = modelsFolder+ resultsFileName +".csv";

display(newline);
display("Node Index               =  "+ nodeIndex);
display("Node ID                  =  "+ nodeID);
display("Data Folder Located      @ :"+ dataFolder);
display("Raw Data Located         @ :"+ rawFolder );
display("Raw DotMat Data Located  @ :"+ rawMatsFolder);
display("Update Data Located      @ :"+ updateFolder);
stringIn = "TimeSeries";

%% Loading from previiously Saved Data files

loadName = strcat(rawMatsFolder,"/UTDNodes/UTDNodesMints_",nodeID,".mat");
load(loadName)



%% Choosing Input Stack
eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
%     eval(strcat("inputStack       = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"));
%     eval(strcat("latestStack      = mintsDefinitions.latestStack",string(nodeIDs{nodeIndex}.inputStack),";"));

In  =  table2array(mintsDataAll(:,mintsInputs));

[rows, columns] = find(isnan(In));

In(unique(rows),:) = [];
mintsDataAll(unique(rows),:) = [];

%% Days Back Change


validDaysInd= (year(mintsDataAll.dateTime)>2017);

In = In(validDaysInd,:);
mintsDataAll = mintsDataAll(validDaysInd,:) ;


%% Loading the appropriate models

display("Loading Best Models")
[bestModels,bestModelsLabels] = readResultsNow(resultsFile,nodeID,mintsTargets,modelsFolder);


bestModelsFileName    = strcat(updateFolder,"/",nodeID,"/",...
    "MINTS_",...
    nodeID,...
    "_BestModels.csv"...
    );


folderCheck(bestModelsFileName);
writetable(bestModelsLabels,bestModelsFileName);


for n = 1: length(bestModels)
    display("Predicting " + mintsTargets{n})
    eval(strcat(mintsTargets{n},"_predicted= " , predictorStr,"(bestModels{n},In);"));
    
end

predictedTablePre2 = mintsDataAll(:,contains(mintsDataAll.Properties.VariableNames,"GPSGPGGA2"));

predictedTablePre = mintsDataAll(:,contains(mintsDataAll.Properties.VariableNames,"binCount"));

strCombine = "predictedTablePost = timetable(mintsDataAll.dateTime";

for n = 1: length(bestModels)
    strCombine = strcat(strCombine,",",mintsTargets{n},"_predicted");
end

eval(strcat(strCombine,");"));


predictedTablePost.Properties.VariableNames =  strrep(strrep(mintsTargets+"_Predicted","_palas",""),"_Airmar","");



predictedTable = [predictedTablePre2,predictedTablePre,predictedTablePost];
%     predictedTable = predictedTable(height(predictedTable)-height(predictedTablePost)+2:end-1,:);
%     predictedTable.altitude(isnan(predictedTable.altitude))=nodeIDs{nodeIndex}.altitude;
%     predictedTable.latitudeCoordinate(isnan(predictedTable.latitudeCoordinate))=nodeIDs{nodeIndex}.latitude;
%     predictedTable.longitudeCoordinate(isnan(predictedTable.longitudeCoordinate))=nodeIDs{nodeIndex}.longitude;

varNames = predictedTable.Properties.VariableNames;

for n = 1 :length(varNames)
    varNames{n} =   strrep(varNames{n},'latitudeCoordinate','Latitude');
    varNames{n} =   strrep(varNames{n},'longitudeCoordinate','Longitude');
    varNames{n} =   strrep(varNames{n},'altitude','Altitude');
end



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

if (height(predictedTable)>0)
    varNames = predictedTable.Properties.VariableNames;
    
    
    for n = 1 :length(varNames)
        varNames{n} =   strrep(varNames{n},'binCount','Bin');
        varNames{n} =   strrep(varNames{n},'_Predicted','');
        varNames{n} =   strrep(varNames{n},'Airmar','');
        varNames{n} =   strrep(varNames{n},'pm','PM');
        varNames{n} =   strrep(varNames{n},'temperature','Temperature');
        varNames{n} =   strrep(varNames{n},'humidity','Humidity');
        varNames{n} =   strrep(varNames{n},'pressure','Pressure');
        varNames{n} =   strrep(varNames{n},'dewPoint','DewPoint');
        varNames{n} =   strrep(varNames{n},'dCn','ParticleConcentration');
        varNames{n} =   strrep(varNames{n},'pressure','Pressure');
        varNames{n} =   strrep(varNames{n},'latitudeCoordinate','Latitude');
        varNames{n} =   strrep(varNames{n},'longitudeCoordinate','Longitude');
        varNames{n} =   strrep(varNames{n},'altitude','Altitude');
        varNames{n} =   strrep(varNames{n},'Latitude_mintsDataGPSGPGGA2','Latitude');
        varNames{n} =   strrep(varNames{n},'Longitude_mintsDataGPSGPGGA2','Longitude');
        varNames{n} =   strrep(varNames{n},'Altitude_mintsDataGPSGPGGA2','Altitude');
        
    end
    
    predictedTable.Properties.VariableNames = varNames;
    
    %% At this point create both the graphs needed and historic data
    % Initially do the csv for all the variables
    display("Printing complete Time Series for Node: " +nodeID )
    printCSVTTAll(predictedTable,updateFolder,nodeID,"UTC")
    
    printCSVTTWithPlots(predictedTable,updateFolder,nodeID);
    
    %   printCSVT(bestModelsLabels,updateFolder,nodeID,monthIn,'modelInfo');
else
    display("No Data For " +  nodeID );
end
end



