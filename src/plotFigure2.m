%% function plotFigure2
%
% Description:
%   Generates and saves Figure 2 from the associated publication. This script
%   plots the relative Spectral Power Distribution (SPD) of the TLM light
%   source (without the grey paper - as a neutral density filter) at 9 different driving voltages.
%
% Inputs:
%   - Reads data from: '../data/rawData/spdMeasurementsWithoutGreyPaper.csv'
%
% Outputs:s
%   - Saves the figure to:          '../output/fig2_oneColumn.emf'
%   - Also saves a PNG version to:  '../output/fig2_oneColumn.png'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure2
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    % Go up one level from /src to the main folder
    % Add utilities to the path in a robust way
    
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));
    
    % 1. SETUP PUBLICATION PARAMETERS
    % ===================================================================
    figureType        = 'oneColumn';
    finalWidthInches  = 3.5;
    finalHeightInches = 3.5;
    outputFileName    = 'fig2'; % Base name for the output file
    fontName          = 'Arial';
    axisLabelFontSize = 10;
    axisTickFontSize  = 8;
    lineWidth         = 1;
    
    WAVELENGTH_START = 380;
    WAVELENGTH_END   = 780;
    NUM_REPS         = 3;
    
    
    % 2. CREATE THE FIGURE
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    axMain = axes('Position', [0.18 0.18 0.78 0.75]);
    hold(axMain, 'on');
    
    
    % 3. LOAD AND PREPARE DATA
    % ======================================================
    dataPath = fullfile(projectRoot, 'data', 'rawData', 'spdMeasurementsWithoutGreyPaper.csv');
    measurementData = loadSpdAndMetadata(dataPath);
    spd = measurementData.spd;
    numVoltages = numel(unique(measurementData.drivingVoltage));
    % Normalize each spectrum (column) to its own maximum value
    normalizedSPD = spd ./ max(spd, [], 1);
    
    % Average the repetitions for each voltage level
    numWavelengths = size(normalizedSPD, 1);
    averageSPD = zeros(numWavelengths, numVoltages);
    for i = 1 : numVoltages
        colStart = (i - 1) * NUM_REPS + 1;
        colEnd   = i * NUM_REPS;
        averageSPD(:, i) = mean(normalizedSPD(:, colStart:colEnd), 2);
    end
    
    
    % 4. CREATE AND FORMAT THE MAIN PLOT
    % ======================================================
    wavelengths = linspace(WAVELENGTH_START, WAVELENGTH_END, size(averageSPD, 1));
    
    % Plot all 9 SPD curves onto the main axes
    plot(axMain, wavelengths, averageSPD, 'LineWidth', lineWidth);
    hold(axMain, 'off');
    
    % Manual formatting for the main plot
    box(axMain, 'on');
    ylim(axMain, [-0.01 1.01]);
    xlim(axMain, [350 800]);
    xticks(axMain, 350:50:800);
    grid(axMain, 'off');
    set(axMain, 'FontName', fontName, 'FontSize', axisTickFontSize, 'LineWidth', lineWidth);
    
    xlabel(axMain, 'Wavelength (nm)', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'FontWeight', 'bold');
    ylabel(axMain, 'Relative Spectral Power Distribution', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'FontWeight', 'bold');
    
    
    % ===================================================================
    % --- CONTROL PANEL FOR INSETS AND BOXES ---
    % ===================================================================
    insetWidth          = 0.2;
    insetHeight         = 0.2;
    dashedBoxWidthData  = 50;
    dashedBoxHeightData = 0.1;
    inset1PositionXY    = [0.25, 0.60];
    inset2PositionXY    = [0.50, 0.25];
    box1DataXY          = [425, 0.3];
    box2DataXY          = [520, 0.47];
    % ===================================================================
    
    % 5. CREATE THE FIRST INSET (Top-Left, Blue Peak)
    % =========================================================
    insetPosition1 = [inset1PositionXY(1), inset1PositionXY(2), insetWidth, insetHeight];
    axInset1 = axes('Position', insetPosition1);
    plot(axInset1, wavelengths, averageSPD, 'LineWidth', lineWidth);
    box1Data = [box1DataXY(1), box1DataXY(2), dashedBoxWidthData, dashedBoxHeightData];
    xlim(axInset1, [box1Data(1), box1Data(1) + box1Data(3)]);
    ylim(axInset1, [box1Data(2), box1Data(2) + box1Data(4)]);
    set(axInset1, 'Box', 'on', 'LineWidth', lineWidth, 'XTick', [], 'YTick', []);
    
    
    % 6. CREATE THE SECOND INSET (Middle-Right, Slope)
    % =========================================================
    insetPosition2 = [inset2PositionXY(1), inset2PositionXY(2), insetWidth, insetHeight];
    axInset2 = axes('Position', insetPosition2);
    plot(axInset2, wavelengths, averageSPD, 'LineWidth', lineWidth);
    box2Data = [box2DataXY(1), box2DataXY(2), dashedBoxWidthData, dashedBoxHeightData];
    xlim(axInset2, [box2Data(1), box2Data(1) + box2Data(3)]);
    ylim(axInset2, [box2Data(2), box2Data(2) + box2Data(4)]);
    set(axInset2, 'Box', 'on', 'LineWidth', lineWidth, 'XTick', [], 'YTick', []);
    
    
    % 7. ADD ANNOTATIONS (CONNECTING LINES AND BOXES)
    % =========================================================
    dataToFigure = @(ax, x, y) [ax.Position(1) + (x-ax.XLim(1))/diff(ax.XLim)*ax.Position(3), ax.Position(2) + (y-ax.YLim(1))/diff(ax.YLim)*ax.Position(4)];
    positionStart = dataToFigure(axMain, box1Data(1), box1Data(2));
    positionEnd   = dataToFigure(axMain, box1Data(1)+box1Data(3), box1Data(2)+box1Data(4));
    boxPosition1  = [positionStart, positionEnd - positionStart];
    annotation('rectangle', boxPosition1, 'LineStyle', '--', 'LineWidth', lineWidth);
    originX = boxPosition1(1) + boxPosition1(3) / 2;
    originY = boxPosition1(2) + boxPosition1(4);
    destinationLeftX  = insetPosition1(1) + 0.2 * insetPosition1(3);
    destinationRightX = insetPosition1(1) + 0.8 * insetPosition1(3);
    destinationY      = insetPosition1(2);
    annotation('line', [originX, destinationLeftX], [originY, destinationY], 'LineWidth', lineWidth);
    annotation('line', [originX, destinationRightX], [originY, destinationY], 'LineWidth', lineWidth);
    positionStart2 = dataToFigure(axMain, box2Data(1), box2Data(2));
    positionEnd2   = dataToFigure(axMain, box2Data(1) + box2Data(3), box2Data(2) + box2Data(4));
    boxPosition2   = [positionStart2, positionEnd2 - positionStart2];
    annotation('rectangle', boxPosition2, 'LineStyle', '--', 'LineWidth', lineWidth);
    originX = boxPosition2(1) + boxPosition2(3) / 2;
    originY = boxPosition2(2);
    destinationLeftX  = insetPosition2(1) + 0.2 * insetPosition2(3);
    destinationRightX = insetPosition2(1) + 0.8 * insetPosition2(3);
    destinationY       = insetPosition2(2) + insetPosition2(4);
    annotation('line', [originX, destinationLeftX], [originY, destinationY], 'LineWidth', lineWidth);
    annotation('line', [originX, destinationRightX], [originY, destinationY], 'LineWidth', lineWidth);
    
    
    % 8. SAVE THE FIGURE
    % =========================================================
    outputFolder = fullfile(projectRoot, 'output');
    
    % Ensure the output directory exists
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