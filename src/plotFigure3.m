%% function plotFigure3
%
% Description:
%   Generates and saves Figure 3 from the associated publication. This script
%   plots the measured output luminance of the TLM light source (with the
%   grey paper - as a neutral density filter) versus the input voltage, and
%   then uses linear interpolation to find the required voltage for a specific
%   target luminance.
%
% Inputs:
%   - Reads data from: '../data/rawData/spdMeasurementsWithGreyPaper.csv'
%
% Outputs:
%   - Saves the figure to:          '../output/fig3_oneColumn.emf'
%   - Also saves a PNG version to:  '../output/fig3_oneColumn.png'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure3
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));
    
    % 1. SETUP PUBLICATION AND DATA PARAMETERS
    % ===================================================================
    % --- Figure Style Parameters ---
    figureType        = 'oneColumn';
    finalWidthInches  = 3.5;
    finalHeightInches = 3.5;
    outputFileName    = 'fig3';
    fontName          = 'Arial';
    axisLabelFontSize = 10;
    axisTickFontSize  = 8;
    lineWidth         = 1;
    markerSize        = 3;
    
    % --- Data and Experimental Parameters ---
    NUM_REPS          = 3; % Each voltage level was measured three times.
    TARGET_LUMINANCE  = 50; % The target luminance for interpolation (in cd/m^2).
    
    % 2. CREATE THE FIGURE
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    axMain = axes;
    hold(axMain, 'on');
    
    
    % 3. LOAD AND PREPARE DATA
    % ======================================================
    % Use the new helper function to parse the CSV file.
    dataPath = fullfile(projectRoot, 'data', 'rawData', 'spdMeasurementsWithGreyPaper.csv');
    measurementData = loadSpdAndMetadata(dataPath);
    inputVoltages = unique(measurementData.drivingVoltage) / 1000; %conversion from the unit in mV to V
    numVoltages = numel(inputVoltages);
    luminanceValues = measurementData.luminance;
    
    % Reshape the data into a [repetitions x voltages] matrix and average.
    measuredLuminances = mean(reshape(luminanceValues, NUM_REPS, numVoltages));
    
    
    % 4. PLOT DATA AND INTERPOLATION
    % ======================================================
    % Plot the measured relationship
    plot(axMain, measuredLuminances, inputVoltages, 'ko-', 'LineWidth', lineWidth, 'MarkerSize', markerSize, 'MarkerFaceColor', 'w');
    
    % Create a linear interpolation model
    [fitObj, ~] = fit(measuredLuminances', inputVoltages', 'linearinterp');
    outputVoltage = feval(fitObj, TARGET_LUMINANCE);
    
    % Plot the interpolated point and the corresponding dashed lines
    plot(axMain, TARGET_LUMINANCE, outputVoltage, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', markerSize);
    line(axMain, [TARGET_LUMINANCE, TARGET_LUMINANCE], [0, outputVoltage], 'Color', 'r', 'LineStyle', '--', 'LineWidth', lineWidth);
    line(axMain, [0, TARGET_LUMINANCE], [outputVoltage, outputVoltage], 'Color', 'r', 'LineStyle', '--', 'LineWidth', lineWidth);
    plot(axMain, 0, outputVoltage, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', markerSize);
    hold(axMain, 'off');
    
    
    % 5. FORMAT AXES AND LABELS
    % ===========================================================
    box(axMain, 'on');
    xlim(axMain, [0, 120]);
    ylim(axMain, [0, 0.25]);
    set(axMain, 'FontName', fontName, 'FontSize', axisTickFontSize, 'LineWidth', lineWidth);
    
    xlabel(axMain, 'Output Luminance (cd·m^{-2})', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    ylabel(axMain, 'Required Voltage (V Peak-to-Peak)', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    
    
    % 8. SAVE THE FIGURE
    % =========================================================
    outputFolder = fullfile(projectRoot, 'output');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder)
    end
    
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