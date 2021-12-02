% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for recording folders of
% Audio from different time points
%
% Becky Heath
% Winter 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% get a file list for the audio to be analysed: 
% You may need to generate these files form the raw ones first


rootPath = "Data\Yellow_Field_Recordings\";
dirs = ["pre_24Aug","early","late"];

j=0;
figure('WindowState','maximized')
for k = 1:size(dirs,2)

   path = rootPath + dirs(k) + "\";


    Files = dir(path + "*.wav");
    FileNames =  { Files.name };

    %j=j+1;
    for ch = 1:6
        j=j+1;
        for fileNo = 1:size(FileNames,2)

            i_file = path + FileNames(fileNo);
            samples = [1,60*16000]; % Just look at the first minute
            aud = audioread(i_file,samples);
            audCh = aud(:,ch); % Make iterative

            [p,frequencies] = pspectrum(audCh,16000);
            pdb = cat(2,frequencies,pow2db(p));
            
            % Organise titles and axis labels:
            if ch == j
                pltTitle = "ch=" + ch;
            else 
                pltTitle = "";
            end

            if j==1
                ylab = "Pre Deloyment";
            elseif j==7
                ylab = dirs(k);
            elseif j==13
                ylab = dirs(k);
            else 
                ylab="";
            end
            
            % Plot Spectrogram
            subplot(3,6,j);
            e=plot(pdb(:,1), pdb(:,2), 'color','#D95319','linewidth',1);e.Color(4)=0.4;
            title(pltTitle)
            ylabel(ylab)
            hold on
        end    
    end
end
figname = "Figures/Yellowdata/GroupedSpectraAll.png" ;
saveas(gcf, figname)


