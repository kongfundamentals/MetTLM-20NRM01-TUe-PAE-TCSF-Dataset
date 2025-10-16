%% function plotFigure4
%
% Description:
%   Generates and saves Figure 4 from the associated publication. This script
%   creates a schematic timeline of the experimental procedure, detailing
%   the sequence of tasks for the participant.
%
% Inputs:
%   - None. This script generates the figure from hard-coded definitions.
%
% Outputs:
%   - Saves the figure to:          '../output/fig4_oneColumn.emf'
%   - Also saves a PNG version to:  '../output/fig4_oneColumn.png'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure4
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));
    
    % 1. SETUP PUBLICATION AND GEOMETRIC PARAMETERS
    % ===================================================================
    % --- Figure Style Parameters ---
    figureType        = 'oneColumn';
    finalWidthInches  = 3.5;
    finalHeightInches = 5.5;
    outputFileName    = 'fig4';
    fontName          = 'Arial';
    itemFontSize      = 10;
    phaseFontSize     = 12;
    lineWidth         = 1;
    
    % --- Timeline Geometric Parameters (in "data units") ---
    xTimeline         = 0;    % X-position of the main timeline
    tickLength        = 0.5;  % Length of the horizontal ticks
    textOffset        = 0.2;  % Space between tick and text label
    itemSpacing       = 0.45; % Vertical distance between items
    gapSize           = 0.25; % Extra gap between the two main phases
    bracePadding      = 0.2;  % Space between item and brace
    timeLabelOffset   = 0.5;  % Space for the "Time" label at the bottom
    xBrace            = -1.0; % X-position of the phase braces
    braceWidth        = 0.2;  % Width of the brace arms
    xPhaseLabelOffset = 0.3;  % Space between brace and phase label
    
    % --- Define final "crop" for the figure ---
    finalXLim = [-1.5, 5.5];
    finalYLim = [-1.0, 5.0];
    
    
    % 2. CREATE THE FIGURE
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    axMain = gca; % Get the current axes
    hold(axMain, 'on');
    
    
    % 3. DEFINE CONTENT AND CALCULATE POSITIONS
    % ======================================================
    labels = {
        'Informed Consent Form', 'Leiden Visual Sensitivity Scale', 'Pattern Glare Test', ...
        'Landolt C Test', 'Demographic Information', 'Instruction', 'Practice Trials', ...
        'Data Collection', 'Questionnaire', 'Compensation'
        };
    labels = fliplr(labels); % Draw from bottom to top
    
    preliminariesLabel  = 'Preliminaries';
    dataCollectionLabel = 'Data Collection';
    
    % Calculate the Y position for each item on the timeline
    yPositions = (1:length(labels)) * itemSpacing;
    
    % Shift the "Data Collection" items down to create a visual gap
    dataCollectionIndices = 1:(length(labels)-5);
    yPositions(dataCollectionIndices) = yPositions(dataCollectionIndices) - gapSize;
    
    
    % 4. DRAW PLOT ELEMENTS
    % ======================================================
    % --- Main Timeline and Arrowhead ---
    axisStart = min(yPositions) - timeLabelOffset;
    axisEnd = max(yPositions) + 0.5;
    plot(axMain, [xTimeline, xTimeline], [axisStart, axisEnd], 'k-', 'LineWidth', lineWidth);
    text(axMain, xTimeline, axisStart - timeLabelOffset, 'Time', 'HorizontalAlignment', 'center', ...
        'FontName', fontName, 'FontSize', phaseFontSize, 'FontWeight', 'bold');
    
    % Calculate aspect ratio to draw a perfectly shaped arrowhead
    xRange = finalXLim(2) - finalXLim(1);
    yRange = finalYLim(2) - finalYLim(1);
    aspectRatioCorrection = (finalHeightInches / finalWidthInches) * (xRange / yRange);
    arrowSizeY = 0.15;
    arrowSizeX = arrowSizeY * aspectRatioCorrection;
    patch(axMain, [xTimeline - arrowSizeX, xTimeline, xTimeline + arrowSizeX], ...
        [axisStart, axisStart - arrowSizeY*2, axisStart], 'k');
    
    % --- Items and Ticks ---
    for i = 1:length(labels)
        y = yPositions(i);
        xTickEnd = xTimeline + tickLength;
        xTextPosition = xTickEnd + textOffset;
        plot(axMain, [xTimeline, xTickEnd], [y, y], 'k-', 'LineWidth', lineWidth * 0.8);
        text(axMain, xTextPosition, y, labels{i}, 'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', 'FontName', fontName, 'FontSize', itemFontSize);
    end
    
    % --- Braces and Phase Labels ---
    % Preliminaries Brace
    preliminariesIndices = (length(labels) - 5 + 1):length(labels);
    y1Start = min(yPositions(preliminariesIndices)) - bracePadding;
    y1End = max(yPositions(preliminariesIndices)) + bracePadding;
    yCenterPreliminaries = mean([y1Start, y1End]);
    plot(axMain, [xBrace, xBrace + braceWidth], [y1Start, y1Start], 'k-', 'LineWidth', lineWidth * 0.8);
    plot(axMain, [xBrace, xBrace], [y1Start, y1End], 'k-', 'LineWidth', lineWidth * 0.8);
    plot(axMain, [xBrace, xBrace + braceWidth], [y1End, y1End], 'k-', 'LineWidth', lineWidth * 0.8);
    text(axMain, xBrace - xPhaseLabelOffset, yCenterPreliminaries, preliminariesLabel, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Rotation', 90, ...
        'FontName', fontName, 'FontSize', phaseFontSize, 'FontWeight', 'bold');
    
    % Data Collection Brace
    y2Start = min(yPositions(dataCollectionIndices)) - bracePadding;
    y2End = max(yPositions(dataCollectionIndices)) + bracePadding;
    yCenterDataCollection = mean([y2Start, y2End]);
    plot(axMain, [xBrace, xBrace + braceWidth], [y2Start, y2Start], 'k-', 'LineWidth', lineWidth * 0.8);
    plot(axMain, [xBrace, xBrace], [y2Start, y2End], 'k-', 'LineWidth', lineWidth * 0.8);
    plot(axMain, [xBrace, xBrace + braceWidth], [y2End, y2End], 'k-', 'LineWidth', lineWidth * 0.8);
    text(axMain, xBrace - xPhaseLabelOffset, yCenterDataCollection, dataCollectionLabel, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Rotation', 90, ...
        'FontName', fontName, 'FontSize', phaseFontSize, 'FontWeight', 'bold');
    
    
    % 5. FINALIZE AND FRAME THE FIGURE
    % ===========================================================
    hold(axMain, 'off');
    axis(axMain, 'off');
    xlim(axMain, finalXLim);
    ylim(axMain, finalYLim);
    
    
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