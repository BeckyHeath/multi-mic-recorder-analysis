% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we're looking to detect gain issues!
%
% Becky Heath with advice from Dan Harmer + Lorenzo Picinali
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% get a file list for the audio to be analysed: 
audio_dir_path = "Data\postMortem\LabLocalisation\Cleaned_wavs\";
files = dir(audio_dir_path + "*.wav");
file_names =  { files.name };

% Load in Audio 

outMat = ["fileName","ch1","ch2","ch3","ch4","ch5","ch6"];

outDesc = ["fileName","ch1","ch2","ch3","ch4","ch5","ch6"];

% Load in data and join all sprectral data together
for i = 1:size(file_names,2)
    %Load in File
    fileName = string(file_names{1,i});
    filePath = audio_dir_path + file_names{1,i};

    samples = [1,75*16000]; % Sweeps are first 10s, whole rec ~1.15s
    aud = audioread(filePath,samples);
    
    % Use max to get a metric of the status of each channel
    outRaw= mean(abs(aud));
      
    % consolidate this data:     
    outLine = [fileName,outRaw];
    outMat = [outMat;outLine];


    % Get Descriptions here
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
    
    outRaw = [fileName,outRaw];
    outDesc = [outDesc;outRaw];
    
    disp(outLine);

end 


% Find sweep spectra per channel 

% compare levels?

% adjust the gain accordingly?


