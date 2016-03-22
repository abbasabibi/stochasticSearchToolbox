dataManager = Data.DataManager('episodes');
dataManager.addDataEntry('states', 1, -ones(1,1), ones(1,1));
dataManager.addDataEntry('actions', 1, -ones(1,1), ones(1,1));

maxfeatures = 100;
k1 = FeatureGenerators.Kernel.ExponentialQuadraticKernel(dataManager, {'states'}, ':', maxfeatures);
k2 = FeatureGenerators.Kernel.ExponentialQuadraticKernel(dataManager, {'actions'}, ':', maxfeatures);



return
s = sort(rand(100,1)*2*pi);

d1 = sin(s);
d2 = cos(s);

g1 = k1.getGramMatrix( d1, d1);
g2 = k2.getGramMatrix( d2, d2);

k = FeatureGenerators.Kernel.ProductKernel(dataManager, {'states'}, ':', maxfeatures, {k1,k2});
g = k.getGramMatrix({d1,d2},{d1,d2});
figure;
subplot(1,3,1)
imagesc(g1)
subplot(1,3,2)
imagesc(g2)
subplot(1,3,3)
imagesc(g)

