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

for colNum = 1:size(colours,2)
    colour = colours(colNum);

    deadData = readtable("Data\" + colour + "DeadStrings.csv");
    outlierData = readtable("Data\" + colour + "outlier.csv");

    % Ignore Columns you don't need: 
    deadData = deadData(:,[1:2 9:10]);
    outlierData = outlierData(:,[1:2 9]);
    
    joined = join(deadData,outlierData);
    
    B = rowfun(@metaDesc,joined);
    
    out = [joined B]; 

    outFileName = 'Data/' + colour + "QualityData.csv";
    
    writetable(out,outFileName); 
end


