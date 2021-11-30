% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the spectra/ spectrograms of a 
% a given list of files
%
% Becky Heath
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Set up File Locations and Load in Relevant Data
audio_path = "Data/Lab_Localisation/Audio_Data_Edited/Files_clean3/";
csvs_path = "Data/Sweep_Data/";

desc1 = "1a pinknoise N 2";
desc2 = "1b bird N 2";
desc3 = "7a pinknoise N 3";
desc4 = "5a pinknoise Y 2";
desc5 = "5b bird Y 2";
desc6 = "3a pinknoise Y 3";


fn_1 = "1a_pinknoise2_N_2";
fn_2 = "1b_bird_N_2";
fn_3 = "7a_pinknoise_N_3";
fn_4 = "5a_pinknoise_Y_2";
fn_5 = "5b_bird_Y_2";
fn_6 = "3a_pinknoise_Y_3";



% Load in Audio
samples = [1,9*16000]; % Sweeps are just the first 9 seconds
aud1 = audioread(audio_path+fn_1+".wav",samples);
aud2 = audioread(audio_path+fn_2+".wav",samples);
aud3 = audioread(audio_path+fn_3+".wav",samples);
aud4 = audioread(audio_path+fn_4+".wav",samples);
aud5 = audioread(audio_path+fn_5+".wav",samples);
aud6 = audioread(audio_path+fn_6+".wav",samples);

% Load in csvs (power spectrum data - all channels) 
csvs1 = dir(csvs_path + fn_1 + "*.csv"); 
csvs2 = dir(csvs_path + fn_2 + "*.csv"); 
csvs3 = dir(csvs_path + fn_3 + "*.csv"); 
csvs4 = dir(csvs_path + fn_4 + "*.csv"); 
csvs5 = dir(csvs_path + fn_5 + "*.csv"); 
csvs6 = dir(csvs_path + fn_6 + "*.csv"); 
csvnames1 = {csvs1.name};
csvnames2 = {csvs2.name};
csvnames3 = {csvs3.name};
csvnames4 = {csvs4.name};
csvnames5 = {csvs5.name};
csvnames6 = {csvs6.name};


%% FIND THE DIFFERENCE DATA AND PLOT 
% Get mean specrum from each of the groups: 
% Group 1: 
[means1, frequency1] = get_means(csvs_path,csvnames1 );

% Group 2: 
[means2, frequency2] = get_means(csvs_path,csvnames2 );

% Group 1: 
[means3, frequency3] = get_means(csvs_path,csvnames3 );

% Group 2: 
[means4, frequency4] = get_means(csvs_path,csvnames4 );

% Group 1: 
[means5, frequency5] = get_means(csvs_path,csvnames5 );

% Group 2: 
[means6, frequency6] = get_means(csvs_path,csvnames6 );


% Plot Values (and smooth?) 

% Get Smoothed Values: 
sm1 = smooth(means1.frequency, means1.means,0.3,'rloess');
sm2 = smooth(means2.frequency, means2.means,0.3,'rloess');
sm3 = smooth(means3.frequency, means3.means,0.3,'rloess');
sm4 = smooth(means4.frequency, means4.means,0.3,'rloess');
sm5 = smooth(means5.frequency, means5.means,0.3,'rloess');
sm6 = smooth(means6.frequency, means6.means,0.3,'rloess');

% Seperate Plots: 
subplot(6,3,[1,2]);
plot(means1.frequency, sm1, 'color','#D95319','linewidth',1)
hold on 
patchline(means1.frequency, means1.means,'edgecolor',[0.8500, 0.3250, 0.0980],'linewidth',1,'edgealpha',0.3);
hold on
title(desc1)
ylabel('Power Spectrum (dB)')
grid on

subplot(6,3,[4,5]);
plot(means2.frequency, sm2, 'color','#D95319','linewidth',1)
hold on 
patchline(means2.frequency, means2.means,'edgecolor',[0.8500, 0.3250, 0.0980],'linewidth',1,'edgealpha',0.3);
hold on
title(desc2)
ylabel('Power Spectrum (dB)')
grid on

subplot(6,3,[7,8]);
plot(means3.frequency, sm3, 'color','#D95319','linewidth',1)
hold on 
patchline(means3.frequency, means3.means,'edgecolor',[0.8500, 0.3250, 0.0980],'linewidth',1,'edgealpha',0.3);
hold on
title(desc3)
ylabel('Power Spectrum (dB)')
grid on

subplot(6,3,[10,11]);
plot(means4.frequency, sm4, 'color','#D95319','linewidth',1)
hold on 
patchline(means4.frequency, means4.means,'edgecolor',[0.8500, 0.3250, 0.0980],'linewidth',1,'edgealpha',0.3);
hold on
title(desc4)
ylabel('Power Spectrum (dB)')
grid on

subplot(6,3,[13,14]);
plot(means5.frequency, sm5, 'color','#D95319','linewidth',1)
hold on 
patchline(means5.frequency, means5.means,'edgecolor',[0.8500, 0.3250, 0.0980],'linewidth',1,'edgealpha',0.3);
hold on
title(desc5)
ylabel('Power Spectrum (dB)')
grid on

subplot(6,3,[16,17]);
plot(means6.frequency, sm6, 'color','#D95319','linewidth',1)
hold on 
patchline(means6.frequency, means6.means,'edgecolor',[0.8500, 0.3250, 0.0980],'linewidth',1,'edgealpha',0.3);
hold on
title(desc6)
ylabel('Power Spectrum (dB)')
grid on

%% PLOT SPECTROGRAMS

% Split Channels (get just one):
a1 = aud1(:,2);
a2 = aud2(:,2);
a3 = aud3(:,2);
a4 = aud4(:,2);
a5 = aud5(:,2);
a6 = aud6(:,2);


% Generate Spectrogram
subplot(6,3,3);
spectrogram(a1,1280,1200,1280,16000,'yaxis')
title(desc1)

subplot(6,3,6);
spectrogram(a2,1280,1200,1280,16000,'yaxis')
title(desc2)

subplot(6,3,9);
spectrogram(a3,1280,1200,1280,16000,'yaxis')
title(desc3)

subplot(6,3,12);
spectrogram(a4,1280,1200,1280,16000,'yaxis')
title(desc4)

subplot(6,3,15);
spectrogram(a5,1280,1200,1280,16000,'yaxis')
title(desc5)

subplot(6,3,18);
spectrogram(a6,1280,1200,1280,16000,'yaxis')
title(desc6)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function status = generate_spectra(x,audio_dir_path,sweep_dir_path)
% Function which takes an input of a list of .wav audiofiles to analyse. 
% The % function loads each file individually and splits it into individual 
% channels. Spectral data is then generated from each channel and out-
% putted to an individual csv. 
%
% ARGS: x        = list of files to analyse
%       sweep_dir_path = path to file list
%       audio_dir_path = path to save files in
%
% OUTPUT(s): status = placeholder 
%            + a repo of csvs containing indicidual channel spectral data
%    
    % Iterate through the list of files
    for file_no = 1:size(x,2)
        in_file = x(file_no);
        test_file = audio_dir_path + in_file; 

        % Determine the number of samples
        % The sweeps all fall within the first 25 secoonds! 
        samples = [1,25*16000];   % Change if Fs is not 16000
                                  % Change if recording is not 25s

        % load file
        [y_all,Fs] = audioread(test_file,samples);
        
        % Split and iterate through channels
        for ch_no = 1:size(y_all,2)
            y = y_all(:,ch_no);

            [psdata,frequencies] = pspectrum(y,Fs);

            out_data = cat(2,frequencies,pow2db(psdata));

            % Export Spectrums as csv (first col freq, second col data) 
            out_file_name = sweep_dir_path + in_file + "_ch="+ ch_no+ ".csv";
            out_file_name = erase(out_file_name, ".wav");

            csvwrite(out_file_name, out_data);
        end
    end
    status = "Job Done"; % placeholder for now (??)
end 



function [ outMeans, outFrequencies ] = get_means(sweep_dir_path,file_list)
% Function which takes an input of a list spectral data csvs to analyse. 
% The function takes all of the spectral data from the file lest and 
% finds the mean average of the spectral data in this group. This mean
% spectral data, along with the corresponding frequencies is then out-put
%
%
% ARGS:   dir_path       = path to csv files
%         file_list      = list of csv files
%
% OUTPUT: outMeans       = a table containing frequency/ mean spectral data 
%         outFrequencies = a table containing the frequency data alone
%  

    % Define the df dimensions
    file_dim = size(readtable(sweep_dir_path + file_list(1)));
    num_vals = file_dim(1);
    
    % Initialise all values table
    all_vals = table.empty(num_vals,0);

    % Load in data and join all sprectral data together
    for i = 1:size(file_list,2)
        i_file = file_list(i);
        label = char(i_file);
        path = sweep_dir_path + i_file;
        data = readtable(path);
        %plt = plot(data.Var1, data.Var2);

        % Rename variables to collate the data
        data.Properties.VariableNames{1} = 'frequency';
        data.Properties.VariableNames{2} = label;
        frequencies = data(:,1);
        spectra = data (:,2);

        % Bind new data to all values table 
        all_vals = cat(2,all_vals,spectra);

        % Average the values per row
        all_vals_matrix = all_vals{:,:};
        means = mean(all_vals_matrix,2);
        means = table(means);
        means = cat(2,frequencies, means);   
    end
    % Define the output variables
    outMeans = means; % Export the mean data
    outFrequencies = frequencies;
end 