function [] = livePlotter(nodeIndex,yamlFile)
    
    tic
    display(newline)
    display("---------------------MINTS---------------------")
    
    nodeIndex = round(str2double(nodeIndex)) ;
    currentDate= datetime('now','timezone','utc') ;
    
    display(currentDate);
    display(newline)
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
    
    printName=getPrintName(updateFolder,nodeID,currentDate,'calibrated');
    
    if ~isfile(printName)
        display("No data for node " + nodeID)
        return;
    end
        
	
    
    
    predictedTable = table2timetable(tabularTextDatastore(printName).read);
    predictedTable = unique(rmmissing(predictedTable));   
    predictedTable = sortrows(predictedTable,'dateTime');

    predictedTable(diff(predictedTable.dateTime) == 0,:)=[];
    
    
    
    varNames = predictedTable.Properties.VariableNames;   

    
    
    %% Plotting 
    
    display("Printing Plots")
    display(newline)
    
    display("Printing Time Series Plots")
    display(newline)
    timeSeriesPlotsTLL(predictedTable,...
                               nodeID,...
                                  currentDate,...
                                       updateFolder,...
                                         "UTC");


    currentDateStr = char(currentDate);
    dateStr = currentDateStr(1:11);
        
    display("Printing Contour Plots")
    
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

    display(newline)
    toc   
    
    display(newline)
    display("MINTS Done")
    

end


