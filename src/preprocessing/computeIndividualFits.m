%% function computeIndividualFits
%
% Description:
%   This is the secondary analysis script. It loads the computed visibility
%   thresholds, fits a 3rd-order polynomial to each participant's data,
%   calculates the peak sensitivity and peak frequency, and saves all
%   results into a well-structured .mat file for easy plotting.
%
% Inputs:
%   - Reads: '../data/processedData/visibilityThresholds.csv'
%
% Outputs:
%   - Saves a 22x1 struct array of results to: 
%     '../data/processedData/individualFitResults.mat'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function computeIndividualFits
    % 0. SETUP PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(fileparts(projectRoot));
    addpath(fullfile(projectRoot, 'src', 'utils'));

    % 1. LOAD DATA
    % ===================================================================
    participantIdList = 1 : 22;
    frequencyList     = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    thresholdDataPath = fullfile(projectRoot, 'data', 'processedData', 'visibilityThresholds.csv');
    thresholdsTable = readtable(thresholdDataPath);
    visibilityThresholds = thresholdsTable{:, 2 : end}; % Exclude participantId column

    % 2. INITIALIZE A STRUCT ARRAY FOR THE RESULTS
    % ===================================================================
    % Pre-allocate a struct array. This is more efficient than growing it in a loop.
    results = struct();
    results.frequencyList = frequencyList;
    results.participantData(numel(participantIdList)) = struct('participantId', [], ...
                                               'fitObject', [], ...
                                               'peakSensitivity', [], ...
                                               'peakFrequency', []);

    % 3. PERFORM ANALYSIS FOR EACH PARTICIPANT
    % ===================================================================
    fprintf('Analyzing individual polynomial fits...\n');
    xData = log10(frequencyList);
    
    for participantId = 1:numel(participantIdList)
        logSensitivity = log10(1 ./ visibilityThresholds(participantId, :));
        
        fitObject = fit(xData', logSensitivity', 'poly3');
        
        fhandle = @(x) feval(fitObject, x);
        [xMaxLog, yMaxNegative] = fminbnd(@(x) -fhandle(x), log10(min(frequencyList)), log10(max(frequencyList)));
        
        % Store all results for this participant in a single struct element
        results.participantData(participantId).participantId = participantId;
        results.participantData(participantId).fitObject = fitObject;
        results.participantData(participantId).peakSensitivity = -yMaxNegative;
        results.participantData(participantId).peakFrequency = 10.^(xMaxLog);
    end

    % 4. SAVE RESULTS
    % ===================================================================
    outputFolder = fullfile(projectRoot, 'data', 'processedData');
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    outputFilePath = fullfile(outputFolder, 'individualFitResults.mat');
    
    % Save the entire 'results' struct array to the file.
    save(outputFilePath, 'results');
    fprintf('Analysis complete. All individual fit results saved to:\n%s\n', outputFilePath);
end