% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for comparing power spectrums from 
% two different types of .wav recordings (multichanel)
%
% Becky Heath with contributions from Dr. Lorenzo Picinali
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% get a file list for the audio to be analysed: 
% You may need to generate these files form the raw ones first
audio_dir_path = "Data\Field_Recordings_wav\";

desc1 = "Yellow Pre 1";
desc2 = "Yellow Late 1";
fn_1 = "yellow_pre_01";
fn_2 = "yellow_late_01";

% Load in Audio
samples = [1,60*16000]; % Just look at the first minute
aud1 = audioread(audio_dir_path+fn_1+".wav",samples);
aud2 = audioread(audio_dir_path+fn_2+".wav",samples);

% Get Power Spectra in dB
[p1,frequencies] = pspectrum(aud1,16000);
pdb1 = cat(2,frequencies,pow2db(p1));

[p2,frequencies] = pspectrum(aud2,16000);
pdb2 = cat(2,frequencies,pow2db(p2));


% Seperate Data: 

ch1a = pdb1(:,2);
ch1b = pdb1(:,3);
ch1c = pdb1(:,4);
ch1d = pdb1(:,5);
ch1e = pdb1(:,6);
ch1f = pdb1(:,7);

ch2a = pdb2(:,2);
ch2b = pdb2(:,3);
ch2c = pdb2(:,4);
ch2d = pdb2(:,5);
ch2e = pdb2(:,6);
ch2f = pdb2(:,7);



% Seperate Plots: 
subplot(6,4,[1,2]);
plot(frequencies, ch1a, 'color','#D95319','linewidth',1)
hold on
plot(frequencies, ch2a,'color', '#EDB120', 'linewidth',1)
hold on 
ylabel('Channel 1')
legend(desc1, desc2)
legend('Location', 'southwest')
grid on

subplot(6,4,[5,6]);
plot(frequencies, ch1b, 'color','#D95319','linewidth',1)
hold on
plot(frequencies, ch2b,'color', '#EDB120', 'linewidth',1)
hold on 
ylabel('Channel 2')
grid on

subplot(6,4,[9,10]);
plot(frequencies, ch1c, 'color','#D95319','linewidth',1)
hold on
plot(frequencies, ch2c,'color', '#EDB120', 'linewidth',1)
hold on 
ylabel('Channel 3')
grid on

subplot(6,4,[13,14]);
plot(frequencies, ch1d, 'color','#D95319','linewidth',1)
hold on
plot(frequencies, ch2d,'color', '#EDB120', 'linewidth',1)
hold on 
ylabel('Channel 4')
grid on

subplot(6,4,[17,18]);
plot(frequencies, ch1e, 'color','#D95319','linewidth',1)
hold on
plot(frequencies, ch2e,'color', '#EDB120', 'linewidth',1)
hold on 
ylabel('Channel 5')
grid on

subplot(6,4,[21,22]);
plot(frequencies, ch1f, 'color','#D95319','linewidth',1)
hold on
plot(frequencies, ch2f,'color', '#EDB120', 'linewidth',1)
hold on 
ylabel('Channel 6')
grid on

% Plot SPectra
% Split Channels:

aud1a = aud1(:,1);
aud1b = aud1(:,2);
aud1c = aud1(:,3);
aud1d = aud1(:,4);
aud1e = aud1(:,5);
aud1f = aud1(:,6);

aud2a = aud2(:,1);
aud2b = aud2(:,2);
aud2c = aud2(:,3);
aud2d = aud2(:,4);
aud2e = aud2(:,5);
aud2f = aud2(:,6);



% Generate Spectrogram for aud 1
subplot(6,4,3);
spectrogram(aud1a,1280,1200,1280,16000,'yaxis')
title(desc1)
caxis([-150 -50])

subplot(6,4,7);
spectrogram(aud1b,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,11);
spectrogram(aud1c,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,15);
spectrogram(aud1d,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,19);
spectrogram(aud1e,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,23);
spectrogram(aud1f,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])


% Generate Spectrogram for aud 2
subplot(6,4,4);
spectrogram(aud2a,1280,1200,1280,16000,'yaxis')
title(desc2)
caxis([-150 -50])

subplot(6,4,8);
spectrogram(aud2b,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,12);
spectrogram(aud2c,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,16);
spectrogram(aud2d,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,20);
spectrogram(aud2e,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])

subplot(6,4,24);
spectrogram(aud2f,1280,1200,1280,16000,'yaxis')
caxis([-150 -50])


