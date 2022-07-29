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
root = "Data/WavFieldRecordings/AdjGain/";

RecNames = ["yellow","yellowgreen", "green", "Blue"];
SubFolders = ["pre","early"];

% RecNames = ["yellow"];
% SubFolders = ["pre"];

% Play with these Order: Yellow, YellowGreen, Blue, Green
colours = ["F6BD60","86CB92","12664F","00A7E1"];
colours2 = ["EAC435","18FF6D", "5C9EAD", "415D43"];

% Note: The orders wierd but this is for graphing! 

tok=-6; % this is to organise subfigs

ha = tight_subplot(8,6,[.01 .01],[.04 .04],[.05 .01]); % Set up plot 

% Iterate first through recorder types! 
for k = 1:size(RecNames,2)
    recName = RecNames(k);
 
    % Then go through pre and early:
    for sub = 1:size(SubFolders,2)
        folder = SubFolders(sub);
        
        path = root + recName + "/" + folder + "/";

        Files = dir(path + "*.wav");
        FileNames =  { Files.name };

        tok = tok+6;

        % Then through individual Audio Files:
        for fileNo = 1:size(FileNames,2)
            i_file = path + FileNames(fileNo);
            
            %Load in Audio
            aud = audioread(i_file,[1,600*16000]); % Load in full file 
            
    
            % Subset audio just a minute at a time:
            for endSamp = 960000:9600000:9600000 %temp: just do it once
                startSamp = 1;
                samples = [startSamp,endSamp];
                
                TestSection = aud(startSamp:endSamp,:);
                startSamp = endSamp; % Swap over the start/end point for next loop
                
                % Iterate through channels
    
                j=0 + tok; % This will be the figure number!
    
                for ch = 1:6
    
                    j=j+1;
    
                    audCh = aud(:,ch);
                    [p,frequencies] = pspectrum(audCh,16000);
                    pdb = cat(2,frequencies,pow2db(p));
    
                    ylab = "ch " +  j;
                   
                    % Get Colour
                    col = "#"+ colours(k);
    
                    % Plot Spectrogram
                    %subplot(8,6,j);
                    axes(ha(j));
                    plot(pdb(:,1), pdb(:,2), 'color',col,'linewidth',0.5);

                    % Just Title Top Row
                    if j <= 6
                        title(ylab)
                    end
                    hold on
                end 
            end 
            disp(i_file + " done!")
        end 
    end
end

% Get rid of all labels except bottom left
set(ha(1:42),'XTickLabel',''); set(ha(1:42),'YTickLabel','')
set(ha(44:48),'XTickLabel',''); set(ha(44:48),'YTickLabel','')

% ha = tight_subplot(3,2,[.01 .03],[.1 .01],[.01 .01])
%           for ii = 1:6
%               axes(ha(ii)); 
%               plot(randn(10,ii)); 
%           end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

   





