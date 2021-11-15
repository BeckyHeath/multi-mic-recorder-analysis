% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for comparing power Spectrograms from 
% two different types of .wav recordings (multichanel)
%
% Becky Heath
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Set Path and Files to be Loaded 
audio_dir_path = "Data\Lab_Localisation\Audio_Data_Edited\standardised_subset\";

no_wp_path = audio_dir_path + "1a_pinknoise_N_2.wav";
wp_path = audio_dir_path + "3a_pinknoise_Y_3.wav";

% Set Sample Size + Load Files 
samples = [13.5*16000,21*16000]; % Sweeps all occur within first 25 seconds

[no_wp_all,Fs] = audioread(no_wp_path,samples);
[wp_all,Fs] = audioread(wp_path,samples);

% Split Channels:
wp = wp_all(:,2);
no_wp = no_wp_all(:,2);


% Generate Spectrogram
subplot(2,2,2);
spectrogram(no_wp,1280,1200,1280,Fs,'yaxis')
title('No Waterproofing')

subplot(2,2,4);
spectrogram(wp,1280,1200,1280,Fs,'yaxis')
title('with Waterproofing')





