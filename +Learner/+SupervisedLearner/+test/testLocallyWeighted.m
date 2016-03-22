clear Test;

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', 1);
dataManager.addDataEntry('actions', 1);
dataManager.addDataEntry('weighting', 1);


s = repmat((1:8:100)',10,1);
s2 = (5:8:100)';
a = randn(size(s,1),1);
w = exp( -(a - sin(s/10)).^2  );

scatter(s,a,w*100,w)

newData = dataManager.getDataObject(size(s,1));
newData.setDataEntry('states', s);
newData.setDataEntry('actions', a);
newData.setDataEntry('weighting', w);



policy =  Learner.SupervisedLearner.LocallyWeightedPolicy(dataManager,...
    @FeatureGenerators.Kernels.sq_exp_kernel,'states','actions');
learner = Learner.SupervisedLearner.LocallyWeightedPolicyLearner(...
    dataManager, policy, 'weighting',  ...
    'states','actions');


learner.learnFunction( s, a, w);
[mean, sigma] = policy.getExpectationAndSigma(size(s2),s2);

hold on;
plot([s2,s2],[mean+sigma mean-sigma ])
hold off;
