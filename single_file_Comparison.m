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
audio_path = "Data/Lab_Localisation/Audio_Data_Edited/Files_Standardised/";
csvs_path = "Data/Sweep_Data/";

fn_1 = "1a_pinknoise2_N_2";
fn_2 = "7a_pinknoise_N_3";

% Load in Audio
samples = [1,25*16000];
aud1 = audioread(audio_path+fn_1+".wav",samples);
aud2 = audioread(audio_path+fn_1+".wav",samples);

% Load in csvs (power spectrum data - all channels) 
csvs1 = dir(csvs_path + fn_1 + "*.csv"); 
csvs2 = dir(csvs_path + fn_2 + "*.csv"); 

csvnames1 = {csvs1.name};
csvnames2 = {csvs2.name};


% Get mean specrum from each of the groups: 

% Waterproofed: 
[means1, frequency1] = get_means(csvs_path,csvnames1 );

% Not Waterproofed: 
[means2, frequency2] = get_means(csvs_path,csvnames2 );

% Find difference between waterpoofed and un-waterproofed spectra 
difference = means1.means - means2.means;
difference = table(difference);
dif = cat(2,frequency1, difference);

% Plot difference (and smooth?) 

% Get Smoothed Values: 
sm1 = smooth(means1.frequency, means1.means,0.3,'rloess');
sm2 = smooth(means2.frequency, means2.means,0.3,'rloess');
smDif = smooth(dif.frequency, dif.difference,0.3,'rloess');

% Seperate Plots: 
subplot(2,1,1);
plot(means1.frequency, sm1, 'color','#D95319','linewidth',1)
hold on 
patchline(means1.frequency, means1.means,'edgecolor',[0.8500, 0.3250, 0.0980],'linewidth',1,'edgealpha',0.3);
hold on
plot(means2.frequency, sm2,'color', '#EDB120', 'linewidth',1)
hold on 
patchline(means2.frequency, means2.means,'edgecolor',	[0.9290, 0.6940, 0.1250],'linewidth',1,'edgealpha',0.3);
hold on
title('Sweep Comparison: Start v. End')
ylabel('Power Spectrum (dB)')
legend('Start', 'End')
grid on

subplot(2,1,2); 
plot(dif.frequency, smDif)
hold on 
patchline(dif.frequency, dif.difference,'edgecolor',[0, 0.4470, 0.7410],'linewidth',1,'edgealpha',0.3);
title('Difference in Spectra')
xlabel('Frequency/Hz')
ylabel('Power Spectrum (dB)')
grid on


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