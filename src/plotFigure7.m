%% function plotFigure7
%
% Description:
%   Generates and saves a separate figure for each participant, showing their
%   individual visibility thresholds across different temporal frequencies.
%   Each plot includes the raw data points, a 3rd-order polynomial fit,
%   and the 95% confidence interval of the fit.
%
% Inputs:
%   - Reads pre-computed thresholds from:   '../data/processedData/visibilityThresholds.csv'
%   - Reads pre-computed fit results from:  '../data/processedData/individualFitResults.mat'
%
% Outputs:
%   - Saves 22 individual figure files to a dedicated subfolder:
%    e.g.,
%    '../output/figure7_individual_plots/fig7_participantXX_oneColumn.emf'
%    '../output/figure7_individual_plots/fig7_participantXX_oneColumn.png'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure7
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));

    % 1. SETUP PUBLICATION AND EXPERIMENTAL PARAMETERS
    % ===================================================================
    % --- Figure Style Parameters ---
    figureType        = 'oneColumn';
    finalWidthInches  = 3.5;
    finalHeightInches = 3.5;
    outputFileName    = 'fig7'; % Base name for all output files
    fontName          = 'Arial';
    axisLabelFontSize = 10;
    axisTickFontSize  = 8;
    lineWidth         = 1;
    markerSize        = 3;

    % --- Data and Experimental Parameters ---
    frequencyList     = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    
    % 2. LOAD PRE-COMPUTED ANALYSIS RESULTS
    % ======================================================
    thresholdDataPath = fullfile(projectRoot, 'data', 'processedData', 'visibilityThresholds.csv');
    if ~exist(thresholdDataPath, 'file')
        error('Threshold data file not found. Please run computeVisibilityThresholds.m first.');
    end
    % readtable will correctly handle the header and the participant ID column.
    thresholdsTable = readtable(thresholdDataPath);
    visibilityThresholds = thresholdsTable{:, 2 : end};

    analysisDataPath = fullfile(projectRoot, 'data', 'processedData', 'individualFitResults.mat');
    analysisData = load(analysisDataPath);
    results = analysisData.results; % The struct array

    % 3. LOOP THROUGH PARTICIPANTS, PLOT, AND SAVE
    % ======================================================
    fprintf('Generating individual plots for Fig 7...\n');
    
    for participantId = 1:numel(results.participantData)       
        
        fprintf('--> Processing Participant %02d\n', participantId);
        
        % --- Create a new figure for each participant ---
        figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
        ax = gca;
        
         % --- Get Data for this Participant ---
        logSensitivity = log10(1 ./ visibilityThresholds(participantId, :));
        xData = log10(results.frequencyList); % Get freq list from the struct
        fitObject = results.participantData(participantId).fitObject;

        % --- Use the fitObject to get the curve and confidence intervals ---
        xFit = linspace(min(xData), max(xData), 100);
        yFit = feval(fitObject, xFit);
        confidenceIntervals = predint(fitObject, xFit, 0.95, 'Functional');
        
        % --- Plot on LEFT Y-Axis ---
        yyaxis(ax, 'left');
        hold(ax, 'on');
        
        % Plot the confidence interval as a shaded region
        fill([xFit, fliplr(xFit)], [confidenceIntervals(:, 2)', fliplr(confidenceIntervals(:, 1)')], ...
            'k', 'FaceAlpha', 0.1, 'LineStyle', 'none');
            
        % Plot the main fitted curve
        plot(ax, xFit, yFit, 'k-', 'LineWidth', lineWidth * 3, 'Color', [0.98, 0.40, 0.35]);
        
        % Plot the raw data points
        plot(ax, xData, logSensitivity, 'ko-', 'LineWidth', lineWidth, ...
            'MarkerEdgeColor', [0.3 0.3 0.3], 'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerSize', markerSize);
        
        % Add participant ID text to the plot
        text(ax, log10(80), 2, ['PID: ' '{\bf' sprintf('%02d', participantId) '}'], 'FontName', fontName, 'FontSize', axisLabelFontSize + 2, 'Interpreter', 'tex');
        
        % --- Format LEFT Y-Axis ---
        ylim(ax, [0 2.5]);
        yticks(ax, 0:0.5:2.5);
        set(ax, 'YColor', 'k');
        
        % --- Format RIGHT Y-Axis ---
        yyaxis(ax, 'right');
        set(ax, 'YTick',   [0.001,   0.005,   0.01,   0.02,   0.03,   0.04,   0.05,   0.1,   0.2,   0.3,   0.4,   0.5,   1], ...
            'YTickLabel', {'0.001', '0.005', '0.01', '0.02', '0.03', '0.04', '0.05', '0.1', '0.2', '0.3', '0.4', '0.5', '1'}, ...
            'YLim', [1/10^2.5, 1/10^0], ...
            'YScale', 'log', 'YDir', 'reverse', 'YColor', 'k', ...
            'FontName', fontName, 'FontSize', axisTickFontSize);
        ylabel(ax, 'Modulation Depth Visibility Threshold', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
        
        yyaxis(ax, 'left');
        ylabel(ax, 'log_{10}(\it{S})', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');

        % --- Format Shared X-Axis and Finalize Plot ---
        hold(ax, 'off');
        box(ax, 'on');
        xlim(ax, [log10(70), log10(2000)]);
        xticks(ax, log10(frequencyList([1 2 4 6 7 10])));
        xticklabels(ax, {'80', '160', '300', '600', '900', '1800'});
        xtickangle(ax, 60);
        xlabel(ax, 'Temporal Frequency (Hz)', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
        
       
        % --- Save the Figure ---
        % Create a dedicated subfolder for these individual plots to keep
        % the main output directory clean.
        outputFolder = fullfile(projectRoot, 'output', 'fig7_individual_plots');
        if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
        
        % Create a descriptive filename for each participant
        fileNameSuffix = sprintf('participant%02d', participantId);
        
        filePathEmf = fullfile(outputFolder, [outputFileName, '_', fileNameSuffix, '_', figureType, '.emf']);
        filePathPng = fullfile(outputFolder, [outputFileName, '_', fileNameSuffix, '_', figureType, '.png']);

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
    
    fprintf('\nFig 7 generation complete.\n');
end