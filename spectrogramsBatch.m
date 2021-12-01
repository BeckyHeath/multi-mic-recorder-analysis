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

for k = 1:size(dirs,2)

   path = rootPath + dirs(k) + "\";


    Files = dir(path + "*.wav");
    FileNames =  { Files.name };

    for ch = 1:6

        figure('OuterPosition', [481 -5.4 720 870.4])
        j=1;
        for fileNo = 1:size(FileNames,2)

            i_file = path + FileNames(fileNo);
            samples = [1,60*16000]; % Just look at the first minute
            aud = audioread(i_file,samples);
            audCh = aud(:,ch); % Make iterative

            plotTitle = dirs(k) + " Channel=" + ch;

            % Plot Spectrogram
            subplot(5,2,j);
            spectrogram(audCh,1280,1200,1280,16000,'yaxis')
            xlabel("")
            ylabel("")
            caxis([-150 -50])
            %clabel("")
            hold on
            sgtitle(plotTitle) 
            j = j+1;

        end 
    figname = "Figures/Yellowdata/Spectrograms_"+ dirs(k) + "_ch" + ch + ".png" ;
    saveas(gcf, figname)
     
    end

end


