clear variables;
close all;

state_bandwidth_factor = 1;
Filter.test.preludes.pendulumWindowsGkkf;

%%
i = 30;
Y = testData.getDataEntry('thetaNoisy',i);
Yw = testData.getDataEntry('thetaNoisyWindows',i);
valid = testData.getDataEntry('thetaNoisyWindowsValid',i);

Y = Y(logical(valid),:);
Yw = Yw(logical(valid),:);

%%
% m = cell(1,30);
% mt = cell(1,30);
% Y_out = cell(1,30);
% Yt_out = cell(1,30);

Loo = gkkfLearner.filter.Koo + gkkfLearner.observationModelLearner.lambdaO * eye(kernel_size);
Ko2 = gkkfLearner.filter.Ko2;
K22 = gkkfLearner.filter.getKernelVectors2(gkkfLearner.filter.data2);


m = (K22 + gkkfLearner.transitionModelLearner.lambdaT *eye(kernel_size)) \ gkkfLearner.filter.getKernelVectors2(Yw);

S = gkkfLearner.filter.initialCov;

d = gkkfLearner.filter.obsKernelReferenceSet.getKernelVectors(Y) - gkkfLearner.filter.G * (Loo \ Ko2) * m;
Q = (Ko2' / Loo) / ...
    (gkkfLearner.filter.G * (Loo \ Ko2) * S * (Ko2' / Loo) + gkkfLearner.observationModelLearner.kappa * eye(kernel_size));
m = m + S * Q * d;
S = S - S * Q * gkkfLearner.filter.G * (Loo \ Ko2) * S;

Y_out = gkkfLearner.filter.outputTransformation(m);
plot(1:length(Y_out),Y_out(1,:)'); hold on; plot(Yw(:,obs_ind),'r');
