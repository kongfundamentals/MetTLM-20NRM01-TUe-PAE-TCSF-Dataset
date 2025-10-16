%% function buildTcsfAnimation
%
% Description:
%   Generates an animated GIF that provides a dynamic, trial-by-trial
%   visualization of the psychophysical experiment. The animation shows the
%   staircase procedure and the evolving psychometric function (PF) for each
%   of the 10 tested temporal frequencies. It also shows the overall Temporal
%   Contrast Sensitivity Function (TCSF) being derived in real-time from
%   the fitted PF thresholds.
%
% Note: This script is for illustrative purposes and is not required to
%       reproduce the static figures in the paper. It is intended to
%       provide a clear visual explanation of the QUEST+ adaptive method.
%
% Inputs:
%   - participantId (optional): The ID of the participant to animate.
%     If not provided, defaults to a representative participant (e.g., 17).
%     Example: buildTcsfAnimation(5)
%   - Reads curated data from: '../data/rawData/participantXX.mat'
%
% Outputs:
%   - Saves an animated GIF to a dedicated subfolder:
%     '../output/illustrations/tcsfAnimation_pXX.gif'
%
%
% Programmer:
%   Xiangzhen Kong (x.kong@tue.nl)
%
% Last updated:
%   October-17-2025
%

function buildTcsfAnimation(participantId)
    % 0. SETUP FOLDER AND FILE PATHS
    % ===================================================================
    [projectRoot, ~, ~] = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(fileparts(projectRoot));
    addpath(fullfile(projectRoot, 'src', 'utils'));
    addpath(genpath(fullfile(projectRoot, 'external', 'mQUESTPlus')));
    
    % 1. SETUP PARAMETERS
    % ===================================================================
    if nargin < 1
        participantId = 17;
    end
    
    finalWidthInches    = 3.5 * 4;
    finalHeightInches   = 3.5 * 2;
    fontName            = 'Arial';
    axisLabelFontSize   = 14;
    axisTickFontSize    = 10;
    lineWidth           = 1;
    markerSizeTrialData = 6;
    markerSizeTcsf      = 10;
    frameDelay          = 0.05;
    finalFrameDelay     = 5;
    
    
    frequencyList = [80, 160, 200, 300, 400, 600, 900, 1000, 1200, 1800];
    TOTAL_TRIALS  = 300;
    
    % Parameter to control when the TCSF plot starts updating.
    % It only makes sense to generate the TCSF plot after at least 4 trials 
    % (4 data points).
    startTcsfPlotAfterTrial = 4;
    
    % 2. LOAD DATA
    % ======================================================
    rawDataPath = fullfile(projectRoot, 'data', 'rawData', sprintf('participant%02d.mat', participantId));
    if ~exist(rawDataPath, 'file')
        error('Data file for participant %d not found.', participantId);
    end
    data = load(rawDataPath);
    
    % 3. CREATE FIGURE AND DYNAMIC LAYOUT
    % ======================================================
    figureHandle = figure('Units', 'inches', 'Position', [1, 1, finalWidthInches, finalHeightInches], 'Color', 'w');
    
    % Define layout parameters (Control Panel) 
    % Margins (space around the very edge of the figure)
    margin.left   = 0.04;
    margin.right  = 0.04;
    margin.bottom = 0.08;
    margin.top    = 0.08; 

    % Gap between the left and right panels
    horizontalGap = 0.01;

    % Relative width of the two main panels (must sum to 1)
    % Left panel gets 45% of the available space
    % Right panel gets 45%
    panelWidthRatio.left  = 0.55; 
    panelWidthRatio.right = 1 - panelWidthRatio.left; 

    % Calculate the Final Panel Positions
    % Total available space for the panels to live in
    availableWidth = 1.0 - margin.left - margin.right - horizontalGap;
    availableHeight = 1.0 - margin.bottom - margin.top;

    % Calculate the absolute width of each panel
    leftPanel.width = availableWidth * panelWidthRatio.left;
    rightPanel.width = availableWidth * panelWidthRatio.right;

    % Calculate the absolute position of each panel
    leftPanel.left = margin.left;
    rightPanel.left = leftPanel.left + leftPanel.width + horizontalGap;
    panelBottom = margin.bottom;
    panelHeight = availableHeight;
    
    % Left Panel for the 5x4 psychometric grid
    leftPanelHandle = uipanel('Parent', figureHandle, ...
        'Position', [leftPanel.left, panelBottom, leftPanel.width, panelHeight], ...
        'BorderType', 'none', 'BackgroundColor', 'w');
    
    % Right Panel for the summary TCSF plot
    rightPanelHandle = uipanel('Parent', figureHandle, ...
        'Position', [rightPanel.left, panelBottom, rightPanel.width, panelHeight], ...
        'BorderType', 'none', 'BackgroundColor', 'w');
    
    % Create the Tiled Layout INSIDE the Left Panel
    psychometricLayout = tiledlayout(leftPanelHandle, 4, 5, 'TileSpacing', 'compact', 'Padding', 'compact');
    axPsychometric = gobjects(20, 1);
    for i = 1 : 20
        axPsychometric(i) = nexttile(psychometricLayout);
        hold(axPsychometric(i), 'on');
        % title(num2str(i));
        %Some special care to make the figure fixed
        if i <= 5
            tempFrequency = i;
            text(axPsychometric(i), 10, -40, ['{\bf' sprintf('%d', frequencyList(tempFrequency)) '}' 'Hz'], 'FontName', fontName, 'FontSize', axisLabelFontSize, 'Interpreter', 'tex');
            plot(1:30, linear2Log(0));
            plot(0, linear2Log(1));
            xlim([0 32]);
            xticks([1 15 30]);
            ylim(linear2Log([0.005 0.95]));
            box on;
        end
        if i > 5 && i <= 10
            tempFrequency = i - 5;
            text(axPsychometric(i), -32, 0.12, ['{\bf' sprintf('%d', frequencyList(tempFrequency)) '}' 'Hz'], 'FontName', fontName, 'FontSize', axisLabelFontSize, 'Interpreter', 'tex');
            xlim([linear2Log(0.005) linear2Log(1)]);
            ylim([0 1]);
            box on;
        end
        if i > 10 && i <= 15
            tempFrequency = i - 5;
            text(axPsychometric(i), 10, -40, ['{\bf' sprintf('%d', frequencyList(tempFrequency)) '}' 'Hz'], 'FontName', fontName, 'FontSize', axisLabelFontSize, 'Interpreter', 'tex');
            plot(1:30, linear2Log(0));
            plot(0, linear2Log(1));
            xlim([0 32]);
            xticks([1 15 30]);
            ylim(linear2Log([0.005 0.95]));
            box on;
        end
        if i > 15 && i <= 20
            tempFrequency = i - 10;
            text(axPsychometric(i), -32, 0.12, ['{\bf' sprintf('%d', frequencyList(tempFrequency)) '}' 'Hz'], 'FontName', fontName, 'FontSize', axisLabelFontSize, 'Interpreter', 'tex');
            xlim([linear2Log(0.005) linear2Log(1)]);
            ylim([0 1]);
            box on;
        end
        
        hold(axPsychometric(i), 'off');
    end
    
    % Create the Single Axes INSIDE the Right Panel
    % axTcsf = axes('Parent', rightPanelHandle, 'Units', 'normalized', 'Position', [0.15 0.1 0.75 0.8]);
    axTcsf = subplot(1, 1, 1, 'Parent', rightPanelHandle);
    box(axTcsf, 'on');
    % Format the main TCSF plot
    % Add participant ID text to the plot
    % text(axTcsf, log10(80), 2, ['PID: ' '{\bf' sprintf('%02d', participantId) '}'], 'FontName', fontName, 'FontSize', axisLabelFontSize + 2, 'Interpreter', 'tex');



    % --- Format RIGHT Y-Axis ---
    yyaxis(axTcsf, 'right');
    set(axTcsf, 'YTick',   [0.001,   0.005,   0.01,   0.02,   0.03,   0.04,   0.05,   0.1,   0.2,   0.3,   0.4,   0.5,   1], ...
        'YTickLabel', {'0.001', '0.005', '0.01', '0.02', '0.03', '0.04', '0.05', '0.1', '0.2', '0.3', '0.4', '0.5', '1'}, ...
        'YLim', [1/10^2.5, 1/10^0], ...
        'YScale', 'log', 'YDir', 'reverse', 'YColor', 'k', ...
        'FontName', fontName, 'FontSize', axisTickFontSize);
    ylabel(axTcsf, 'Modulation Depth Visibility Threshold', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    
    % --- Format LEFT Y-Axis ---
    yyaxis(axTcsf, 'left');
    ylabel(axTcsf, 'log_{10}(\it{S})', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
    ylim(axTcsf, [0 2.5]);
    yticks(axTcsf, 0:0.5:2.5);
    set(axTcsf, 'YColor', 'k');
    
    xlim(axTcsf, [log10(70), log10(2000)]);
    xticks(axTcsf, log10(frequencyList([1 2 4 6 7 10])));
    xticklabels(axTcsf, {'80', '160', '300', '600', '900', '1800'});
    xtickangle(axTcsf, 60);
    xlabel(axTcsf, 'Temporal Frequency (Hz)', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold'); 
    

    % 4. MAIN LOOP: BUILD THE ANIMATION
    % ======================================================
    fprintf('Generating the TCSF animation for Participant %d...\n', participantId);
    outputFolder = fullfile(projectRoot, 'output', 'illustrations');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    outputGifFile = fullfile(outputFolder, sprintf('tcsfAnimation_p%02d.gif', participantId));
    numberOfTrialsVisualizedPerFrequency = zeros(1, 10);
    currentThresholdPerFrequency = NaN(1, 10);
    
    for trialNum = 1 : TOTAL_TRIALS
        % 1: Check for each of the frequency, the number of trials for that frequency;
        % 2: Update the visualization and fit for subplot;
        % 3: Update the fit for the TCSF (but only after a certain number of trials).
        
        frequencyIndex = data.whichQuestPlusOrder(trialNum);
        questVarName = sprintf('questDataFrequency%d', frequencyIndex);
        questData = data.(questVarName);
        modulationDetphInDb = cell2mat({questData.trialData.stim});
        outcome = cell2mat({questData.trialData.outcome});
        
        nTrials = []; pCorrect = [];
        SLOPE = 3; GUESSRATE = 0.5; LAPSE = 0.02;
    
        numberOfTrialsVisualizedPerFrequency(frequencyIndex) = numberOfTrialsVisualizedPerFrequency(frequencyIndex) + 1;
        numberofTrialsThisFrequency = numberOfTrialsVisualizedPerFrequency(frequencyIndex);
    
        % Trial Data Plots:
        % Frequencies 1 - 5 go into tiles 1, 2, 3, 4, 5 (the first row).
        % Frequencies 6 - 10 go into tiles 11, 12, 13, 14, 15 (the third row).
        % Psychometric Function (PF) Plots:
        % PFs for Frequencies 1 - 5 go into tiles 6, 7, 8, 9, 10 (the second row).
        % PFs for Frequencies 6 - 10 go into tiles 16, 17, 18, 19, 20 (the fourth row).
        if frequencyIndex <= 5
            trialDataAxisIndex = frequencyIndex;
            pfAxisIndex = frequencyIndex + 5;
        else
            trialDataAxisIndex = frequencyIndex + 5;
            pfAxisIndex = frequencyIndex + 10;
        end
        
        %%
        psiParamsIndex = qpListMaxArg(questData.posterior);
        psiParamsQuest = questData.psiParamsDomain(psiParamsIndex,:);
        psiParamsFit = qpFit(questData.trialData(1 : numberofTrialsThisFrequency), questData.qpPF, psiParamsQuest, questData.nOutcomes,...
            'lowerBounds',  [linear2Log(data.modulationDepthInPercentageMIN) SLOPE(1)      GUESSRATE LAPSE],...
            'upperBounds',  [linear2Log(data.modulationDepthInPercentageMAX) SLOPE(end)    GUESSRATE LAPSE]);
        stimCounts = qpCounts(qpData(questData.trialData), questData.nOutcomes);
        stim = [stimCounts.stim];
        stimFine = linspace(linear2Log(data.modulationDepthInPercentageMIN), linear2Log(data.modulationDepthInPercentageMAX), 100)';
        
        plotProportionsFit = qpPFWeibull(stimFine, psiParamsFit);
        for stimuliIndex = 1 : length(stimCounts)
            nTrials(stimuliIndex) = sum(stimCounts(stimuliIndex).outcomeCounts);
            pCorrect(stimuliIndex) = stimCounts(stimuliIndex).outcomeCounts(2)/nTrials(stimuliIndex);
        end

        maxTrials = max(nTrials);
        if maxTrials == 0, maxTrials = 1; end % Avoid division by zero

        %% Update the trial data plot
        ax = axPsychometric(trialDataAxisIndex);
        hold(ax, 'on');
        if outcome(numberofTrialsThisFrequency) == 2
            plot(ax, numberofTrialsThisFrequency, modulationDetphInDb(numberofTrialsThisFrequency), 'o', 'MarkerFaceColor', [74 163 49]./255, 'MarkerEdgeColor', [1 1 1], 'MarkerSize', markerSizeTrialData);
        else
            plot(ax, numberofTrialsThisFrequency, modulationDetphInDb(numberofTrialsThisFrequency), 's', 'MarkerFaceColor', [170 32 22]./255, 'MarkerEdgeColor', [1 1 1], 'MarkerSize', markerSizeTrialData);
        end
        
        %% Update the psychometric function plot
        ax = axPsychometric(pfAxisIndex);
        hold(ax, 'on');
        plot(ax, stimFine, plotProportionsFit(:, 2), '-', 'Color', [0 0 0], 'LineWidth', lineWidth);
        
        if numberofTrialsThisFrequency == 30
            for stimuliIndex = 1 : length(stimCounts)
                scatter(ax, stim(stimuliIndex), pCorrect(stimuliIndex), markerSizeTcsf, 'o', 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0 0 0],...
                    'MarkerFaceAlpha', nTrials(stimuliIndex)/maxTrials, 'MarkerEdgeAlpha', nTrials(stimuliIndex)/maxTrials);
            end
            finalThresholdHandleY = yline(0.75);
            set(finalThresholdHandleY, 'LineStyle', '-', 'LineWidth', lineWidth * 2, 'Color', [0 0 0]);
        end

        outputThreshold = log2Linear(psiParamsFit(1));
        currentThresholdPerFrequency(frequencyIndex) = outputThreshold;
        %title(['Threshold = ' num2str(outputThreshold)]);
        
        %title(ax, sprintf('Trial No. %d)', numberofTrialsThisFrequency), 'FontSize', axisLabelFontSize);
        %frequencyList(frequencyIndex), 
    
        % --- Update the main TCSF plot on the right ---
        if trialNum >= startTcsfPlotAfterTrial
            % Find indices of frequencies that have data
            validDataIndex = ~isnan(currentThresholdPerFrequency);
    
            if sum(validDataIndex) >= 4 % We need at least 4 points to fit a 3rd-order poly
                xData = log10(frequencyList(validDataIndex));
                logSensitivity = log10(1 ./ currentThresholdPerFrequency(validDataIndex));
    
                % Fit the TCSF curve with the data available so far
                fitObject = fit(xData', logSensitivity', 'poly3');
                xFit = linspace(log10(min(frequencyList)), log10(max(frequencyList)), 100);
                yFit = feval(fitObject, xFit);
                try
                    confidenceIntervals = predint(fitObject, xFit, 0.95, 'Functional');
                    fill(axTcsf, [xFit, fliplr(xFit)], [confidenceIntervals(:, 2)', fliplr(confidenceIntervals(:, 1)')], ...
                        'k', 'FaceAlpha', 0.1, 'LineStyle', 'none');
                catch
                    fprintf('Skipping 95%%CI on trial %d\n', trialNum);
                end
                hold(axTcsf, 'on');
                plot(axTcsf, xFit, yFit, '-', 'LineWidth', lineWidth * 3, 'Color', [0.98, 0.40, 0.35]);
                plot(axTcsf, xData, logSensitivity, 'ko', 'LineWidth', lineWidth, 'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerEdgeColor', [0.3 0.3 0.3], 'MarkerSize', markerSizeTcsf);
                hold(axTcsf, 'off');
                % --- Format LEFT Y-Axis ---
                yyaxis(axTcsf, 'left');
                ylabel(axTcsf, 'log_{10}(\it{S})', 'FontSize', axisLabelFontSize, 'FontName', fontName, 'Interpreter', 'tex', 'FontWeight', 'bold');
                ylim(axTcsf, [0 2.5]);
                yticks(axTcsf, 0:0.5:2.5);
                set(axTcsf, 'YColor', 'k');
            end
        end
    
        % --- Update main title and capture frame ---
        titleString = sprintf('Measuring {\\bfTCSF} of the {\\bfPhantom Array Effect} for Participant {\\bf%02d}: Trial {\\bf%d}/{\\bf%d}', ...
                      participantId, trialNum, TOTAL_TRIALS);

        % Update the super title on the figure.
        sgtitle(figureHandle, titleString, 'FontSize', axisLabelFontSize + 2, 'Interpreter', 'tex');
        drawnow;
    
        frame = getframe(figureHandle);
        [A, map] = rgb2ind(frame.cdata, 256);
    
        if trialNum == 1
            imwrite(A, map, outputGifFile, 'gif', 'LoopCount', Inf, 'DelayTime', 1);
        elseif trialNum == 300
            imwrite(A, map, outputGifFile, 'gif', 'WriteMode', 'append', 'DelayTime', finalFrameDelay);
        else
            imwrite(A, map, outputGifFile, 'gif', 'WriteMode', 'append', 'DelayTime', frameDelay);
        end
        if mod(trialNum, 10) == 0, fprintf('  > Frame %d captured.\n', trialNum); end
    end
    
    fprintf('\nAnimation complete! Saved to:\n%s\n', outputGifFile);
    close(figureHandle);
end