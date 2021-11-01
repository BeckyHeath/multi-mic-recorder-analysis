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

% Load in Audio Files and Generate Power Spectrums
% Power Spectrums Saved in Data/Sweep_Data
dir_path = "Data\Lab_Localisation\Audio_Data_Edited\Files_standardised\";
files = dir(dir_path + "*.wav");
file_names =  { files.name };

%%%% ALREADY DONE - UNCOMMENT TO RE-DO 
%status = generate_spectra(file_names, dir_path);

% Seperate Into YES waterproof or NO waterproof groups 
dir_path = "Data\Sweep_Data\";
files_wp = dir(dir_path + "*_*_Y*.csv");
files_no_wp = dir(dir_path + "*_*_N*.csv");

files_wp_names =  { files_wp.name };
files_no_wp_names =  { files_no_wp.name };


% get means: 
[means_wp_names, frequency1] = get_means(dir_path,files_wp_names);
[means_no_wp_names, frequency2] = get_means(dir_path,files_no_wp_names);

%TODO: check frequencies match (they should do if generated in script)

% Subtract the Waterproofed Spectra from Un-waterproofed spectra 
dif = means_no_wp_names.means - means_wp_names.means;
dif = table(dif);
dif = cat(2,frequency1, dif);

% Plot difference (and smooth?) 
plot(dif.frequency, dif.dif,dif.frequency, means_wp_names.means,dif.frequency, means_no_wp_names.means)



% Define Functions Below: 


function status = generate_spectra(x,dir_path)

    for file_no = 1:size(x,2)
        in_file = x(file_no);
        test_file = dir_path + in_file; 
        samples = [1,25*16000];   % Change if Fs is not 16000
        [y_all,Fs] = audioread(test_file,samples);
    
        for ch_no = 1:size(y_all,2)
            y = y_all(:,ch_no);
            % Generate Power Spectrum TODO: Check that this is correct)
            n_fft = floor((length(y)/15));  
            psd_function = psd(spectrum.periodogram,y,'Fs',Fs,'NFFT',n_fft);
            frequencies = psd_function.Frequencies;
            psdata = psd_function.Data;

            out_data = cat(2,frequencies,psdata);

            % psd_function.plot % (uncomment this if you want to see the plots)

            % Export Spectrums as csv (first col freq, second col data) 
            out_file_name = "Data\Sweep_Data\" + in_file + "_ch="+ ch_no+ ".csv";
            out_file_name = erase(out_file_name, ".wav");

            csvwrite(out_file_name, out_data);
        end
    end
    status = "Job Done"; % placeholder for now
end 



function [ outMeans, outFrequencies ] = get_means(dir_path,file_list)
    % Define the df dimensions
    file_dim = size(readtable(dir_path + file_list(1)));
    num_vals = file_dim(1);

    all_vals = table.empty(num_vals,0);

    % Load in data and join all sprectral data together
    for i = 1:size(file_list,2)
        i_file = file_list(i);
        label = char(i_file);
        path = dir_path + i_file;
        data = readtable(path);
        %plt = plot(data.Var1, data.Var2);
        data.Properties.VariableNames{1} = 'frequency';
        data.Properties.VariableNames{2} = label;
        frequencies = data(:,1);
        spectra = data (:,2);
        all_vals = cat(2,all_vals,spectra);

        % Average the values per row
        all_vals_matrix = all_vals{:,:};
        means = mean(all_vals_matrix,2);
        means = table(means);
        means = cat(2,frequencies, means);   
    end
    outMeans = means; % Export the mean data
    outFrequencies = frequencies;
end 