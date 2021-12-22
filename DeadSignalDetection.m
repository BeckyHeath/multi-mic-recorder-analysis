% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for Detecting Dead Channels in
% multichannel recording 
%
% TODO: Optimise? This is very slow
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
    outArray = ["FileRoot" "FileName" "ch1" "ch2" "ch3" "ch4" "ch5" "ch6" "deadCh" "partDeadCh"]; 
    
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
            outLine = [dirPath FileNames(fileNo) 0 0 0 0 0 0 0];
    
            for ch = 1:6
    
                a = aud(:,ch);
                labeled = bwlabel(a < 0.002);
                measurements = regionprops(labeled, a, 'area', 'PixelValues');
                % Get all the areas (lengths of runs above threshold).
                allAreas = [measurements.Area];
    
                % Sort them in descending order
                [sortedAreas, sortIndices] = sort(allAreas, 'Descend');
                chain = sortedAreas(1);
    
                if chain > 9599000
                    outLine(ch+2)= "X"; % dead signal
                elseif chain > 100000
                    outLine(ch+2)= "/"; % part gone (drop out)
                else 
                    outLine(ch+2)= "-"; % signal okay
                end 
           end 
            
            % Find number of channels that are broken:
            deadCh = sum(outLine == "X");
            outLine(9) = deadCh;
            
            PartdeadCh = sum(outLine == "/");
            outLine(10) = PartdeadCh;
    
            outArray=[outArray;outLine];
        end
    end
    
    outFileName = 'Data/' + colour + "DeadStrings.csv";
    
    writematrix(outArray,outFileName);
    
    disp(colour + " done")

end 





