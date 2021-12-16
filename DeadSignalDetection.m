% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for Detecting Dead Channels in
% multichannel recording 
%
% Becky Heath
% Winter 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

rootPath = "Data\Blue\";
dirs = ["pre10May","early","late"];

clearvars outArray
outArray = ["FileRoot" "FileName" "ch1" "ch2" "ch3" "ch4" "ch5" "ch6"]; 

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

        for ch = 1:6
            count = sum(aud(:,ch) > 0.005);
            if count > 9600
                outLine(ch+2)= "ok";
            elseif count > 1500
                outLine(ch+2)= "part";
            else 
                outLine(ch+2)= "dead"; 
            end 
        end 
        disp(outLine)

        outArray=[outArray;outLine];
    end
end





