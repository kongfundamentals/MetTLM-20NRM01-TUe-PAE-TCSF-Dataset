%% function plotFigure9
%
% Description:
%   Generates and saves Figure 9 from the associated publication. This script
%   creates a custom bar chart infographic to visualize the summary results
%   of the post-experiment questionnaire completed by the participants.
%
% Inputs:
%   - None. All questionnaire data is defined within this script.
%
% Outputs:
%   - Saves the figure to:          '../output/fig9_twoColumn.emf'
%   - Also saves a PNG version to:  '../output/fig9_twoColumn.png'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure9
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));

    % 1. SETUP PUBLICATION AND FIGURE PARAMETERS
    % ===================================================================
    % --- Figure Style Parameters ---
    figureType        = 'twoColumn';
    finalWidthInches  = 7.2;
    finalHeightInches = 8;
    outputFileName    = 'fig9';
    fontName          = 'Arial';
    axisLabelFontSize = 12;
    axisTickFontSize  = 10;
    lineWidth         = 1;
    barHeight         = 1.5;

    % --- Geometric and Style Properties ---
    yStepAnswer       = -2;
    yStepQuestion     = -3;
    xPercentLabel     = -2;
    xAnswerLabel      = 2;
    barFillColor      = [0.7, 0.7, 0.7];
    barEdgeColor      = [0.7, 0.7, 0.7];
    barAlpha          = 0.4;

    % 2. DEFINE QUESTIONNAIRE DATA
    % ======================================================
    % This data is stored in a cell array of structs for easy modification.
    questionnaireData = {
        struct(...
            'question', 'Question 2: Do you find the task difficult?', ...
            'answerOptions', {{'Yes, most of the time', 'Yes, sometimes', 'No, not at all'}}, ...
            'percentageValues', [27, 73, 0] ...
        ), ...
        struct(...
            'question', 'Question 3: How confident are you about your answers?', ...
            'answerOptions', {{'Not confident at all', 'Slightly confident', 'Somewhat confident', 'Fairly confident', 'Completely confident'}}, ...
            'percentageValues', [14, 9, 36, 41, 0] ...
        ), ...
        struct(...
            'question', 'Question 4: How would you describe the direction of the PAE?', ...
            'answerOptions', {{...
                'PAE appears on the left when moving eyes from left to right', ...
                'PAE appears on the right when moving eyes from left to right', ...
                'PAE appears on the left when moving eyes from right to left', ...
                'PAE appears on the right when moving eyes from right to left', ...
                'I don''t know' ...
                }}, ...
            'percentageValues', [30, 21, 18, 21, 9] ...
        ), ...
        struct(...
            'question', 'Question 5: Was moving your eyes more easier in one direction?', ...
            'answerOptions', {{'Yes, moving from left to right was easier', 'Yes, moving from right to left was easier', 'No difference'}}, ...
            'percentageValues', [45, 14, 41] ...
        ) ...
    };
    
    % 3. CREATE THE FIGURE
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    ax = gca;
    hold(ax, 'on');

    % 4. DRAW THE CUSTOM PLOT ELEMENTS
    % ======================================================
    % --- Draw the Top X-Axis ---
    yAxisPosition = 1.0;
    plot(ax, [0, 100], [yAxisPosition, yAxisPosition], 'k-', 'LineWidth', lineWidth);
    for i = 0:10:100
        plot(ax, [i, i], [yAxisPosition, yAxisPosition - 0.2], 'k-', 'LineWidth', lineWidth);
        text(ax, i, yAxisPosition + 0.6, num2str(i), 'HorizontalAlignment', 'center', 'FontName', fontName, 'FontSize', axisTickFontSize);
    end
    text(ax, 50, yAxisPosition + 2, 'Percentage (%)', 'HorizontalAlignment', 'center', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'FontWeight', 'bold');
    
    % --- Main Loop to Draw Each Question ---
    yCurrent = 0;
    for q = 1:length(questionnaireData)
        yCurrent = yCurrent + yStepQuestion;
        
        text(ax, xAnswerLabel, yCurrent, questionnaireData{q}.question, 'FontSize', axisLabelFontSize, 'FontName', fontName, 'FontWeight', 'bold', 'VerticalAlignment', 'bottom');
        
        for a = 1:length(questionnaireData{q}.answerOptions)
            yCurrent = yCurrent + yStepAnswer;
            percentValue = questionnaireData{q}.percentageValues(a);
            
            text(ax, xPercentLabel, yCurrent, num2str(percentValue), 'HorizontalAlignment', 'right', 'FontName', fontName, 'FontSize', axisTickFontSize);

            if percentValue > 0
                rectangle(ax, 'Position', [0, yCurrent - barHeight/2, percentValue, barHeight], ...
                          'FaceColor', barFillColor, 'EdgeColor', barEdgeColor, 'FaceAlpha', barAlpha);
            end
            
            answerText = questionnaireData{q}.answerOptions{a};
            text(ax, xAnswerLabel, yCurrent, answerText, 'HorizontalAlignment', 'left', 'FontName', fontName, 'FontSize', axisTickFontSize, 'VerticalAlignment', 'middle');
        end
    end
    
    % --- Draw the Vertical Axis Line ---
    plot(ax, [0, 0], [yAxisPosition, yCurrent - barHeight], 'k-', 'LineWidth', lineWidth);
    
    % 5. FINALIZE THE PLOT
    % ===========================================================
    hold(ax, 'off');
    axis(ax, 'off');
    xlim(ax, [xPercentLabel - 10, 102]);
    ylim(ax, [yCurrent - 2, yAxisPosition + 3]);
    set(ax, 'FontName', fontName);

    % 6. SAVE THE FIGURE
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
    
    close(figureHandle);
end