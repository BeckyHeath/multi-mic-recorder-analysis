% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we're looking to detect gain/ dead channel issues!
% Adapted from Field + Lab test scipts for general use
%
%
% Becky Heath with advice from Dan Harmer + Lorenzo Picinali
% Summer 2022
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));


% Set audio and output locations 
audio_dir_path = 'Data\postMortem\LabLocalisation\Cleaned_wavs\'; % path to audio 
outFileRoot = "Data\AnomolyDatasheets"; % include file name, but DO NOT include ending (.csv)


recLength = 600; % Recording Length (seconds)
recFreq = 16000; % Recording Frequency (Hz)

% Setup Output DFs: 
outMat = ["fileName","ch1","ch2","ch3","ch4","ch5","ch6"];

outDesc = ["fileName","ch1","ch2","ch3","ch4","ch5","ch6"];

      
% Get Filenames
filenames = getfn(audio_dir_path, ".wav");

% Load in data and join all sprectral data together
for i = 1:size(file_names,2)

    %Load in File
    fileName = string(file_names{1,i});
    filePath = audio_dir_path + file_names{1,i};

    samples = [1,recLength*recFreq]; 
    aud = audioread(filePath,samples);
    
    % Use the absolute of the mean values to 
    % get a metric of the status of each channel
    outRaw= mean(abs(aud));
      
    % consolidate this data:     
    outLine = [filePath,outRaw]; % add file label
    outMat = [outMat;outLine];


    % Get Text Descriptions here (Edit if necessary)
    outRaw = string(outRaw);
    for j = 1:size(outRaw,2)
        val = str2double(outRaw(j));
        if val >= 0.01
            outRaw(j) = "OverPower";
        end
        if val < 0.01
            outRaw(j) = "ok";
        end
        if val <= 0.0005
            outRaw(j) = "dead";
        end
    end
    
    % Consolidate info: 
    outRaw = [filePath,outRaw]; % Append file name
    outDesc = [outDesc;outRaw];
    
end      

rawFileName = outFileRoot + ".csv";
descFileName = outFileRoot + "_Desc.csv";
writematrix(outMat,rawFileName);
writematrix(outDesc,descFileName);

fclose('all');
