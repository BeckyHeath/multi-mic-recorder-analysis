% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare and Plot the difference between
% Two *given* Spectra - not for batch
%
% Becky Heath with contributions from Dr. Lorenzo Picinali
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Set up File Locations and Load in Relevant Data
audio_path = "Data/Lab_Localisation/Audio_Data_Edited/Files_clean3/";

desc1 = "Rec2";
desc2 = "Rec3";
fn_1 = "5a_pinknoise_Y_2";
fn_2 = "3a_pinknoise_Y_3";

% Load in Audio
samples = [1,1440000]; % whole signal
aud1 = audioread(audio_path+fn_1+".wav",samples);
aud2 = audioread(audio_path+fn_2+".wav",samples);


%PLOT SPECTROGRAMS
% Generate Spectrogram
subplot(2,2,[1,2]);
spectrogram(aud1,1300,1200,1300,48000,'yaxis')
title(desc1)
caxis([-110 -30])

subplot(2,2,[3,4]);
spectrogram(aud2,1280,1200,1280,48000,'yaxis')
title(desc2)
caxis([-110 -30])

