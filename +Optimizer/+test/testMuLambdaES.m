clear variables;
close all;

numParams = 15;

rewardFunctionMean = randn(numParams, 1);
rewardFunctionCovariance = randn(numParams);
rewardFunctionCovariance = rewardFunctionCovariance * rewardFunctionCovariance';

rewardFunction = @(params,u) (params - rewardFunctionMean)' * rewardFunctionCovariance * (params - rewardFunctionMean);

minParams = -ones(1, numParams) * 100;
maxParams = ones(1, numParams) * 100;


initMean = (maxParams - minParams) .* randn(1, numParams) + minParams;

optimizer = Optimizer.Mu_Lambda_ES(numParams, minParams, maxParams);

[paramsCMA, valCMA, numIterationsCMA] = optimizer.optimize(rewardFunction, initMean);