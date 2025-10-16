%% Main script to reproduce all figures from the paper "Measuring the temporal contrast sensitivity function of the phantom array effect"
% Title
% Measuring the temporal contrast sensitivity function of the phantom array effect
% Journal
% Lighting Research & Technology
% DOI
% 10.1177/14771535251379686
%
% Programmer
% Xiangzhen Kong (x.kong@tue.nl)
%


clear; close all; clc;

fprintf('Running the preprocessing scripts first!...\n');
fprintf('Setting up paths...\n');
addpath(genpath('src'));

fprintf('Executing computeVisibilityThresholds.m ...\n');
computeVisibilityThresholds

fprintf('Executing computeIndividualFits.m ...\n');
computeIndividualFits

fprintf('Executing createLiteratureDataset.m ...\n');
createLiteratureDataset

fprintf('Generating Figure 2...\n');
plotFigure2;

fprintf('Generating Figure 3...\n');
plotFigure3;

fprintf('Generating Figure 4...\n');
plotFigure4;

fprintf('Generating Figure 5...\n');
plotFigure5;

fprintf('Generating Figure 6...\n');
plotFigure6;

fprintf('Generating Figure 7...\n');
plotFigure7;

fprintf('Generating Figure 8...\n');
plotFigure8;

fprintf('Generating Figure 9...\n');
plotFigure9;

fprintf('Generating Figure 10a...\n');
plotFigure10a;

fprintf('Generating Figure 10b...\n');
plotFigure10b;

fprintf('\nAll figures have been generated and saved in the /output folder.\n');

fprintf('Generating animations for Participant 17...\n');
buildTcsfAnimation(17);

fprintf('Generating animations for Participant 09...\n');
buildTcsfAnimation(9);

close all