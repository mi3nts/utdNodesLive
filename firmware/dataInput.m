function [BME280,GPSGPGGA2,MGS001,OPCN2,OPCN3,PPD42NSDuo,SCD30]...
                        = dataInput(BME280Files,GPSGPGGA2Files,...
                                MGS001Files,OPCN2Files,OPCN3Files,PPD42NSDuoFiles,SCD30Files,...
                                    readFast,GPGGAReadFast,...
                                        timeSpan)

    BME280      =  sensorReadSolo(BME280Files,@readFast,timeSpan);
    GPSGPGGA2   =  sensorReadSolo(GPSGPGGA2Files,@GPGGAReadFast,timeSpan);
    MGS001      =  sensorReadSolo(MGS001Files,@readFast,timeSpan);
    OPCN2       =  sensorReadSolo(OPCN2Files,@readFast,timeSpan); 
    OPCN3       =  sensorReadSolo(OPCN3Files,@readFast,timeSpan); 
    PPD42NSDuo  =  sensorReadSolo(PPD42NSDuoFiles,@readFast,timeSpan); 
    SCD30       =  sensorReadSolo(SCD30Files,@readFast,timeSpan); 
    
end

