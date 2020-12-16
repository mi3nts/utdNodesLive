
clc
clear all
close all 

% % 
addpath("functions/");

addpath("YAMLMatlab_0.4.3");

% currentDate= datetime('now','timezone','utc');
% display(currentDate);
%     
% daysBack = daysact(datetime(2020,10,10),today)    
% 

% liveRunTimedDynamic(string(11),...
%             '/media/teamlary/teamlary1/gitHubRepos/utdNodesLive/firmware/mintsDefinitions.yaml'...
%                  );

while (true)
     for n = 1:15
        try
            liveRunTimedDynamic(string(n),...
                'mintsDefinitions.yaml'...
                );
        catch e
            display(e)     
        end
        
        clear all -except n
        pause(5)
    end
end 



% 
% currentDate= datetime('now','timezone','utc');
% display(currentDate);  
%  readYamlFile('/media/teamlary/teamlary1/gitHubRepos/utdNodesLive/firmware/mintsDefinitions.yaml')
 
%      liveRunPeriodic(string(1),...
%             '/media/teamlary/teamlary1/gitHubRepos/utdNodesLive/firmware/mintsDefinitions.yaml',...
%                 string(1)...
%             );


%% 2 No Node Data - Not active 
%% 3 - Pm2.5 and pm 10 are not working 
% 5 Alpha Sensor Failing - But it works 
%% 9 no data  
%% 12 No model for pressure 
%% 14 No model for pressure or humidity 

