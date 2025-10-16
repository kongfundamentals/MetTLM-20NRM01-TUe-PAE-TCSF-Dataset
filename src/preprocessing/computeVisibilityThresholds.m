%% function computeVisibilityThresholds
%
% Description:
%   This is the core data analysis script for the project. It loads the
%   curated raw data for all the 22 participants, runs the mQUESTPlus 
%   psychometric function fitting for all 10 temporal frequencies, and 
%   saves the extracted visibility thresholds into a single, clean summary 
%   CSV file.
%
% Inputs:
%   - Reads all curated data from: '../data/rawData/participantXX.mat'
%
% Outputs:
%   - Saves a 22-by-10 matrix of visibility thresholds (expressed in 
%     modulation depth) to:
%     '../data/processedData/visibilityThresholds.csv'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function computeVisibilityThresholds
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(fileparts(projectRoot)); % Go up two levels
    addpath(fullfile(projectRoot, 'src', 'utils'));
    addpath(genpath(fullfile(projectRoot, 'external', 'mQUESTPlus')));

    % 1. SETUP PARAMETERS
    % ===================================================================
    participantIdList = 1 : 22;
    frequencyList    = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    
    % Initialize a matrix to store the threshold results.
    % Rows correspond to participants, columns to frequencies.
    visibilityThresholds = NaN(numel(participantIdList), numel(frequencyList));
   
    % 2. LOOP THROUGH PARTICIPANTS AND FREQUENCIES TO ANALYZE DATA
    % ===================================================================
    fprintf('Starting visibility threshold analysis...\n');
    
    % The outer loop is now participants, which is slightly more intuitive.
    for participantId = 1: numel(participantIdList)
        
        participantFile = sprintf('participant%02d.mat', participantId);
        filePath = fullfile(projectRoot, 'data', 'rawData', participantFile);
        
        if ~exist(filePath, 'file')
            warning('File for participant %02d not found. Skipping.', participantId);
            continue;
        end
        data = load(filePath);
        
        fprintf('Processing Participant %02d...\n', participantId);

        for frequencyIndex = 1 : numel(frequencyList)
            questVarName = sprintf('questDataFrequency%d', frequencyIndex);
            
            % Check if the required questData field exists in the file
            if ~isfield(data, questVarName)
                warning('Quest data for frequency index %d not found for participant %d. Skipping.', frequencyIndex, participantId);
                continue;
            end
            questData = data.(questVarName);
             
            SLOPE = 3; GUESSRATE = 0.5; LAPSE = 0.02;
            
            psiParamsIndex = qpListMaxArg(questData.posterior);
            psiParamsQuest = questData.psiParamsDomain(psiParamsIndex, :);
            
            psiParamsFit = qpFit(questData.trialData, questData.qpPF, psiParamsQuest, questData.nOutcomes,...
                'lowerBounds',  [linear2Log(data.modulationDepthInPercentageMIN) SLOPE   GUESSRATE LAPSE],...
                'upperBounds',  [linear2Log(data.modulationDepthInPercentageMAX) SLOPE   GUESSRATE LAPSE]);
            
            % Store only the threshold (the first fitted parameter)
            visibilityThresholds(participantId, frequencyIndex) = log2Linear(psiParamsFit(1));
        end
    end
    
    % 3. SAVE THE CLEAN RESULTS TO A .CSV FILE
    % ===================================================================
    outputFolder = fullfile(projectRoot, 'data', 'processedData');
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    
    % Define the output filename
    outputFileName = 'visibilityThresholds.csv';
    outputFilePath = fullfile(outputFolder, outputFileName);
    
    % Create descriptive column headers for the frequency data.
    % This programmatically creates names like 'frequency80Hz', 'frequency160Hz', etc.
    columnHeaders = cell(1, numel(frequencyList));
    for i = 1 : numel(frequencyList)
        columnHeaders{i} = sprintf('frequency%dHz', frequencyList(i));
    end

    % Convert the numeric matrix into a MATLAB table.
    T = array2table(visibilityThresholds, 'VariableNames', columnHeaders);
    
    % Create a participant ID column.
    participantIdColumn = (1 : numel(participantIdList))';

    % Add the participant ID column to the beginning of the table.
    T = addvars(T, participantIdColumn, 'Before', 1, 'NewVariableNames', 'participantId');
    
    % Use writetable to save the file, which includes the headers by default.
    writetable(T, outputFilePath);
    
    fprintf('\nAnalysis complete. Results saved to:\n%s\n', outputFilePath);
end