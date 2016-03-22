clear 
addpath('/home/gneumann/test/nlopt_build');
addpath('~/policysearchtoolbox/NLopt/');
load('+Optimizer/+test/HiREPSPendulumData.mat');

%opt.algorithm = NLOPT_LD_MMA;
opt.algorithm = NLOPT_LD_LBFGS;
%opt.algorithm = NLOPT_LD_SLSQP;
%opt.lower_bounds = [zeros(300,1), ones(300,1)*inf]
g = @(theta) f(theta');
opt.min_objective = g;
opt.maxeval = 1000;

%opt.min_objective = f;
%opt.fc = { (@(x) myconstraint(x,2,0)), (@(x) myconstraint(x,-1,1)) }
%opt.fc_tol = [ones(300,1)*1e-8, ones(300,1)*1e-8];
%opt.xtol_abs = ones(300,1)*1e-4;
opt.xtol_rel = 1e-4;
opt.verbose = 0;

tic;
[xopt, fmin, retcode] = nlopt_optimize(opt, zeros(300,1))
toc;