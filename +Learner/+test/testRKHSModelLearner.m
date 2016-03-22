clear variables;
close all;

dataManager = Data.DataManager('steps');

dataManager.addDataEntry('states', 1);
dataManager.addDataEntry('actions', 1);
dataManager.addDataEntry('nextStates', 1);

c = Common.Settings();   
c.setProperty('modelLambda', 1e-3); 
c.setProperty('stateParams', [1 1]); 
c.setProperty('actionParams', [1 1]);
        
%removeDuplicates = false;
%sekernel = @FeatureGenerators.Kernels.sq_exp_kernel;
%seprodkernel = @(s1,a1,s2,a2,bw) FeatureGenerators.Kernels.product_kernels(sekernel, sekernel, s1,a1,s2,a2,bw);

maxFeat = 300;

skernel = FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
    dataManager, {'states'}, ':', maxFeat );
spkernel = FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
    dataManager, {'nextStates'}, ':', maxFeat );
skernel2 = FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
    dataManager, {'states'}, ':', maxFeat );
akernel2 = FeatureGenerators.Kernel.ExponentialQuadraticKernel( ...
    dataManager, {'actions'}, ':', maxFeat );
sakernel = FeatureGenerators.Kernel.ProductKernel( ...
                dataManager, {'states', 'actions'}, ':', maxFeat, ...
                {skernel2, akernel2}, {1, 2});

%sakernelFeatures = FeatureGenerators.KernelStateActionFeatures(seprodkernel, removeDuplicates, maxFeat, dataManager, {'states','actions'}, 2);
rkhslearner = Learner.ModelLearner.RKHSModelLearner(dataManager, :,skernel,skernel, sakernel);

dataManager.finalizeDataManager();
skernel.initObject();
spkernel.initObject();
sakernel.initObject();
rkhslearner.initObject();

newData = dataManager.getDataObject(100);

s = sort(randn(100,1));
a = randn(100,1);
sp = randn(100,1);

newData.setDataEntry('states', s);
newData.setDataEntry('actions', a);
newData.setDataEntry('nextStates', sp);


skernel.updateModel(newData)
sakernel.updateModel(newData)
spkernel.updateModel(newData)
%nskernelFeatures.updateModel(newData)
rkhslearner.updateModel(newData)
phi = newData.getDataEntry('statesExpQuadKernel');
psi = newData.getDataEntry('statesactionsProdKernelstatesExpQuadKernelExpNextFeat');
true