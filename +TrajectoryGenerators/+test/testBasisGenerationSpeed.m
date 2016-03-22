clear variables;
close all;
Common.clearClasses;


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));


environment = Sampler.test.EnvironmentSequentialTest(dataManager, dataManager.getSubDataManager());

sampler.setContextSampler(environment);
sampler.setActionPolicy(environment);
sampler.setTransitionFunction(environment);
sampler.setRewardFunction(environment);
sampler.setInitialStateSampler(environment);


settings = Common.Settings();
settings.setProperty('numBasis', 30);
settings.setProperty('numTimeSteps', 200);

phaseGenerator = TrajectoryGenerators.PhaseGenerators.PhaseGenerator(dataManager);
basisGenerator = TrajectoryGenerators.BasisFunctions.NormalizedGaussianBasisGenerator(dataManager,phaseGenerator);

% sampler.addParameterPolicy(phaseGenerator,'generatePhase');

sampler.addParameterPolicy(phaseGenerator,'generatePhaseD');
sampler.addParameterPolicy(phaseGenerator,'generatePhaseDD');

if 0 %does not work any more, change implemented in BasisGenerator interface
    sampler.addParameterPolicy(basisGenerator,'generateBasis');
else
    sampler.addParameterPolicy(basisGenerator,'generateBasis');
    sampler.addParameterPolicy(basisGenerator,'generateBasisD');
    sampler.addParameterPolicy(basisGenerator,'generateBasisDD');
end

dataManager.finalizeDataManager();


sampler.numSamples = 40;
sampler.setParallelSampling(true);

newData = dataManager.getDataObject(sampler.numSamples);


i=1:10;
t = zeros(i(end),1);
for i = i
    fprintf('Generating Data\n');
    tic
    sampler.createSamples(newData);
    t(i) = toc
end
t'

% Params 100 Basis, 1000 steps, 40 Episodes
% for monolithic 
% 8.8674    8.7738    8.7908    8.7911    8.7848    8.7956    8.8029    8.7660    8.7933    8.8103
% for the separate calculation 
% 9.1827    9.0994    9.0684    9.0490    9.0923    9.0459    9.0878    9.1319    9.1156    9.1356
% mean diff 0.3033

% Params 30 Basis, 1000 steps, 40 Episodes
% for monolithic 
% 8.7017    8.6392    8.6422    8.5923    8.6073    8.6374    8.6734    8.5890    8.5859    8.6793
% for the separate calculation 
% 8.8384    8.8672    8.8025    8.8526    8.7816    8.7822    8.8088    8.8006    8.7622    8.7811
% mean diff 0.1729

% Params 30 Basis, 200 steps, 40 Episodes
% for monolithic 
% 1.7692    1.6672    1.6631    1.6766    1.6821    1.6865    1.6783    1.6777    1.6788    1.6649
% for the separate calculation 
% 1.9307    1.8291    1.8332    1.8507    1.8392    1.8349    1.8311    1.8244    1.8353    1.8285
% mean diff 0.1593


%2.1193    2.0049    2.0104    2.0235    2.0517    2.0364    2.0179    2.0116    2.0136    2.0141