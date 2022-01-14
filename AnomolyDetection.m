% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for Detecting Quieter Channels in
% multichannel recording 
%
% This is taking ages - check why (seems wierd)
%
% Becky Heath
% Winter 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

colours = ["green","yellow","yellowgreen","Blue"];

for col =  1:size(colours,2)
    colour = colours(:,col);

    rootPath = "Data\" + colour + "\";
    dirs = ["pre","early","late"];
    
    clearvars outArray
    outArray = ["FileRoot" "FileName" "ch1" "ch2" "ch3" "ch4" "ch5" "ch6" "OutlierNum"]; 
    
    for k = 1:size(dirs,2)
        
        path = rootPath + dirs(k) + "\";
        Files = dir(path + "*.wav");
        FileNames =  { Files.name };
    
        for fileNo = 1:size(FileNames,2)
    
            % Read File and determine if signal is on
            i_file = path + FileNames(fileNo);
            samples = [1,600*16000]; % Recordings are 10 minutes
            aud = audioread(i_file,samples);
            
            dirPath = rootPath + dirs(k);
            outLine = [dirPath FileNames(fileNo) 0 0 0 0 0 0];

%             mid = bandpower(aud,16000,[2000 5000]);
%             
%             outLine(3:8) = mid;

            % MAYBE TRY FINDPEAKS?

            % Calculate the proportional difference between 
            % High and low bands (based on NDSI index) 
            lowProp = bandpower(aud,16000,[1000 2000]);
            highProp = bandpower(aud,16000,[2000 8000]);

            compProp = lowProp./highProp;
            outLine(3:8) = compProp;
            
%             % Also tried using Variance: 
%             V = var(aud); 
%             V = V/1.0e-05;
%             
% %           outLine(3:8) = V;
% 
%             % Also also tried using RMS: 
%             RMS = rms(aud); 
%             RMS = RMS/0.001;
%             RMS = log(RMS);
%             
%             outLine(3:8) = RMS;



% % Add this in again in a bit I just wanna see (:
%             A = outLine(1,3:8);
%             B = str2double( A(:,:) );
%             outlier = isoutlier(B);
%             outLine(3:8) = outlier;
% 
%             countlier = sum(outLine == "true"); % MAYBE (check this) 
%             outLine(9) = countlier;
%     
            outLine(9) = "easyTiger";
            outArray=[outArray;outLine];
        end
    end
    
    outFileName = 'Data/' + colour + "NDSI_raw.csv";
    
    writematrix(outArray,outFileName);
    
    disp(colour + " done")

end 





