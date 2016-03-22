dataManager = Data.DataManager('episodes');
dataManager.addDataEntry('states', 1, -ones(1,1), ones(1,1));
dataManager.addDataEntry('actions', 1, -ones(1,1), ones(1,1));

maxfeatures = 100;
k1 = Kernels.ExponentialQuadraticKernel(dataManager, 1, 'stateKernel');
k2 = Kernels.ExponentialQuadraticKernel(dataManager, 1, 'actionKernel');

s = sort(rand(100,1)*2*pi);

d1 = sin(s);
d2 = cos(s);

g1 = k1.getGramMatrix( d1, d1);
g2 = k2.getGramMatrix( d2, d2);

k = Kernels.ProductKernel(dataManager, 2, {k1,k2}, {[1], [2]}, 'stateActionKernel');
g = k.getGramMatrix([d1,d2],[d1,d2]);
figure;
subplot(1,3,1)
imagesc(g1)
subplot(1,3,2)
imagesc(g2)
subplot(1,3,3)
imagesc(g)


featureGenerator = Kernels.KernelBasedFeatureGenerator(dataManager, k, {'states', 'actions'});

kernelReferenceSetLearner = Kernels.Learner.RandomKernelReferenceSetLearner(dataManager, featureGenerator);
kernelBandWidthLearner = Kernels.Learner.MedianBandwidthSelector(dataManager, k, kernelReferenceSetLearner, featureGenerator);

data = dataManager.getDataObject(100);
data.setDataEntry('states', d1);
data.setDataEntry('actions', d2);

kernelReferenceSetLearner.updateModel(data);
kernelBandWidthLearner.updateModel(data);

data.getDataEntry('stateActionKernelStatesActions')
