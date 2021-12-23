% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Consolidate the dead and anomolous 
% signal data
%
% Becky Heath
% Winter 2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set working directory 
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

colours = ["green","yellow","yellowgreen","Blue"];
colour = colours(4);

deadData = readtable("Data\" + colour + "DeadStrings.csv");
outlierData = readtable("Data\" + colour + "outlier.csv");

joined = join(deadData,outlierData, 'Keys','FileName');