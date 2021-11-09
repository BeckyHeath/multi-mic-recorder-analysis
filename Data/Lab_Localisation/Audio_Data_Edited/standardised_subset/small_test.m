% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for comparing power spectrums from 
% two different types of .wav recordings (multichanel)
% SIMPLIFIED
%
% Becky Heath + Lorenzo Picinali
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Load Files 
x = audioread("no_waterproofing.wav");
y = audioread("quiet_with_waterproofing.wav");

pspectrum(x,16000);
hold on 
pspectrum(y,16000);

xSpect=pspectrum(x,16000);
ySpect=pspectrum(y,16000);

%diff = xSpect - ySpect;
%plot(diff)