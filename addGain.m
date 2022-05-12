% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Automate Adding Gain to a repo of audio depending on need
%
%
% Becky Heath with advice from Dan Harmer + Lorenzo Picinali
% Summer 2022
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Information repos: 
raw = readtable("Data/AnomolyDatasheets/Field_maxAbs_automated.csv");
desc = readtable("Data/AnomolyDatasheets/Field_maxAbs_automated_Desc.csv");

outFiles = "Data/postMortem/LabLocalisation/AdjustedGain/justAbs/";

% Recording Details: 
reqLen = 80;
reqFreq = 16000;


% set up 

fullOn = [1,1,1,1,1,1];


% Iterate through files and work out if you can analyse?
for i = 1:size(desc,1)
    
    % Seperate file name and Data
    file = char(desc{i,1});
    data = desc{i,2:7};

    % Don't do anything to files that are okay
    if sum(count(data,"ok")) == 6
        disp(file + " is ok! no changes made")

        % Load in corresponding audio
        samples = [1,reqLen*reqFreq];
        aud = audioread(file,samples);

        outName = split(file,"\");
        outName = outName{size(outName,1),1};
        
        outFN = outFiles + outName;
        audiowrite(outFN,aud,reqFreq)

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
        
        % Load in corresponding audio
        samples = [1,reqLen*reqFreq];
        aud = audioread(file,samples);
        
        % Multiply the gain factor to the audio (just chans that need it)
        new_vals = aud.*((opFactor*(fullOn-opChans))/2) + (aud.*opChans);
        

        %Write Elsewhere
        
        outName = split(file,"\");
        outName = outName{size(outName,1),1};
        
        outFN = outFiles + "AdjG_" + outName;
        audiowrite(outFN,new_vals,reqFreq)

        % Run through HARKBird 
        % Great success :) 

    end 





end