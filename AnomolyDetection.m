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
            
%             % find variance % Worked okay but try RMS 
%             V = var(aud); 
%             V = V/1.0e-05;
%             
%             outLine(3:8) = V;

            % try RMS OR MAYBE MEDIAN SPECTRA??
            % Try bringing in spectral info! 
            
            RMS = rms(aud); 
            RMS = RMS/0.001;
            RMS = log(RMS);
            
            outLine(3:8) = RMS;

            A = outLine(1,3:8);
            B = str2double( A(:,:) );
            outlier = isoutlier(B);
            outLine(3:8) = outlier;

            countlier = sum(outLine == "true"); % MAYBE (check this) 
            outLine(9) = countlier;
    
            outArray=[outArray;outLine];
        end
    end
    
    outFileName = 'Data/' + colour + "TF_RMS_OUTLIER.csv";
    
    writematrix(outArray,outFileName);
    
    disp(colour + " done")

end 





