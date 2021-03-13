

% MINTS
% Main Live 2021 
% Written on March 12 2021 


clc
clear all
close all 


addpath("functions/");
addpath("YAMLMatlab_0.4.3");


while (true)
     for n = 1:15
%         try
            liveRun2021(string(n),...
                'mintsDefinitions.yaml'...
                );
 %        catch e
  %           display(e)     
   %      end
        clear all -except n
        pause(5)
    end
end 


