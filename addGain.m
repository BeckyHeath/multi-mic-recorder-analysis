% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Automate Adding Gain to an archive of audio depending on need
%
%
% Becky Heath with advice from Dan Harmer + Lorenzo Picinali
% Summer 2022
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Information repos: 
raw = readtable("Data/AnomolyDatasheets/AvgAbs_justPostMortemLab.csv");
desc = readtable("Data/AnomolyDatasheets/AvgAbs_justPostMortemLab_Desc.csv");

% Iterate through files and work out if you can analyse?
for i = 1:size(desc,1)
    
    % Seperate file name and Data
    file = char(desc{i,1});
    data = desc{i,2:7};

    % Don't do anything to files that are okay
    if sum(count(data,"ok")) == 6
        disp(file + " is ok! no changes made")
    end 
    
    if sum(count(data,"OverPower")) >= 1
        
        opChans = count(data,"OverPower"); 
        disp(file + " contains " + sum(count(data,"OverPower")) + "x OP channels")

        rawDat = raw{i,2:7};

        % Isolate and average just the overpowered channels:
        opRaw = rawDat.*opChans;
        avgOp = sum(opRaw)/sum(opChans);
        
        % Find the average of other channels
        upRaw = rawDat - (rawDat.*opChans);
        avgUp = sum(upRaw)/(6-sum(opChans));
        
        % Find factor difference
        opFactor = avgOp/(avgUp);
        
        disp(file + " has an OP factor of " +  opFactor);

        % Times all the relevant channels by the OP factor! 
        % Save as wavs somewhere else 
        % Run through HARKBird 
        % Great success :) 

    end 





end