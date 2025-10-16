%% function plotFigure5
%
% Description:
%   Generates and saves Figure 5 from the associated publication. This script
%   loads curated participant data, fits a psychometric function for each
%   participant at 10 different temporal frequencies using the mQUESTPlus
%   toolbox, and plots the results in a 2x5 grid of subplots.
%
% Inputs:
%   - Reads curated data from: '../data/rawData/participantXX.mat'
%   - participantIdList (optional): A vector of participant IDs to plot.
%     If not provided, defaults to all 22 participants.
%     Example: plotFigure5([7])     
%     Example: plotFigure5([3, 5, 10])
%     Example: plotFigure5([setdiff(1:22, 9)])
%
% Outputs:
%   - Saves a multi-panel figure in both .emf and .png format.
%     The filename is dynamic based on input.
%     Default: '../output/fig5_allParticipants.emf'
%     Custom:  '../output/fig5_customParticipant5.emf' or similar.
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure5(participantIdList)
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));
    addpath(genpath(fullfile(projectRoot, 'external', 'mQUESTPlus')));

    % 1. SETUP PUBLICATION AND EXPERIMENTAL PARAMETERS
    % ===================================================================
    % --- Figure Style Parameters ---
    figureType        = 'twoColumn';
    finalWidthInches  = 3.5 * 5;
    finalHeightInches = 3.5 * 2;
    outputFileName    = 'fig5';
    fontName          = 'Arial';
    axisLabelFontSize = 14;
    axisTickFontSize  = 10;
    lineWidth         = 1;
    markerSize        = 30;

    % --- Data and Experimental Parameters ---
    % The 'nargin' variable is built-in and counts the number of inputs.
    if nargin < 1
        % DEFAULT MODE: Use all participants.
        participantIdList = 1 : 22;
        % For the default run, the suffix is the same as the figure type.
        fileNameSuffix = 'allParticipants';
    else
        % CUSTOM MODE: A specific list was provided.
        if numel(participantIdList) == 1
            % Create a specific suffix for a single participant.
            fileNameSuffix = sprintf('participant_%02d', participantIdList(1));
        else
            % Create a generic suffix for a custom group.
            fileNameSuffix = 'customSubset';
        end
    end
    
    fprintf('Plotting the psychometric functions for the following %d participants:\n', numel(participantIdList));
    for participantIndex = 1: numel(participantIdList)
        participantId = participantIdList(participantIndex);
        fprintf('Participant %02d\n', participantId);
    end
    frequencyList    = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    
    % 2. CREATE THE FIGURE
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    tiledLayoutHandle = tiledlayout(2, 5, 'TileSpacing', 'compact', 'Padding', 'compact');


    % 3. LOOP THROUGH FREQUENCIES, LOAD DATA, AND PLOT
    % ======================================================
    for frequencyIndex = 1 : 10
        ax = nexttile;
        hold(ax, 'on');

        for participantIndex = 1: numel(participantIdList)
            participantId = participantIdList(participantIndex);
            % --- Load Data ---
            participantFile = sprintf('participant%02d.mat', participantId);
            filePath = fullfile(projectRoot, 'data', 'rawData', participantFile);
            if ~exist(filePath, 'file'), continue; end
            data = load(filePath);

            % --- Select Correct questData ---
            questVarName = sprintf('questDataFrequency%d', frequencyIndex);
            questData = data.(questVarName);
            
            stimFine = linspace(linear2Log(data.modulationDepthInPercentageMIN), linear2Log(data.modulationDepthInPercentageMAX), 100)';
            
            nTrials = []; pCorrect = [];
            
            SLOPE = 3; GUESSRATE = 0.5; LAPSE = 0.02;
            
            psiParamsIndex = qpListMaxArg(questData.posterior);
            psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
            
            psiParamsFit = qpFit(questData.trialData, questData.qpPF, psiParamsQuest, questData.nOutcomes,...
                'lowerBounds',  [linear2Log(data.modulationDepthInPercentageMIN) SLOPE(1)   GUESSRATE LAPSE],...
                'upperBounds',  [linear2Log(data.modulationDepthInPercentageMAX) SLOPE(end) GUESSRATE LAPSE]);
            
            stimCounts = qpCounts(qpData(questData.trialData), questData.nOutcomes);
            stim = [stimCounts.stim];
            
            plotProportionsFit = qpPFWeibull(stimFine, psiParamsFit);
            
            for stimuliIndex = 1:length(stimCounts)
                nTrials(stimuliIndex) = sum(stimCounts(stimuliIndex).outcomeCounts);
                pCorrect(stimuliIndex) = stimCounts(stimuliIndex).outcomeCounts(2)/nTrials(stimuliIndex);
            end
            
            maxTrials = max(nTrials);
            if maxTrials == 0, maxTrials = 1; end % Avoid division by zero
            
            for stimuliIndex = 1:length(stimCounts)
                scatter(ax, stim(stimuliIndex), pCorrect(stimuliIndex), markerSize, 'o', 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0],...
                    'MarkerFaceAlpha', nTrials(stimuliIndex)/maxTrials, 'MarkerEdgeAlpha', nTrials(stimuliIndex)/maxTrials);
            end
            
            plot(ax, stimFine, plotProportionsFit(:, 2), '-', 'Color', [0 0 0], 'LineWidth', lineWidth);
            
        end 

        % --- Format Subplot ---
        hold(ax, 'off');
        box(ax, 'on');
        xlim(ax, [linear2Log(data.modulationDepthInPercentageMIN), linear2Log(data.modulationDepthInPercentageMAX)]);
        ylim(ax, [0 1.05]);
        set(ax, 'FontName', fontName, 'FontSize', axisTickFontSize, 'LineWidth', lineWidth);
        
        text(ax, -42, 0.2, ['{\bf' num2str(frequencyList(frequencyIndex)) '} Hz'], 'FontName', fontName, 'FontSize', axisLabelFontSize + 2, 'Interpreter', 'tex');
        
        drawnow;
    end

    % 4. ADD GLOBAL LABELS AND FINALIZE
    % ======================================================
    xlabel(tiledLayoutHandle, 'Modulation Depth (dB)', 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    ylabel(tiledLayoutHandle, 'Proportion Correct', 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    

    % 5. SAVE THE FIGURE
    % =========================================================
    outputFolder = fullfile(projectRoot, 'output');
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    
    filePathEmf = fullfile(outputFolder, [outputFileName, '_', figureType, '_', fileNameSuffix, '.emf']);
    filePathPng = fullfile(outputFolder, [outputFileName, '_', figureType, '_', fileNameSuffix, '.png']);

    % --- Use the 'print' command for precise size control ---
    set(figureHandle, 'PaperUnits', 'inches');
    set(figureHandle, 'PaperSize', [finalWidthInches, finalHeightInches]);
    set(figureHandle, 'PaperPosition', [0, 0, finalWidthInches, finalHeightInches]);
    
    % Save the EMF file
    print(figureHandle, filePathEmf, '-dmeta', '-r300');
    disp(['Figure saved to: ', filePathEmf]);
    
    % Save the PNG file
    print(figureHandle, filePathPng, '-dpng', '-r300');
    disp(['Figure saved to: ', filePathPng]);

    close(figureHandle);
end