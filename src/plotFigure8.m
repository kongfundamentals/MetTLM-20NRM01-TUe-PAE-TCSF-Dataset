%% function plotFigure8
%
% Description:
%   Generates and saves Figure 8 from the associated publication. It loads
%   pre-computed data to visualize the distribution of peak sensitivity and
%   peak frequency across all participants using stem plots and histograms.
%
% Inputs:
%   - Reads pre-computed fit results from: '../data/processedData/individualFitResults.mat'
%
% Outputs:
%   - Saves the figure to: 
%               '../output/fig8_twoColumn.emf'
%               '../output/fig8_twoColumn.png'
%   - Saves a .csv table with peak parameters for supplementary material:
%               '../output/table_S9_peakParameters.csv'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure8
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));

    % 1. SETUP PUBLICATION PARAMETERS
    % ===================================================================
    figureType        = 'twoColumn';
    finalWidthInches  = 7.2;
    finalHeightInches = 6;
    outputFileName    = 'fig8';
    fontName          = 'Arial';
    axisLabelFontSize = 12;
    axisTickFontSize  = 8;
    lineWidth         = 1;
    markerSize        = 3;
    numberOfBins      = 6;

    % 2. LOAD PRE-COMPUTED ANALYSIS RESULTS
    % ======================================================
    analysisDataPath = fullfile(projectRoot, 'data', 'processedData', 'individualFitResults.mat');
    if ~exist(analysisDataPath, 'file')
        error('Analysis results file not found. Please run computeIndividualFits.m first.');
    end
    data = load(analysisDataPath);
    results = data.results; % Unpack the struct array
    participantIdList   = [results.participantData.participantId]';
    peakSensitivities   = [results.participantData.peakSensitivity]';
    peakFrequencies     = [results.participantData.peakFrequency]';

    % 3. CREATE THE FIGURE AND SUBPLOTS
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    ax1 = subplot(2, 2, 1); ax2 = subplot(2, 2, 2);
    ax3 = subplot(2, 2, 3); ax4 = subplot(2, 2, 4);

    % 4. PLOT DATA (NO ANALYSIS NEEDED)
    % ======================================================
    % --- Top Row: Peak Sensitivity ---
    [sortedSensitivities, sortOrderSensitivity] = sort(peakSensitivities, 'descend');
    
    stem(ax1, sortedSensitivities, 'filled', 'MarkerSize', markerSize, 'Color', 'k', 'LineWidth', lineWidth);
    hold(ax1, 'on');
    yline(ax1, mean(peakSensitivities), 'r--', 'LineWidth', lineWidth);
    
    histogram(ax2, peakSensitivities, numberOfBins, 'Orientation', 'horizontal', 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'k', 'FaceAlpha', 0.7);
    hold(ax2, 'on');
    hYLine1 = yline(ax2, mean(peakSensitivities), 'r--', 'LineWidth', lineWidth);

    % --- Bottom Row: Peak Frequency ---
    [sortedFrequencies, sortOrderFrequency] = sort(peakFrequencies, 'descend');
    
    stem(ax3, sortedFrequencies, 'filled', 'MarkerSize', markerSize, 'Color', 'k', 'LineWidth', lineWidth);
    hold(ax3, 'on');
    yline(ax3, mean(peakFrequencies), 'r--', 'LineWidth', lineWidth);

    histogram(ax4, peakFrequencies, numberOfBins, 'Orientation', 'horizontal', 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'k', 'FaceAlpha', 0.7);
    hold(ax4, 'on');
    hYLine2 = yline(ax4, mean(peakFrequencies), 'r--', 'LineWidth', lineWidth);

    % 5. FORMAT AND CUSTOMIZE PLOT LAYOUT
    % ======================================================
    set(ax1, 'FontName', fontName, 'FontSize', axisTickFontSize, 'YColor', 'k', ...
        'XLim', [0 23], 'YLim', [0 2], 'XTick', 1 : 22, 'XTickLabel', cellstr(num2str(participantIdList(sortOrderSensitivity))), 'XTickLabelRotation', 0);
    title(ax1, 'Peak Sensitivity', 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    xlabel(ax1, 'PID', 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    ylabel(ax1, 'log_{10}(\it{S})', 'FontSize', axisLabelFontSize, 'Interpreter', 'tex', 'FontWeight', 'bold');

    set(ax2, 'FontName', fontName, 'FontSize', axisTickFontSize, 'XTick', 0:10, 'YTick', [], 'YLim', [0 2], 'XTickLabelRotation', 0);
    title(ax2, {'Histogram of', 'Peak Sensitivities'}, 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    legend(ax2, hYLine1, 'Mean Peak Sensitivity', 'FontSize', axisTickFontSize, 'Location', 'northeast');
    
    yyaxis(ax2, 'right');
    set(ax2, 'YLim', [1/10^2 1/10^0], 'YScale', 'log', 'YDir', 'reverse', 'YColor', 'k', ...
        'YTick', [0.01 0.05 0.1 0.5 1], 'YTickLabel', {'0.01', '0.05', '0.1', '0.5', '1'});
    ylabel(ax2, {'Modulation Depth', 'Visibility Threshold'}, 'FontSize', axisLabelFontSize, 'Interpreter', 'tex', 'FontWeight', 'bold');

    set(ax3, 'FontName', fontName, 'FontSize', axisTickFontSize, 'YColor', 'k', ...
        'XLim', [0 23], 'YLim', [100 1000], 'XTick', 1 : 22, 'YTick', 100:100:1000, 'XTickLabel', cellstr(num2str(participantIdList(sortOrderFrequency))), 'XTickLabelRotation', 0);
    title(ax3, 'Peak Frequency', 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    xlabel(ax3, 'PID', 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    ylabel(ax3, 'Frequency (Hz)', 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    
    set(ax4, 'FontName', fontName, 'FontSize', axisTickFontSize, 'XTick', 0:8, 'YTick', [], 'YLim', [100 1000], 'XTickLabelRotation', 0);
    title(ax4, {'Histogram of', 'Peak Frequencies'}, 'FontSize', axisLabelFontSize, 'FontWeight', 'bold');
    legend(ax4, hYLine2, 'Mean Peak Frequency', 'FontSize', axisTickFontSize, 'Location', 'northeast');
    
    pos1 = get(ax1, 'Position'); pos2 = get(ax2, 'Position'); pos3 = get(ax3, 'Position'); pos4 = get(ax4, 'Position');
    ratioColumn1 = 0.62; horizontalGap = 0;
    totalPlotWidth = pos1(3) + pos2(3);
    newWidth1 = totalPlotWidth * ratioColumn1;
    newWidth2 = totalPlotWidth * (1 - ratioColumn1);
    set(ax1, 'Position', [pos1(1), pos1(2), newWidth1, pos1(4)]);
    set(ax2, 'Position', [pos1(1) + newWidth1 + horizontalGap, pos2(2), newWidth2, pos2(4)]);
    set(ax3, 'Position', [pos3(1), pos3(2), newWidth1, pos3(4)]);
    set(ax4, 'Position', [pos3(1) + newWidth1 + horizontalGap, pos4(2), newWidth2, pos4(4)]);

    % 6. SAVE PEAK DATA FOR SUPPLEMENTARY MATERIAL (TABLE S9)
    % =========================================================
    outputFolder = fullfile(projectRoot, 'output');
    peakFrequencyInHz = round(peakFrequencies);
    peakSensitivityInLogSensitivity = round(peakSensitivities, 2);
    
    
    T = table(participantIdList, peakFrequencyInHz, peakSensitivityInLogSensitivity);
    T.Properties.VariableNames = {'participantID', 'peakFrequencyInHz', 'peakSensitivityInLog10'};
    tableFileName = 'table_S9_peakParameters.csv';
    writetable(T, fullfile(outputFolder, tableFileName));
    disp(['Supplementary data saved to: ' tableFileName]);

    % 7. SAVE THE FIGURE
    % =========================================================
    filePathEmf = fullfile(outputFolder, [outputFileName, '_', figureType, '.emf']);
    filePathPng = fullfile(outputFolder, [outputFileName, '_', figureType, '.png']);

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