%% function plotFigure6
%
% Description:
%   Generates and saves Figure 6 from the associated publication. This script
%   plots the average visibility threshold as a function of temporal frequency,
%   using a dual y-axis to show both log sensitivity and modulation depth.
%   Individual participant data is shown as a scatter plot.
%
% Inputs:
%   - Reads pre-computed thresholds from: '../data/processedData/visibilityThresholds.csv'
%
% Outputs:
%   - Saves the figure to:          '../output/fig6_twoColumn.emf'
%   - Also saves a PNG version to:  '../output/fig6_twoColumn.png'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure6
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));

    % 1. SETUP PUBLICATION AND EXPERIMENTAL PARAMETERS
    % ===================================================================
    % --- Figure Style Parameters ---
    figureType        = 'twoColumn';
    finalWidthInches  = 7.2;
    finalHeightInches = 5.6;
    outputFileName    = 'fig6';
    fontName          = 'Arial';
    axisLabelFontSize = 14;
    axisTickFontSize  = 10;
    lineWidth         = 1;
    markerSize        = 6;
    dataPointSize     = 100;
    transparencyValue = 0.1;

    % --- Data and Experimental Parameters ---
    frequencyList = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    
    % 2. LOAD PRE-COMPUTED ANALYSIS RESULTS
    % ======================================================
    thresholdDataPath = fullfile(projectRoot, 'data', 'processedData', 'visibilityThresholds.csv');
    if ~exist(thresholdDataPath, 'file')
        error('Threshold data file not found. Please run computeVisibilityThresholds.m first.');
    end
    % readtable will correctly handle the header and the participant ID column.
    thresholdsTable = readtable(thresholdDataPath);
    visibilityThresholds = thresholdsTable{:, 2 : end};

    % 3. CREATE THE FIGURE
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    ax = gca; % Get the axes handle
    hold(ax, 'on');

    % 4. PREPARE DATA FOR PLOTTING
    % ======================================================
    % Convert modulation depth thresholds to log sensitivity (S = 1/T)
    logSensitivity = log10(1 ./ visibilityThresholds);
    
    % Calculate the mean and 95% confidence intervals for each frequency
    meanLogSensitivity = zeros(1, numel(frequencyList));
    ci95 = zeros(1, numel(frequencyList));
    for i = 1 : numel(frequencyList)
        [meanLogSensitivity(i), ci95(i)] = confidenceIntervalCalculation(logSensitivity(:, i), 0.05);
    end
    
    % Perform a third-order polynomial fit on the mean data
    xData = log10(frequencyList);
    [fitObject, gof] = fit(xData', meanLogSensitivity', 'poly3');
    % 1. Get the coefficients from the fit object.
    coefficients = coeffvalues(fitObject);
    % 2. Get the R-squared value from the goodness-of-fit struct.
    rSquared = gof.rsquare;
    % 3. Create a fine x-axis for plotting the smooth curve.
    xFit = linspace(min(xData), max(xData), 100)';
    % 4. Evaluate the fit object to get the corresponding y-values.
    yFit = feval(fitObject, xFit);

    % 5. PLOT DATA ON DUAL Y-AXES
    % ======================================================
    % --- Plot on the LEFT Y-Axis (Log Sensitivity) ---
    yyaxis(ax, 'left');
    
    % Plot individual participant data as a semi-transparent scatter plot
    scatter(ax, log10(frequencyList), logSensitivity, dataPointSize, 'o', 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'k', 'MarkerFaceAlpha', transparencyValue, 'MarkerEdgeAlpha', transparencyValue);
    
    % Plot the mean data with error bars
    errorbar(ax, xData, meanLogSensitivity, ci95, 's', 'MarkerSize', markerSize, 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', 'k', 'Color', 'k', 'LineWidth', lineWidth * 2);
    
    % Plot the fitted curve
    plot(ax, xFit, yFit, 'k-', 'LineWidth', lineWidth * 2);
    set(ax, 'FontName', fontName, 'FontSize', axisTickFontSize);
    % --- Format the LEFT Y-Axis ---
    ylabel(ax, 'log_{10}(\it{S})', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    
    %% EXPLANATION AND FIX FOR EMF EXPORT BUG
    % The 'Painters' renderer in MATLAB can fail to export transparent
    % markers that lie exactly on an axis boundary (e.g., y=0).
    % To work around this, we "nudge" the lower y-limit by a tiny,
    % visually insignificant amount. This ensures the markers are no
    % longer on the exact edge and will be rendered correctly in the .emf file.
    yLimLowerNudge = -0.001;
    ylim(ax, [yLimLowerNudge 2.5]);

    %ylim(ax, [0 2.5]);
    set(ax, 'YColor', 'k'); % Ensure left axis color is black
    
    % --- Format the RIGHT Y-Axis (Modulation Depth) ---
    yyaxis(ax, 'right');
    
    % The right axis is a transformed scale of the left axis, so we don't plot new data.
    % We just set the limits and labels to correspond correctly.
    set(ax, ...
        'YTick',       [0.001, 0.005, 0.01, 0.02, 0.03, 0.04, 0.05, 0.1, 0.2, 0.3, 0.4, 0.5, 1], ...
        'YTickLabel',  {'0.001', '0.005', '0.01', '0.02', '0.03', '0.04', '0.05', '0.1', '0.2', '0.3', '0.4', '0.5', '1'}, ...
        'YLim',        [1/10^2.5, 1/10^yLimLowerNudge], ... % Corresponds to the left axis [0, 2.5]
        'YScale',      'log', ...
        'YDir',        'reverse', ...
        'YColor',      'k');
    ylabel(ax, 'Modulation Depth Visibility Threshold', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    
    % 6. FORMAT SHARED X-AXIS AND FINALIZE
    % ===========================================================
    hold(ax, 'off');
    box(ax, 'on');
    
    % Set X-axis properties
    xlim(ax, [log10(70), log10(2000)]);
    xticks(ax, log10(frequencyList));
    xticklabels(ax, {'80', '160', '200', '300', '400', '600', '900', '1000', '1200', '1800'});
    xtickangle(ax, 45);
    xlabel(ax, 'Temporal Frequency (Hz)', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    
    % 7. SAVE THE FIGURE AND FIT PARAMETERS
    % =========================================================
    outputFolder = fullfile(projectRoot, 'output');
    if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end
    
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
    
     % --- Save the Fit Parameters to a Text File ---
    paramFileName = [outputFileName, '_fitCoefficients.txt'];
    paramFilePath = fullfile(outputFolder, paramFileName);
    
    % Open the file for writing
    fileID = fopen(paramFilePath, 'w');
    fprintf(fileID, 'Third-Order Polynomial Fit Parameters for Figure 6\n\n');
    fprintf(fileID, 'Fit Equation: y = p0 + p1*x + p2*x^2 + p3*x^3\n');
    fprintf(fileID, '-------------------------------------------------\n');
    fprintf(fileID, 'p0 (Intercept): %.4f\n', coefficients(4));
    fprintf(fileID, 'p1 (Linear):    %.4f\n', coefficients(3));
    fprintf(fileID, 'p2 (Quadratic): %.4f\n', coefficients(2));
    fprintf(fileID, 'p3 (Cubic):     %.4f\n', coefficients(1));
    fprintf(fileID, '-------------------------------------------------\n');
    fprintf(fileID, 'R-squared:      %f\n', rSquared);
    fclose(fileID);
    
    disp(['Fit parameters saved to: ' paramFileName]);

    close(figureHandle);
end