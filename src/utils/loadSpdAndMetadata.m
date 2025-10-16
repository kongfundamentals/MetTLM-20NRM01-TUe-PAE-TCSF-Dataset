%% function loadSpdAndMetadata
%
% Description:
%   Parses a complex spectroradiometer CSV report that contains both
%   metadata (Luminance, Chromaticity) in the header and a main data block
%   (Spectral Power Distribution).
%
% Inputs:
%   - filePath: A string containing the full path to the CSV file.
%
% Outputs:
%   - data: A struct containing the parsed data with the following fields:
%       .drivingVoltage  (1xN double) - Driving Voltage (mV peak-to-peak)
%       .luminance       (1xN double) - Luminance values [cd/m^2]
%       .xCoords         (1xN double) - CIE 1931 x chromaticity coordinates
%       .yCoords         (1xN double) - CIE 1931 y chromaticity coordinates
%       .wavelengths     (Mx1 double) - Wavelengths [nm]
%       .spd             (MxN double) - Spectral Power Distribution data
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function data = loadSpdAndMetadata(filePath)

    % --- 1. Read the Metadata Block (first 7 rows) ---
    % We use readcell here because the data is non-uniform.
    % This block contains Luminance and Chromaticity.
    try
        % The 'Range' parameter is used to read only a specific section.
        metadataRange = '1:7';
        metadataBlock = readcell(filePath, 'Range', metadataRange);
    catch ME
        error('Failed to read the metadata block from the file. Check the file path and format. Original error: %s', ME.message);
    end

    % Extract the specific rows of interest from the cell array.
    % The '2:end' skips the first column which contains text headers.
    % The 'cell2mat' converts the cell array of numbers into a numeric matrix.
    data.drivingVoltage     = cell2mat(metadataBlock(2, 2:end));
    data.luminance          = cell2mat(metadataBlock(4, 2:end));
    data.xCoords            = cell2mat(metadataBlock(6, 2:end));
    data.yCoords            = cell2mat(metadataBlock(7, 2:end));


    % --- 2. Read the Main SPD Data Block ---
    % To read the main data table, we can use readtable, but we must
    % tell it to skip the metadata headers.
    try
        % detectImportOptions helps us programmatically set the rules.
        opts = detectImportOptions(filePath);
        
        % Rule 1: The variable names (headers) are on line 8.
        opts.VariableNamesLine = 8;
        
        % Rule 2: The actual numerical data starts on line 9.
        opts.DataLines = [9, Inf];
        
        % The 'preserve' rule tells readtable to use the original column
        % headers (e.g., "Measurement #1") exactly as they are, which
        % prevents MATLAB from trying to "fix" them and issuing a warning.
        opts.VariableNamingRule = 'preserve';

        % Now read the table with these specific options.
        spdTable = readtable(filePath, opts);

    catch ME
        error('Failed to read the SPD data block from the file. Check the file format. Original error: %s', ME.message);
    end

    % Extract the data from the resulting table.
    % The first column is the wavelength.
    data.wavelengths = spdTable{:, 1};
    
    % The remaining columns are the SPD measurements.
    data.spd = spdTable{:, 2:end};

end