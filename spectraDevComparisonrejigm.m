% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Looking at Spectra from each channel 
% For all 4 Devices
%
% Becky Heath
% Spring 2022
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));


% One at a time
rootPaths = ["Data\yellow\early\","Data\yellowgreen\early\","Data\Blue\early\","Data\green\early\"];
%rootPaths = ["Data\yellow\early\"];


figureNames = ["Figures/MicQualData/yellowfull.png","Figures/MicQualData/yellowgreenfull.png","Figures/MicQualData/bluefull.png","Figures/MicQualData/greenfull.png"];

% Play with these Order: Yellow, YellowGreen, Blue, Green
colours = ["F6BD60","86CB92","12664F","00A7E1"];
colours2 = ["EAC435","18FF6D", "5C9EAD", "415D43"];

for k = 1:size(rootPaths,2)
    rootPath = rootPaths(k);
    figName = figureNames(k);

    Files = dir(rootPath + "*.wav");
    FileNames =  { Files.name };
    
    %figure('WindowState','maximized')
    
    for fileNo = 1:size(FileNames,2)
        i_file = rootPath + FileNames(fileNo);
        
        %Load in Audio
        aud = audioread(i_file,[1,600*16000]); % Load in full file 
        
        % Work out spectra minutewise
        for endSamp = 960000:960000:9600000
            startSamp = 1;
            samples = [startSamp,endSamp];
            
            TestSection = aud(startSamp:endSamp,:);
            startSamp = endSamp; % Swap over the start/end point for next loop
            
            % Iterate through channels
            j=0;
            for ch = 1:6
                j=j+1;
                audCh = aud(:,ch);
                [p,frequencies] = pspectrum(audCh,16000);
                pdb = cat(2,frequencies,pow2db(p));

                ylab = "ch " +  j;
                
                col = "#"+ colours2(k);
                % Plot Spectrogram
                subplot(2,3,j);
                e=plot(pdb(:,1), pdb(:,2), 'color',col,'linewidth',1);
                e.Color(4)=0.2;
                title(ylab)
                hold on
            end 
        end 
        disp(i_file + " done!")
    end
        saveas(gcf, figName)
        close
end


   





