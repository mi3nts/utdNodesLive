
clc
clear all
close all 

% % 
addpath("../functions/");

addpath("YAMLMatlab_0.4.3");
    currentDate= datetime('now','timezone','utc');
    display(currentDate);
for n = 1:15
    try
        liveRunDaily(string(n),...
            '/media/teamlary/teamlary1/gitHubRepos/utdNodesLive/firmware/mintsDefinitions.yaml'...
            );
    catch e
        display(e)     
    end    
end       
    currentDate= datetime('now','timezone','utc');
    display(currentDate);  
%  readYamlFile('/media/teamlary/teamlary1/gitHubRepos/utdNodesLive/firmware/mintsDefinitions.yaml')
 



%% 2 No Node Data - Not active 
%% 3 - Pm2.5 and pm 10 are not working 
% 5 Alpha Sensor Failing - But it works 
%% 9 no data  
%% 12 No model for pressure 
%% 14 No model for pressure or humidity 

