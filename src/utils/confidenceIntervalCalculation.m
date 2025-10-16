%% function confidenceIntervalCalculation
function [data_mean, ci95] = confidenceIntervalCalculation(data, alpha)

%%
%Remove NaN values
data_nan = data(~isnan(data));

%%
%Mean
data_mean = mean(data_nan);

%%
%Standard Error
s = std(data_nan);
%Number of elements in the data vector
n = length(data_nan); 
stdError= s / sqrt(n);

%%
%Confidence interval
T_multiplier = tinv(1 - alpha / 2, n - 1);
ci95 = T_multiplier * stdError;

% lowerBoundary = data_mean - ci95;
% upperBoundary = data_mean + ci95;

end