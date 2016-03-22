clear

% load data
load('HiREPSPendulumData.mat')

paramDim =300;

% get global settings
settings = Common.Settings();

settings.setProperty('OptibPrint', 1);
settings.setProperty('OptiMaxEval', 1000);
settings.setProperty('OptiAbsfTol', 10e-5);% DOES NOT WORK AS EXPECTED WITH FMINUNC


% create optimizer 

optimizer = Optimizer.Optimizer();



% Should try CMA-ES
[params1,val1] = optimizer.optimize(f,paramDim)


% FMinUnc Call
[params2,val2] = optimizer.optimize(f,paramDim,'FMinUnc');

% NLOPT_LD_MMA
[params3,val3] = optimizer.optimize(f,paramDim,'NLOPT_LD_MMA');
