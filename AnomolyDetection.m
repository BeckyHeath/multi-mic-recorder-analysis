% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for Detecting Anomolies in
% multichannel recording 
%
% Becky Heath
% Winter 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

rootPath = "Data\Yellow_Field_Recordings\";
dirs = ["pre_24Aug","early","late"];

for k = 1:size(dirs,2)

    path = rootPath + dirs(k) + "\";
    Files = dir(path + "*.wav");
    FileNames =  { Files.name };

    for fileNo = 1:size(FileNames,2)

        % Read File and Generate Power Spectrum 
        i_file = path + FileNames(fileNo);
        samples = [1,60*16000]; % Just look at the first minute
        aud = audioread(i_file,samples);
        [p,frequencies] = pspectrum(aud,16000);
        pdb = pow2db(p);
        
        TF = [0 0 0 0 0 0]; % Initialise anomoly df
        % Detect Outliers row by row 
        for row = 1:size(pdb,1)
            [B,TF1] = rmoutliers(pdb(row,:));
            TF = vertcat(TF,TF1);
        end
        
        tots = sum(TF); 
        disp(tots)
        for val = 1:size(tots,2)

            if tots(1,val) > 1000
                out = "*******"+dirs(k) +": " + FileNames(fileNo) + ": " +  " CH: " + val + " IS ANOMOLOUS";
            else 
                out = dirs(k) +": " + FileNames(fileNo) + ": " +  " ch: " + val + " is ok";
            end 
            disp(out)
        end          
    end
end





