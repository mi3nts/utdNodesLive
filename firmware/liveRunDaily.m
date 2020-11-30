function [] = liveRunDaily(nodeIndex,yamlFile)
    
    tic
    display(newline)
    display("---------------------MINTS---------------------")
    
    nodeIndex = round(str2double(nodeIndex));
    currentDate= datetime('now','timezone','utc');
    display(currentDate);
    
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
    display(nodeID);
    
    
    todaysNodeFolder   = strcat(rawFolder,"/",nodeID,"/",...
                                string(year(currentDate)),"/",...
                                string(month(currentDate)),"/",...
                                string(day(currentDate)))    ;                                
                            
    resultsFile        = modelsFolder+ "resultsNow.csv";

    display(newline);
    display("Data Folder Located      @ :"+ dataFolder);
    display("Raw Data Located         @ :"+ rawFolder );
    display("Raw DotMat Data Located  @ :"+ rawMatsFolder);
    display("Update Data Located      @ :"+ updateFolder);

    display(newline)
    
    %AS7262Files      =  dir(strcat(currentFolder,'/*AS7262*.csv'))
    BME280Files      =  dir(strcat(todaysNodeFolder,'/*BME280*.csv'));
    GPSGPGGA2Files   =  dir(strcat(todaysNodeFolder,'/*GPSGPGGA2*.csv'));
%     GPSGPRMC2Files   =  dir(strcat(todaysNodeFolder,'/*GPSGPRMC2*.csv'));
    MGS001Files      =  dir(strcat(todaysNodeFolder,'/*MGS001*.csv'));
    OPCN2Files       =  dir(strcat(todaysNodeFolder,'/*OPCN2*.csv'));
    OPCN3Files       =  dir(strcat(todaysNodeFolder,'/*OPCN3*.csv'));
    PPD42NSDuoFiles  =  dir(strcat(todaysNodeFolder,'/*PPD42NSDuo*.csv'));
    SCD30Files       =  dir(strcat(todaysNodeFolder,'/*SCD30*.csv'));
    % TSL2591Files     =  dir(strcat(currentFolder,'/*TSL2591*.csv'))
    % VEML6075Files    =  dir(strcat(currentFolder,'/*VEML6075*.csv'))

    if isempty(BME280Files)||(isempty(OPCN2Files)&&isempty(OPCN3Files))

        display("No Data for Node:" +  nodeID)
        return;

    end    
    
    %% Loading the appropriate models 
    display(newline)
    display("Loading Best Models")
    
    [bestModels,bestModelsLabels] = readResultsNow(resultsFile,nodeID,mintsTargets,modelsFolder);

    if(sum(cellfun(@isempty,bestModels))>0 || length(bestModels)<10)
        display("Insuffient Number of Models Saved for Node:" +  nodeID)
        return;
    end    
    
      
    [BME280,GPSGPGGA2,MGS001,OPCN2,OPCN3,PPD42NSDuo,SCD30]...
                            = pmInputDataFor(BME280Files,GPSGPGGA2Files,...
                                    MGS001Files,OPCN2Files,OPCN3Files,PPD42NSDuoFiles,SCD30Files,...
                                        @readFast,@GPGGAReadFast,...
                                            timeSpan);
                                        
                                        
    

    %% Choosing Input Stack

    eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("inputStack       = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("latestStack      = mintsDefinitions.latestStack",string(nodeIDs{nodeIndex}.inputStack),";"));


    %% Getting Inputs for calibration  
    display(newline)
    display("Saving UTD Nodes Data");
    concatStr  =  "latestDataAll   = synchronize(";
    for stackIndex = 1: length(latestStack)
        concatStr = strcat(concatStr,latestStack{stackIndex},",");
    end
    concatStr  = strcat(concatStr,"'union');")   ;
    eval(concatStr)

    %% Correction of Column names 
    if nodeIDs{nodeIndex}.inputStack == 1 
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature ;
    end     

    if nodeIDs{nodeIndex}.inputStack == 2
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature_BME280 ;
       latestDataAll.humidity_mintsDataBME280 = latestDataAll.humidity_BME280 ;
    end   
    
    if nodeIDs{nodeIndex}.inputStack == 3
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature_BME280 ;
       latestDataAll.humidity_mintsDataBME280 = latestDataAll.humidity_BME280 ;
       latestDataAll.temperature_mintsDataSCD30 = latestDataAll.temperature_SCD30 ;
       latestDataAll.humidity_mintsDataSCD30 = latestDataAll.humidity_SCD30 ;
    end 

    In  =  table2array(latestDataAll(:,mintsInputs));



    
    display(newline)
    display("Gaining Super Learner Predictions")
    for n = 1: length(bestModels)

       eval(strcat(mintsTargets{n},"_predicted= " , "predictrsuper(bestModels{n},In);"));

    end

    predictedTablePre = latestDataAll(:,contains(latestDataAll.Properties.VariableNames,"binCount"));

    strCombine = "predictedTablePost = timetable(latestDataAll.dateTime";

    for n = 1: length(bestModels)
       strCombine = strcat(strCombine,",",mintsTargets{n},"_predicted");
    end
    
    eval(strcat(strCombine,");"));

    predictedTablePost.Properties.VariableNames =  strrep(strrep(mintsTargets+"_Predicted","_palas",""),"Airmar","");

    if isempty(GPSGPGGA2)
        GPSGPGGA2 = table();
        GPSGPGGA2.dateTime = currentDate;
        GPSGPGGA2.latitude = nan;
        GPSGPGGA2.longitude = nan;
        GPSGPGGA2.altitude = nan;
        GPSGPGGA2 = table2timetable(GPSGPGGA2);
     end    
        
    predictedTable = synchronize(GPSGPGGA2,[predictedTablePre,predictedTablePost],'union','linear');

    predictedTable(end,:) = [];
    
%     predictionCorrection = zeros(height(predictedTable),1);

    
    %% 
    display(newline)
    display("Applying Corrections")
    
    % Zero Correction 
    %sum(predictedTable.pm1_Predicted<0)
%     predictionCorrection = predictionCorrection |(predictedTable.pm1_Predicted<0);
    predictedTable.pm1_Predicted((predictedTable.pm1_Predicted<0),:)=0;

    %sum(predictedTable.pm2_5_Predicted<0)
%     predictionCorrection = predictionCorrection | (predictedTable.pm2_5_Predicted<0);
    predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted<0),:)=0;

    %sum(predictedTable.pm4_Predicted<0)
%     predictionCorrection = predictionCorrection | (predictedTable.pm4_Predicted<0);
    predictedTable.pm4_Predicted((predictedTable.pm4_Predicted<0),:)=0;

    %sum(predictedTable.pm10_Predicted<0)
%     predictionCorrection = predictionCorrection | (predictedTable.pm10_Predicted<0);
    predictedTable.pm10_Predicted((predictedTable.pm10_Predicted<0),:)=0;
    
%     predictionCorrection = predictionCorrection | (predictedTable.pmTotal_Predicted<0);
    predictedTable.pmTotal_Predicted((predictedTable.pmTotal_Predicted<0),:)=0;

%     predictionCorrection = predictionCorrection |(predictedTable.dCn_Predicted<0);
    predictedTable.dCn_Predicted((predictedTable.dCn_Predicted<0),:)=0;
    
    %% PM Corrections 

    %sum((predictedTable.pm2_5_Predicted>predictedTable.pm10_Predicted))
%     predictionCorrection = predictionCorrection | (predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted);
    predictedTable.pm4_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) =...
                               predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) ;  

    %sum((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted))                       
%     predictionCorrection = predictionCorrection | (predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted);                       
    predictedTable.pm1_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) =...
                                predictedTable.pm2_5_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) ;

    %sum((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted))                          
%     predictionCorrection = predictionCorrection | (predictedTable.pm4_Predicted>predictedTable.pm10_Predicted);  
    predictedTable.pm10_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) =...
                                predictedTable.pm4_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) ;

    %sum((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted))                          
%     predictionCorrection = predictionCorrection | (predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted);  
    predictedTable.pmTotal_Predicted((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted),:) =...
                                predictedTable.pm10_Predicted((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted),:) ;

    %% Checks                      

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
    end
    
    predictedTable.Properties.VariableNames = varNames;
    
    printCSVTT(predictedTable,updateFolder,nodeID,currentDate,'calibrated');
    printCSVT(bestModelsLabels,updateFolder,nodeID,currentDate,'modelInfo');
    
    %% Plotting 
    if (minute(currentDate)<1)
       display(newline)
       display("Printing Plots")
       
        %% Plotting only once per hour 
        timeSeriesPlotsTLL(predictedTable,...
                               nodeID,...
                                  currentDate,...
                                       updateFolder,...
                                         "UTC");


        currentDateStr = char(currentDate);
        dateStr = currentDateStr(1:11);
        if sum(contains(varNames,'Bin')) == 16 
           contourPlotOPCN2(predictedTable,nodeID,{"UTC Time(hours)"; dateStr},...
                                                          "Particle Diametors(\mum)",...
                                                                "Particle Size Distribution ",...
                                                                      currentDate,...
                                                                        updateFolder,...
                                                                         "Contour_UTC_Time"...
                                                                           );


        elseif sum(contains(varNames,'Bin')) == 24
            contourPlotOPCN3(predictedTable,nodeID,{"UTC Time(hours)"; dateStr},...
                                                          "Particle Diametors(\mum)",...
                                                                "Particle Size Distribution ",...
                                                                      currentDate,...
                                                                        updateFolder,...
                                                                         "Contour_UTC_Time"...
                                                                         );            
        end 
          
    end
    
    display(newline)
    toc   
    
    display(newline)
    display("MINTS Done")
    

end


