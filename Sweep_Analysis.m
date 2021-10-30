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

status = generate_spectra(file_names, dir_path);

% Seperate Into YES waterproof or NO waterproof groups 
% + Average the spectrum accross groups 

% change path and indexing conditions
dir_path = "Data\Sweep_Data\";
files_wp = dir(dir_path + "*_*_Y*.wav");


% Subtract the Waterproofed Spectra from Un-waterproofed spectra 


% Plot difference (and smooth?) 



% Define Functions Below: 
function status = generate_spectra(x,dir_path)

    for file_no = 1:size(x,2)
        in_file = x(file_no);
        test_file = dir_path + in_file; 
        [y_all,Fs] = audioread(test_file);
    
        for ch_no = 1:size(y_all,2)
            y = y_all(:,ch_no);
            % Generate Power Spectrum TODO: Check that this is correct)
            n_fft = floor((length(y)/30));  
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

end 
