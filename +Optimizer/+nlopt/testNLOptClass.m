clear 
addpath('/home/gneumann/test/nlopt_build');
addpath('~/policysearchtoolbox/NLopt/');
load('+Optimizer/+test/HiREPSPendulumData.mat');

numParams = 300;

settings = Common.Settings();

properties = {'maxNumOptiIterationsTestOptimizer'};
propertiesValues = {{10}, {100}, {200}, {500}, {1000}};

for i = 1:length(propertiesValues)
    settings.setProperties(properties, propertiesValues{i});
    
    optimizer = Optimizer.NLOptOptimizer(numParams, [], [], 'TestOptimizer');

    optimizer.printProperties();


    tic;
    [xopt, fval(i)] = optimizer.optimize(f, zeros(300,1));
    timeval(i) = toc;
    fprintf('FunctionValue: %f\n', fval(i));
end

figure;plot(timeval, fval);
