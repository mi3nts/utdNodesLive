function [] = printCSVTTWithPlots(calibrated,updateFolder,nodeID)
%
%     PRINTCSVDAILY Summary of this function goes here
%     Initially divides up all the timetable by day
%     then saves them as csv files for historic data
%     should have the appropriate naming convention
%     as the live daily csvs

datesIn =  datetime('today','timezone','utc') -1 :-day(1): datetime(2017,1,1,'timezone','utc');

for dateIndex = 1: length(datesIn)
    currentDate =  datesIn(dateIndex) ;
    display("Printing files for Node: " +nodeID + " for " + string(currentDate) )
    
    predictedTable = calibrated(currentDate<=calibrated.dateTime & ...
        calibrated.dateTime<currentDate+1,:);
    
    % Get data for the current day
    
    if(height(predictedTable)>50)
        printCSVTT(predictedTable,updateFolder,nodeID,currentDate,'calibrated');
        %             printCSVT(bestModelsLabels,updateFolder,nodeID,currentDate,'modelInfo');
        
        %% Plotting
        
        %% Plotting only once per hour
        timeSeriesPlotsTLL(predictedTable,...
            nodeID,...
            currentDate,...
            updateFolder,...
            "UTC");
        
        
        varNames = predictedTable.Properties.VariableNames;
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
    
end

end
