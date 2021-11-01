% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scripts for comparing power spectrums from 
% two different types of .wav recordings (multichanel)
%
% Becky Heath 
% Autumn 2021 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% get a file list for the audio to be analysed: 
dir_path = "Data\Lab_Localisation\Audio_Data_Edited\Files_standardised\";
files = dir(dir_path + "*.wav");
file_names =  { files.name };

% generate spectra from the Audio List:
%%%% ALREADY DONE - UNCOMMENT TO RE-DO 
%status = generate_spectra(file_names, dir_path);

% Seperate spectral csvs into waterproofed vs unwaterproofed 
dir_path = "Data\Sweep_Data\";
files_wp = dir(dir_path + "*_*_Y*.csv"); % y = YES waterproof
files_no_wp = dir(dir_path + "*_*_N*.csv"); % n = NO waterproof

files_wp_names =  { files_wp.name };
files_no_wp_names =  { files_no_wp.name };


% Get mean specrum from each of the groups: 

% Waterproofed: 
[means_wp_names, frequency1] = get_means(dir_path,files_wp_names);

% Not Waterproofed: 
[means_no_wp_names, frequency2] = get_means(dir_path,files_no_wp_names);

%TODO (??): check frequencies match (they will if generated in script)

% Find difference between waterpoofed and un-waterproofed spectra 
dif = means_no_wp_names.means - means_wp_names.means;
dif = table(dif);
dif = cat(2,frequency1, dif);

% Plot difference (and smooth?) 
figure
plot(dif.frequency, dif.dif,dif.frequency, means_wp_names.means,dif.frequency, means_no_wp_names.means)
title('Sweep Comparison')
xlabel('Frequency/Hz')
ylabel('Amplitude')
legend('No Waterproofing','With Waterproofing', 'Difference')
ylim([0,4.5e-7])



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function status = generate_spectra(x,dir_path)
% Function which takes an input of a list of .wav audiofiles to analyse. 
% The % function loads each file individually and splits it into individual 
% channels. Spectral data is then generated from each channel and out-
% putted to an individual csv. 
%
% ARGS: x        = list of files to analyse
%       dir_path = path to file list
%
% OUTPUT(s): status = placeholder 
%            + a repo of csvs containing indicidual channel spectral data
%    
    % Iterate through the list of files
    for file_no = 1:size(x,2)
        in_file = x(file_no);
        test_file = dir_path + in_file; 

        % Determine the number of samples (??)
        samples = [1,25*16000];   % Change if Fs is not 16000

        % load file
        [y_all,Fs] = audioread(test_file,samples);
        
        % Split and iterate through channels
        for ch_no = 1:size(y_all,2)
            y = y_all(:,ch_no);
            % Generate Power Spectrum TODO: Check that this is correct)

            % Determine the number of bands to analyse
            n_fft = floor((length(y)/15));  

            % Generate Spectra and output daya
            psd_function = psd(spectrum.periodogram,y,'Fs',Fs,'NFFT',n_fft);
            frequencies = psd_function.Frequencies;
            psdata = psd_function.Data;

            out_data = cat(2,frequencies,psdata);

            % Export Spectrums as csv (first col freq, second col data) 
            out_file_name = "Data\Sweep_Data\" + in_file + "_ch="+ ch_no+ ".csv";
            out_file_name = erase(out_file_name, ".wav");

            csvwrite(out_file_name, out_data);
        end
    end
    status = "Job Done"; % placeholder for now (??)
end 



function [ outMeans, outFrequencies ] = get_means(dir_path,file_list)
% Function which takes an input of a list spectral data csvs to analyse. 
% The function takes all of the spectral data from the file lest and 
% finds the mean average of the spectral data in this group. This spectral 
% data, along with the corresponding frequencies is then out-put
%
%
% ARGS:   dir_path       = path to csv files
%         file_list      = list of csv files
%
% OUTPUT: outMeans       = a table containing frequency/ mean spectral data 
%         outFrequencies = a table containing the frequency data alone
%  

    % Define the df dimensions
    file_dim = size(readtable(dir_path + file_list(1)));
    num_vals = file_dim(1);
    
    % Initialise all values table
    all_vals = table.empty(num_vals,0);

    % Load in data and join all sprectral data together
    for i = 1:size(file_list,2)
        i_file = file_list(i);
        label = char(i_file);
        path = dir_path + i_file;
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