clear variables;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In This testfile we run Optimizer.FMinUnc and Optimizer.CMAOptimizer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numParams = 15;

% creating random vector as mean
rewardFunctionMean = randn(numParams, 1);
% creating a regular matrix for the Covariance
rewardFunctionCovariance = randn(numParams);
rewardFunctionCovariance = rewardFunctionCovariance * rewardFunctionCovariance';

% anonymous function returns reward. Generally better reward closer to mean
rewardFunction = @(params) (params' - rewardFunctionMean)' * rewardFunctionCovariance * (params' - rewardFunctionMean);

% Parameter in [-1,1]
minParams = -ones(1, numParams) * 100;
maxParams = ones(1, numParams) * 100;

% starting Value
initMean = (maxParams - minParams) .* randn(1, numParams) + minParams;

% Using Optimizer.FMinUnc (uses matlabs fminunc internally)
% Settings: useGradient=false useHessian=false
optimizer = Optimizer.FMinUnc(numParams, false, false);

optimizer.setPrintIterations(true);
[params, val, numIterations] = optimizer.optimize(rewardFunction, initMean);

% Using Optimizer.CMAOptimizer
optimizer = Optimizer.CMAOptimizer(numParams, minParams, maxParams);

optimizer.setPrintIterations(true);
optimizer.maxNumOptiIterations = 1000;
optimizer.CMAOptimizerInitialRange = 0.001;

[paramsCMA, valCMA, numIterationsCMA] = optimizer.optimize(rewardFunction, initMean);