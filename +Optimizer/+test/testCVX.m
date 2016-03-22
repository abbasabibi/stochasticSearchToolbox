% Using predefined data
load('HiREPSPendulumData.mat');

% using different solver
cvx_solver sedumi

% Values taken form example
epsilonAction=0.5;
eta = 0.3371;

%features.numPerTimeStep = 10;
%features.psi = features.psi(1:10, :);
%features.phi = features.phi(1:10, :);
%features.meanInit = features.meanInit(:, 1:10);

tic;
cvx_begin
    variable theta(features.numPerTimeStep);
    minimize(features.meanInit * theta +  sum(Optimizer.test.maxAdvantage(theta, features, reward, responsibilities, weighting)+eta.*(epsilonAction ...
                -log(sum(weighting,2))+log(Optimizer.test.advantage(theta, features, reward, responsibilities, weighting)))) + obj.repsRegularizationTheta * (theta' *theta)  )

%   minimize(features.meanInit * theta + eta * log_sum_exp((reward + theta' * (features.psi - features.phi) ) / eta  - log(300)));

%    subject to       
%        theta <= 1e12 * ones(size(theta))
%        theta >= -1e12 * ones(size(theta))
cvx_end
toc;

% Output using sum()/300

% CVX Warning:
%    Models involving "log" or other functions in the log, exp, and entropy
%    family are solved using an experimental successive approximation method.
%    This method is slower and less reliable than the method CVX employs for
%    other models. Please see the section of the user's guide entitled
%        The successive approximation method
%    for more details about the approach, and for instructions on how to
%    suppress this warning message in the future.
% 
% ans =
% 
%      1
% 
% 
% ans =
% 
%      1
% 
%  
% Successive approximation method to be employed.
%    For improved efficiency, SDPT3 is solving the dual problem.
%    SDPT3 will be called several times to refine the solution.
%    Original size: 2348 variables, 653 equality constraints
%    349 exponentials add 2792 variables, 1745 equality constraints
% -----------------------------------------------------------------
%  Cones  |             Errors              |
% Mov/Act | Centering  Exp cone   Poly cone | Status
% --------+---------------------------------+---------
%   0/165 | 3.500e+00  1.379e-08  1.379e-08 | Failed
%   0/165 | 1.750e+00  1.379e-08  0.000e+00 | Failed
%   0/165 | 8.750e-01  1.379e-08  0.000e+00 | Failed
% -----------------------------------------------------------------
% Status: Failed
% Optimal value (cvx_optval): NaN



