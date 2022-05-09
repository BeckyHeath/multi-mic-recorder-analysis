% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we're looking to detect gain/ dead channel issues!
% It works for Field Tests! 
%
% This is fast and good but the save files need tidying!
% Try to run on box?
%
% Becky Heath with advice from Dan Harmer + Lorenzo Picinali
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

outFileRoot = "Data\AnomolyDatasheets\Field_meanAbs";

colours = ["green","yellow","yellowgreen","Blue"];

for col =  1:size(colours,2)
    % Go first through recorders
    rootPath = "Data\" + colours(:,col) + "\";
    dirs = ["pre","early","late"];

        
     for k = 1:size(dirs,2)
        % Then through the subdirs get filelists
        audio_dir_path = rootPath + dirs(k) + "\";
        files = dir(audio_dir_path + "*.wav");
        file_names =  { files.name };
        
        % Decide where files shoud be saved (and most of their name):
        outFileSubroot = outFileRoot + "_" + colours(:,col) + "_" +  dirs(k);
        
        outMat = ["fileName","ch1","ch2","ch3","ch4","ch5","ch6"];

        outDesc = ["fileName","ch1","ch2","ch3","ch4","ch5","ch6"];

        % Load in data and join all sprectral data together
        for i = 1:size(file_names,2)
            %Load in File
            fileName = string(file_names{1,i});
            filePath = audio_dir_path + file_names{1,i};
        
            samples = [1,600*16000]; % Sweeps are first 10s, whole rec ~1.15s
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
            
                 % Save to CSVs
            rawFileName = outFileSubroot + ".csv";
            descFileName = outFileSubroot + "_Desc.csv";
            writematrix(outMat,rawFileName);
            writematrix(outDesc,descFileName);
                %disp(outLine);
        
        end 

        
        fclose('all');
     end
end


