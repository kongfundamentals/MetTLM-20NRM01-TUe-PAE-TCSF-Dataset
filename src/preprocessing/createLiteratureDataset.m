%% function createLiteratureDataset
%
% Description:
%   This is a core processing script that loads, processes, and analyzes
%   all datasets for the literature review meta-analysis (Figure 10a/b). It reads
%   the results of the current study, loads all curated external datasets
%   from CSV/XLS files, harmonizes the units (i.e., some modulation depths 
%   are expressed in percentages while others are expressed in decimals), 
%   performs polynomial fits where appropriate, and saves all results into 
%   a single, clean .mat file.
%
% Inputs:
%   - Reads this study's results from: '../data/processedData/visibilityThresholds.csv'
%   - Reads all literature data from:  '../data/externalData/'
%
% Outputs:
%   - Saves a struct of all processed data and fits to:
%     '../data/processedData/literatureAnalysisResults.mat'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%
function createLiteratureDataset
    % 0. SETUP PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(fileparts(projectRoot)); % Go up two levels
    addpath(fullfile(projectRoot, 'src', 'utils'));

    % 1. INITIALIZE RESULTS STRUCT
    % ===================================================================
    litData = struct();

    % 2. PROCESS THIS STUDY'S DATA
    % ===================================================================
    fprintf('Processing current study data...\n');
    thresholdDataPath = fullfile(projectRoot, 'data', 'processedData', 'visibilityThresholds.csv');
    thresholdsTable = readtable(thresholdDataPath);
    visibilityThresholds = thresholdsTable{:, 2 : end}; % Exclude participantId column
    
    frequencyList = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    xData = log10(frequencyList);
    logSensitivity = log10(1 ./ visibilityThresholds);
    meanLogSensitivity = mean(logSensitivity, 1, 'omitnan');
    
    % Perform fit
    [fitObject, gof] = fit(xData', meanLogSensitivity', 'poly3');
    %xFit = linspace(min(xData), max(xData), 100)';
    % To ensure it extrapolates to the axis crossing
    % manually change it to log10(2000).
    xFit = linspace(min(xData), log10(2000), 100)';
    yFit = feval(fitObject, xFit);

    % Store in struct
    litData.currentUserStudy.xData = xData;
    litData.currentUserStudy.yData = meanLogSensitivity;
    litData.currentUserStudy.xFit = xFit;
    litData.currentUserStudy.yFit = yFit;
    litData.currentUserStudy.rSquared = gof.rsquare;
    litData.currentUserStudy.citationKey = 'Current Study';

    % 3. PROCESS EXTERNAL DATA FROM /data/externalData/
    % ===================================================================
    externalDataFolder = fullfile(projectRoot, 'data', 'externalData');
    allExternalFiles = dir(fullfile(externalDataFolder, '*.csv'));
    
    fprintf('Processing %d external CSV datasets...\n', numel(allExternalFiles));
    
    for i = 1:numel(allExternalFiles)
        fileName = allExternalFiles(i).name;
        filePath = fullfile(externalDataFolder, fileName);
        
        % Use the filename (without extension) as the struct field name
        [~, structName, ~] = fileparts(fileName);
        fprintf('--> Processing: %s\n', fileName);
        
        dataTable = readtable(filePath);
        
        % --- Data Harmonization ---
        % Convert modulation depth from percentage (0-100) to decimal (0-1)
        % and then to log sensitivity.
        modDepthCols = contains(dataTable.Properties.VariableNames, '_M');
        dataTable{:, modDepthCols} = dataTable{:, modDepthCols} / 100;
        
        xData = log10(dataTable.frequency_Hz);
        yData = log10(1 ./ dataTable.modulationDepth_M);
        
        litData.(structName).xData = xData;
        litData.(structName).yData = yData;
        
        % --- Perform Fits (where appropriate) ---
        % Only fit datasets with enough points for a 3rd-order polynomial
        if strcmp(structName, 'yu2018_sin') || strcmp(structName, 'yu2018_square')
            [fitObject, gof] = fit(xData, yData, 'poly3');
            xFit = linspace(min(xData), max(xData), 100)';
            yFit = feval(fitObject, xFit);
            
            litData.(structName).xFit = xFit;
            litData.(structName).yFit = yFit;
            litData.(structName).rSquared = gof.rsquare;
        end
        
        % --- Handle Special Cases for Pre-fitted Data ---
        if strcmp(structName, 'cie2022_from_tan2024')
             [fitObject, gof] = fit(xData, yData, 'poly3');
             xFit = linspace(log10(80), log10(5000), 100)';
             yFit = feval(fitObject, xFit);
             litData.(structName).xFit = xFit;
             litData.(structName).yFit = yFit;
             litData.(structName).rSquared = gof.rsquare;
        end

        if strcmp(structName, 'tan2024')
             [fitObject, gof] = fit(xData, yData, 'poly2'); % This one was a 2nd order fit
             xFit = linspace(log10(80), log10(5000), 100)';
             yFit = feval(fitObject, xFit);
             litData.(structName).xFit = xFit;
             litData.(structName).yFit = yFit;
             litData.(structName).rSquared = gof.rsquare;
        end
    end
    
    % --- Handle the special Kong2023 XLS file ---
    fprintf('--> Processing: kong2023_fullDataset.xls\n');
    filePathXLS = fullfile(projectRoot, 'data', 'externalData', 'kong2023_fullDataset.xls');
    % Using readtable for robust import of Excel files.
    opts = detectImportOptions(filePathXLS);
    opts.DataRange = 'A2:R21'; % The first row is empty
    dataTableXLS = readtable(filePathXLS, opts);  
    % Now, convert the imported table to a numeric matrix for processing.
    kong2023DataMatrix = table2array(dataTableXLS);

    % Define the structure of the Kong et al. (2023) data
    colorsToProcess   = {'red', 'green', 'warmWhite'};
    frequencies       = [80, 300, 600, 900, 1200, 1800];
    xData             = log10(frequencies);
    
    for c = 1:length(colorsToProcess)
        color = colorsToProcess{c};
        structName = ['kong2023_', color];
        
        % Select the correct 6 columns for the current color
        colStart = (c - 1) * 6 + 1;
        colEnd   = c * 6;
        colorData = kong2023DataMatrix(:, colStart:colEnd);
        
        % Calculate the mean log sensitivity for this color, ignoring NaNs
        logSensitivity = log10(1 ./ colorData);
        meanLogSensitivity = mean(logSensitivity, 1, 'omitnan');
        
        % Perform the 3rd-order polynomial fit
        [fitObject, gof] = fit(xData', meanLogSensitivity', 'poly3');
        xFit = linspace(min(xData), max(xData), 100)';
        yFit = feval(fitObject, xFit);

        % Store all the results in our main struct
        litData.(structName).xData = xData;
        litData.(structName).yData = meanLogSensitivity;
        litData.(structName).xFit = xFit;
        litData.(structName).yFit = yFit;
        litData.(structName).rSquared = gof.rsquare;
        litData.(structName).citationKey = 'Kong et al. (2023)';
    end
    

    % 4. SAVE COMBINED DATA
    % ===================================================================
    outputFolder = fullfile(projectRoot, 'data', 'processedData');
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    outputFilePath = fullfile(outputFolder, 'literatureAnalysisResults.mat');
    
    save(outputFilePath, 'litData');
    fprintf('\nAnalysis complete. All literature data saved to:\n%s\n', outputFilePath);
end