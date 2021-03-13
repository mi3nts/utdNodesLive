function [] = liveRun2021(nodeIndex,yamlFile)
    
    tic
    display(newline)
    display("---------------------MINTS---------------------")
    
    nodeIndex = round(str2double(nodeIndex)) ;
    currentDate= datetime('now','timezone','utc') 
    display(currentDate);
    
    mintsDefinitions   = ReadYaml(yamlFile);

    nodeIDs            = mintsDefinitions.nodeIDs;
    dataFolder         = mintsDefinitions.dataFolder;
    mintsTargets       = mintsDefinitions.mintsTargets;

    rawFolder          =  dataFolder + "/raw";
    rawMatsFolder      =  dataFolder + "/rawMats";
    updateFolder       =  dataFolder + "/liveUpdate/results/";
    scanFolder         =  dataFolder + "/liveUpdate/scan/";
    modelsFolder       =  dataFolder + "/modelsMats/UTDNodes/";

       
    timeSpan           =  seconds(mintsDefinitions.timeSpan);
    nodeID             =  nodeIDs{nodeIndex}.nodeID;
    display(nodeID);
    
    timeFile         =  strcat(scanFolder,"t_"+nodeID,".mat")
    folderCheck(timeFile)
    display(timeFile);
    
    todaysNodeFolder   = strcat(rawFolder,"/",nodeID,"/",...
                                num2str(year(currentDate),'%04d'),"/",...
                                num2str(month(currentDate),'%02d'),"/",...
                                num2str(day(currentDate),'%02d'))    ;                                
                            
    resultsFile        = modelsFolder+ "WS.csv";

    display(newline);
    display("Data Folder Located      @ :"+ dataFolder);
    display("Raw Data Located         @ :"+ rawFolder );
    display("Raw DotMat Data Located  @ :"+ rawMatsFolder);
    display("Update Data Located      @ :"+ updateFolder);
    display("Results File Located     @ :"+ resultsFile);
    display(newline)
    
    %AS7262Files      =  dir(strcat(currentFolder,'/*AS7262*.csv'))
    BME280Files      =  dir(strcat(todaysNodeFolder,'/*BME280*.csv'));
    GPSGPGGA2Files   =  dir(strcat(todaysNodeFolder,'/*GPSGPGGA2*.csv'));
%   GPSGPRMC2Files   =  dir(strcat(todaysNodeFolder,'/*GPSGPRMC2*.csv'));
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
    
    display(newline)
    display("Reading Raw Data")
    
    
    [BME280,GPSGPGGA2,MGS001,OPCN2,OPCN3,PPD42NSDuo,SCD30]...
                            = dataInput(BME280Files,GPSGPGGA2Files,...
                                    MGS001Files,OPCN2Files,OPCN3Files,PPD42NSDuoFiles,SCD30Files,...
                                        @readFast,@GPGGAReadFast,...
                                            timeSpan);
                                        
   
    eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
%    eval(strcat("inputStack       = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("latestStack      = mintsDefinitions.latestStack",string(nodeIDs{nodeIndex}.inputStack),";"));

    display(newline)
    display("Saving UTD Nodes Data");
    concatStr  =  "latestDataAll   = synchronize(";
    for stackIndex = 1: length(latestStack)
        concatStr = strcat(concatStr,latestStack{stackIndex},",");
    end
    concatStr  = strcat(concatStr,"'union');")   ;
    eval(concatStr)

    if nodeIDs{nodeIndex}.inputStack == 1 
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature ;
    end     

    if nodeIDs{nodeIndex}.inputStack == 2
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature_BME280 ;
       latestDataAll.humidity_mintsDataBME280 = latestDataAll.humidity_BME280 ;
    end   

    if nodeIDs{nodeIndex}.inputStack == 20
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature_BME280 ;
       latestDataAll.humidity_mintsDataBME280 = latestDataAll.humidity_BME280 ;
    end

    if nodeIDs{nodeIndex}.inputStack == 21
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature_BME280 ;
       latestDataAll.humidity_mintsDataBME280 = latestDataAll.humidity_BME280 ;
    end


    if nodeIDs{nodeIndex}.inputStack == 3
       latestDataAll.temperature_mintsDataBME280 = latestDataAll.temperature_BME280 ;
       latestDataAll.humidity_mintsDataBME280 = latestDataAll.humidity_BME280 ;
       latestDataAll.temperature_mintsDataSCD30 = latestDataAll.temperature_SCD30 ;
       latestDataAll.humidity_mintsDataSCD30 = latestDataAll.humidity_SCD30 ;
       latestDataAll(isnan(latestDataAll.c02),:) = [];
    end 
  
    printName=getPrintName(updateFolder,nodeID,currentDate,'calibrated');
    
    latestDataAll(isnan(latestDataAll.temperature_BME280),:) = [];
    latestDataAll(isnan(latestDataAll.no2),:) = [];
    latestDataAll(isnan(latestDataAll.binCount0),:) = [];

    
    csvAvailable =     isfile(printName);
        
%    mintsInputs';

    if csvAvailable
        currentTime          =  load(timeFile).nextTime;
        In                   =  table2array(latestDataAll(latestDataAll.dateTime>currentTime,mintsInputs));
        predictedTablePre    = latestDataAll(latestDataAll.dateTime>currentTime,contains(latestDataAll.Properties.VariableNames,"binCount"));
        strCombine = "predictedTablePost = timetable(latestDataAll.dateTime(latestDataAll.dateTime>currentTime)";
    else
        currentTime = datetime(2016,1,1,'timezone','utc')
        In  =  table2array(latestDataAll(:,mintsInputs));
        predictedTablePre = latestDataAll(:,contains(latestDataAll.Properties.VariableNames,"binCount"));
        strCombine = "predictedTablePost = timetable(latestDataAll.dateTime";
    end
    

    nextTime = latestDataAll.dateTime(end);

    if currentTime == nextTime 
        display("No new Data for Node:" +  nodeID)
        return;
    end      
      
    display(newline)
    
    
    %% Loading the appropriate models 
    display(newline)
    display("Loading Best Models")
       
    [bestModels,bestModelsLabels] = readResultsNow(resultsFile,nodeID,mintsTargets,modelsFolder);
 %   bestModelsLabels;

    if(sum(cellfun(@isempty,bestModels))>0 || length(bestModels)<10)
        display("Insuffient Number of Models Saved for Node:" +  nodeID)
        return;
    end    
    
    display("Gaining Super Learner Predictions")
    
    for n = 1: length(bestModels)
       eval(strcat(mintsTargets{n},"_predicted= " , "predictrnn(bestModels{n},In);"));
    end


    for n = 1: length(bestModels)
       strCombine = strcat(strCombine,",",mintsTargets{n},"_predicted");
    end
    
    eval(strcat(strCombine,");"));

    predictedTablePost.Properties.VariableNames =  strrep(strrep(mintsTargets+"_Predicted","_palas",""),"Airmar","");

    if isempty(GPSGPGGA2)
        GPSGPGGA2 = table();
        GPSGPGGA2.dateTime = currentDate;
        GPSGPGGA2.latitudeCoordinate = nan;
        GPSGPGGA2.longitudeCoordinate = nan;
        GPSGPGGA2.altitude = nan;
        GPSGPGGA2 = table2timetable(GPSGPGGA2);
    end    
        
    predictedTable = synchronize(GPSGPGGA2,[predictedTablePre,predictedTablePost],'last');
    predictedTable = predictedTable(height(predictedTable)-height(predictedTablePost)+2:end-1,:);
    predictedTable.altitude(isnan(predictedTable.altitude))=nodeIDs{nodeIndex}.altitude;
    predictedTable.latitudeCoordinate(isnan(predictedTable.latitudeCoordinate))=nodeIDs{nodeIndex}.latitude;
    predictedTable.longitudeCoordinate(isnan(predictedTable.longitudeCoordinate))=nodeIDs{nodeIndex}.longitude;
  
    display("Applying Corrections")
    
    predictedTable.pm1_Predicted((predictedTable.pm1_Predicted<0),:)=0;

    predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted<0),:)=0;

    predictedTable.pm4_Predicted((predictedTable.pm4_Predicted<0),:)=0;

    predictedTable.pm10_Predicted((predictedTable.pm10_Predicted<0),:)=0;
    
    predictedTable.pmTotal_Predicted((predictedTable.pmTotal_Predicted<0),:)=0;

    predictedTable.dCn_Predicted((predictedTable.dCn_Predicted<0),:)=0;
    
    predictedTable.pm4_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) =...
                               predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) ;  

    predictedTable.pm1_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) =...
                                predictedTable.pm2_5_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) ;

    predictedTable.pm10_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) =...
                                predictedTable.pm4_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) ;

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
    predictedTable.dateTime.Format =  'uuuu-MM-dd HH:mm:ss.SSS';
    
    if csvAvailable
        writetimetable(predictedTable,printName,'WriteMode','append','WriteVariableNames',false)
    else 
        writetimetable(predictedTable,  printName)
    end
     
    
    save(timeFile,'nextTime'); 
    
    
    printCSVT(bestModelsLabels,updateFolder,nodeID,currentDate,'modelInfo');
    
    display(newline)
    toc   
    
    display(newline)
    display("MINTS Done")
    

end


