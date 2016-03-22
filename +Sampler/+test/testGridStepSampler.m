clear variables;
close all;

% grid as one episode with many steps
%

%create data managers with 3 hierarchical layers (episodes, steps,
%subSteps)
dataManager = Data.DataManager('episodes');
subdataManager = Data.DataManager('steps');
dataManager.setSubDataManager(subdataManager);

env = Sampler.test.EnvironmentSequentialTest(subdataManager, subdataManager);

dataManager.setRange('states', zeros(1,4), ones(1,4));
dataManager.setRange('actions', -ones(1,2), ones(1,2));
initSampler = Sampler.StateActionGridSampler(subdataManager,  [2,2,2,2,2,2]);
stepSampler = Sampler.GridStepSampler(subdataManager, [2,2,2,2,2,2]);


stepSampler.setTransitionFunction(env, 'sampleNextState');
stepSampler.setRewardFunction(env, 'sampleReward');
stepSampler.setInitStateActionSampler( initSampler,'sampleInitStateAction');

sampler = Sampler.EpisodeSampler(dataManager);
sampler.addSamplerFunction('Episodes', 'steps', stepSampler); 

%sampler = Sampler.EpisodeWithStepsSampler(dataManager);
%sampler.setStepSampler(stepSampler)

sampler.numSamples = 1;
%stepSampler.numSamples = 64;

dataManager = sampler.getDataManagerForSampler();

newData = dataManager.getDataObject(0);
sampler.createSamples(newData);
%dataManager.finalizeDataManager();

%myData = dataManager.getDataObject(800);
sa = newData.getDataEntry('stateactions');
ns = newData.getDataEntry('nextStates');
r = newData.getDataEntry('rewards');
res = [sa, ns, r]


