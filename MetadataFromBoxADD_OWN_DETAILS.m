% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading and Exploring Box Repo 
%
% *** YOU'LL NEED TO SET UP THE BOX INFO WITH YOUR 
%     OWN DATA - IT'S DELIBERATELY OMITTED HERE ***
%
% Becky Heath
% Winter 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Put in the names of files you're after looking at
rootDirNames = ["03_v2_Blue", "rec02_yellow", "rec04_yellowgreen", "Rec01_green"];

% Setup out Array 
clearvars outArray
outArray = ["Recorder" "date" "numFiles" "TotFileSizeMB"]; 

for j = rootDirNames 
    % ************* ADD DETAILS HERE **************************
    %ftpobj = ftp("ftp.box.com",USERNAME,PASSWORD,"TLSMode","strict");

    disp("FTP Object Set up for " + j);
    root = j;

    % Navigate to filelist (as per the Sethi setup) 
    cd(ftpobj, root);
    cd(ftpobj, "live_data");
    RPiID = dir(ftpobj);
    cd(ftpobj, RPiID.name);
    dirList = dir(ftpobj);
    
    % Find out how many days have recordings 
    numDirs =  size(dirList,1);
    
    for i = 1:numDirs
    
        if mod(i,30) == 0 % reset the ftp every 50
            disp("resetting FTP object at "+ i);
            % ************* ADD DETAILS HERE **************************
            %ftpobj = ftp("ftp.box.com",USERNAME,PASSWORD,"TLSMode","strict");
            dir(ftpobj);
            
            % Navigate to filelist (as per the Sethi setup) 
            cd(ftpobj, root);
            cd(ftpobj, "live_data");
            RPiID = dir(ftpobj);
            cd(ftpobj, RPiID.name);
            dirList = dir(ftpobj);
        end 
    
    
        % Select and Move to subfolder
        folder = dirList(i,1).name; 
        cd(ftpobj, folder);
        
        % Get a filelist for dir
        files = dir(ftpobj);
        numFiles = size(files,1);

        if numFiles ~= 0         
            % Get the total filesize in MB 
            byteSize = extractfield(files, "bytes")/1000000; % in Megabytes
            folderTot = sum(byteSize); % ib Megabytes
            
            % Determine Output and add to OutArray
            outLine = [root folder numFiles folderTot];
            outArray = [outArray; outLine];
        else
            % Determine Output and add to OutArray
            outLine = [root folder numFiles "NA"];
            outArray = [outArray; outLine];
        end 
    
        disp(i + " of " + numDirs + " done");
        cd(ftpobj, "../"); % Move back to Root   
    
    end 
end


% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Write to a csv 
outFileName = "Data/MetaData.csv";
writematrix(outArray,outFileName); 
