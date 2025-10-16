%% function plotFigure10b
%
% Description:
%   Generates and saves Figure 10b from the associated publication. This script
%   visualizes a subset of dataset presented in Figure 10a.
%
% Inputs:
%   - Reads all pre-analyzed data from: '../data/processedData/literatureAnalysisResults.mat'
%
% Outputs:
%   - Saves the figure to:          '../output/fig10b_twoColumn.emf'
%   - Also saves a PNG version to:  '../output/fig10b_twoColumn.png'
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function plotFigure10b
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(projectRoot);
    addpath(fullfile(projectRoot, 'src', 'utils'));

    % 1. SETUP PUBLICATION AND PLOTTING PARAMETERS
    % ===================================================================
    % --- Figure Style Parameters ---
    figureType        = 'twoColumn';
    finalWidthInches  = 7.2;
    finalHeightInches = 5.6;
    outputFileName    = 'fig10b';
    fontName          = 'Arial';
    axisLabelFontSize = 14;
    axisTickFontSize  = 10;
    lineWidth         = 1;
    markerSize        = 6;

    symbols = 'sopd><^+hvx.';                                          
    colors  = {[0 0 0]/255, [237 50 50]/255, [50 208 50]/255, [230 159 0]/255, [0 114 178]/255}; % Black, Red, Green, Orange, Blue
    
    % 2. LOAD PRE-COMPUTED ANALYSIS RESULTS
    % ======================================================
    analysisDataPath = fullfile(projectRoot, 'data', 'processedData', 'literatureAnalysisResults.mat');
    if ~exist(analysisDataPath, 'file')
        error('Analysis results file not found. Please run createLiteratureDataset.m first.');
    end
    data = load(analysisDataPath);
    litData = data.litData; % Unpack the struct
    frequencyList = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    % 3. CREATE THE FIGURE
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w', 'Renderer', 'Painters');
    ax = gca;
    hold(ax, 'on');

    % 4. PLOT ALL DATASETS
    % ======================================================
    % --- Current Study ---
    h(1) = plot(ax, litData.currentUserStudy.xData, litData.currentUserStudy.yData, symbols(1), 'MarkerSize', markerSize, 'MarkerEdgeColor', colors{1}, 'MarkerFaceColor', colors{1});
    plot(ax, litData.currentUserStudy.xFit, litData.currentUserStudy.yFit, '-', 'Color', colors{1}, 'LineWidth', lineWidth * 3);

    % --- CIE 249:2022 & Tan et al. 2024 ---
    h(2) = plot(ax, litData.cie2022_from_tan2024.xFit, litData.cie2022_from_tan2024.yFit, [symbols(2) '-'], 'MarkerSize', markerSize/2, 'MarkerEdgeColor', colors{1}, 'MarkerFaceColor', 'w', 'Color', colors{1});
    h(3) = plot(ax, litData.tan2024.xFit, litData.tan2024.yFit, [symbols(2) '-'], 'MarkerSize', markerSize/2, 'MarkerEdgeColor', colors{1}, 'MarkerFaceColor', colors{1}, 'Color', colors{1});

    % 5. FORMAT AXES, LEGEND, AND FINALIZE
    % ======================================================
    % --- Y-Axis Formatting (Dual Axis) ---
    yyaxis(ax, 'left');
    ylim(ax, [0 1.8]);
    set(ax, 'FontName', fontName, 'FontSize', axisTickFontSize);
    set(ax, 'YColor', 'k');
    ylabel(ax, 'log_{10}(\it{S})', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    
    yyaxis(ax, 'right');
    set(gca, ...
        'YTick',        [ 0.001    0.005     0.01    0.02    0.03    0.04    0.05     0.1    0.2     0.3     0.4     0.5     1], ...
        'YTickLabel',   {'0.001', '0.005',  '0.01', '0.02', '0.03', '0.04', '0.05',  '0.1', '0.2',  '0.3',  '0.4',  '0.5',  '1'}, ...
        'YLim',         [1/10^1.8 1/10^0], 'YScale', 'log', 'YDir', 'reverse', ...
        'YColor',       [0 0 0], ...
        'FontName', fontName);
    ylabel(ax, 'Modulation Depth Visibility Threshold', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');

    % --- X-Axis and General Formatting ---
    allFreqs = unique([frequencyList, 400, 1200, 2000, 3000, 4000, 5000, 100]);
    xticks(ax, log10(allFreqs));
    %xticklabels(ax, cellstr(num2str(allFreqs')));
    % To avoid crowded xticks, here the '900' and '1800' are omitted since they are too close to the neighboring labels 
    xticklabels(ax, {'80', '100', '160', '200', '300', '400', '600', ' ', '1000', '1200', ' ', '2000', '3000', '4000', '5000'});

    xtickangle(ax, 45);
    xlabel(ax, 'Temporal Frequency (Hz)', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    
    box(ax, 'on');
    hold(ax, 'off');

    % --- Legend ---
    legend(ax, h, ...
        {'Current study', '^{ 1} CIE 249:2022', '^{27} PAVM'}, ...
        'NumColumns', 1, 'Location', 'best', 'Box', 'off', ...
        'FontName', fontName, 'FontSize', axisTickFontSize, 'Interpreter', 'tex');
    
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