clear variables;
close all;
load('+Optimizer/+test/HiREPSPendulumData.mat');

optimizerTest = Optimizer.OptimizerTestClass([50, 100, 200, 500]);

optimizerTest.addAlgorithmToTest('FMinCon');
optimizerTest.addAlgorithmToTest('FMinUnc');
% additional properties can be set for the algorithms...
optimizerTest.addAlgorithmToTest('NLOPT_LD_LBFGS', 'OptiAbsfTol', 10^-12);
optimizerTest.addAlgorithmToTest('NLOPT_LD_MMA');
optimizerTest.addAlgorithmToTest('NLOPT_LD_SLSQP');
optimizerTest.addAlgorithmToTest('NLOPT_LD_TNEWTON_PRECOND_RESTART');
optimizerTest.addAlgorithmToTest('NLOPT_LD_TNEWTON_PRECOND');
optimizerTest.addAlgorithmToTest('NLOPT_LD_TNEWTON');
optimizerTest.addAlgorithmToTest('NLOPT_LD_VAR2');
optimizerTest.addAlgorithmToTest('NLOPT_LD_VAR1');


[times, values] = optimizerTest.testOptimizer(f, zeros(300,1));
figure;plot(times',values');
