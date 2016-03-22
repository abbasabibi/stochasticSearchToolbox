clear variables;
close all;
Common.clearClasses;

settings = Common.Settings();
settings.setProperty('dt', 0.05);
settings.setProperty('numBasis', 201);
settings.setProperty('numTimeSteps', 200);
settings.setProperty('widthFactorBasis', 5.0);
settings.setProperty('Noise_std', 0.3);
settings.setProperty('numCentersOutsideRange', 0);
settings.setProperty('PGainsDistributionCorrection', [50, 40, 30, 20]*3);
settings.setProperty('DGainsDistributionCorrection', [3, 3, 3, 3]);
settings.setProperty('correctionTemperature', 2);
settings.setProperty('correctionThreshold', 30);
settings.setProperty('stochasticCtl', 1);


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));

dimObsState = 4;
dimCtls = 4;

environment = Environments.DynamicalSystems.QuadLink(sampler);
environment.friction = ones(1,4) * 5;

dataManager.setRange('actions',-1000*ones(1,dimObsState),1e1000*ones(1,dimObsState));
% dataManager.setRange('actions',-300*ones(1,dimObsState),300*ones(1,dimObsState));
dataManager.setRestrictToRange('actions', false);
environment.initObject();

sampler.setTransitionFunction(environment);

trajectoryGenerator = TrajectoryGenerators.ProMPsModelFree(dataManager, dimObsState, dimCtls);
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.minCov = 0.0;
distributionLearner.maxCorr = 1.0;

gainGenerator = TrajectoryGenerators.ProMPsModelFreeCtl(dataManager, trajectoryGenerator);
%gainGenerator = TrajectoryGenerators.TrajectoryTracker.LearnedLinearFeedbackController(dataManager, {'jointPositions', 'jointVelocities'}, 'actions', environment.dimAction);


trajectoryGenerator.initObject();

sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseD');
sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseDD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisDD');

%ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, dimCtls, gainGenerator);
ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearControllerDistributionCorrection(dataManager, trajectoryGenerator, dimCtls, gainGenerator);

sampler.setActionPolicy(ctrTraj);

imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner...
                      (dataManager, trajectoryGenerator, 'jointStateAction');
                  
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
                                (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
                         
imitationLearner.imitationLearningRegularization = 1e-10; 
                         
sampler.addParameterPolicy(gainGenerator,'updateModel');
sampler.addParameterPolicy(ctrTraj,'updateModel');

sampler.setInitialStateSampler(trajectoryGenerator);


subDataManager = dataManager.getSubDataManager();
subDataManager.addDataAlias('jointStateAction', 'states', 1:2:8);
subDataManager.addDataAlias('jointStateAction', 'actions');

dataManager.finalizeDataManager();

%%% From file
% load('+TrajectoryGenerators/+test/+ProMPs/im_data_opt_1k.mat'  )
% load('+TrajectoryGenerators/+test/+ProMPs/im_data_opt_smooth_1k.mat'  )
% load('+TrajectoryGenerators/+test/+ProMPs/im_data_opt_smooth_via_allPerm_9x150.mat')
% load('+TrajectoryGenerators/+test/+ProMPs/im_data_opt_smooth_via_allPerm_3x150.mat')
load('+TrajectoryGenerators/+test/+ProMPs/im_data_pd_4link.mat')

numSamplesTraining = 50;
dataStructure.numElements = numSamplesTraining;
dataStructure.steps = dataStructure.steps(1:numSamplesTraining);
dataStructure.iterationNumber = dataStructure.iterationNumber(1:numSamplesTraining);

trData = dataManager.getDataObject(0);
trData.copyValuesFromDataStructure(dataStructure);

sampleData = dataManager.getDataObject(0);

nSamples = trData.getNumElements();
% nSamples = 300;
trLength = trData.getNumElementsForDepth(2);


sampler.numSamples = 100;
sampler.setParallelSampling(true);

imitationLearnerDistribution.updateModel(trData);
%gainGenerator.updateModel(trData);
tic
sampler.createSamples(sampleData);
toc

savePlot = true;

% Plot --- Desired vs training
Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 1, 1, {'r'});
ms = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointPositions', 1, 1, {'b'});

title('');
set(gcf, 'Position', [580 549 643 329]);
xlabel('time(s)', 'FontSize', 20);
ylabel('q(rad)', 'FontSize', 20);
set(gca, 'FontSize', 20);
set(gca, 'YTick', [3,4,5] )
set(gca, 'XTickLabel', num2cell(0:0.5:2))
axis([0 200 3 5.3])

if (savePlot)
    Plotter.plot2svg('4LinkJoint1', gcf) %Save figure
    matlab2tikz('filename',['4LinkJoint1','.tex'],'width','0.75\columnwidth',...
             'extraAxisOptions',[...
             'ylabel style = {yshift = -1.5em,font = \large},'...
             'xlabel style = {yshift =  0.3em,font = \large},'...
             'xticklabel style = { font = \large},'...
             'yticklabel style = { font = \large},'
             ])
end
    



Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions', 2, 2, {'r'});
Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointPositions', 2, 2, {'b'});

title('');
set(gcf, 'Position', [580 549 643 329]);
xlabel('time(s)', 'FontSize', 20);
ylabel('q(rad)', 'FontSize', 20);
set(gca, 'XTickLabel', num2cell(0:0.5:2))
set(gca, 'YTick', [0,1.5,3] )
set(gca, 'FontSize', 20);
axis([0 200 0 3])

if (savePlot)
    Plotter.plot2svg('4LinkJoint2', gcf) %Save figure
    matlab2tikz('filename',['4LinkJoint2','.tex'],'width','0.75\columnwidth',...
        'extraAxisOptions',[...
        'ylabel style = {yshift = -1.5em,font = \large},'...
        'xlabel style = {yshift =  0.3em,font = \large},'...
        'xticklabel style = { font = \large},'...
        'yticklabel style = { font = \large},'
        ])
end

mx = ms(1:65,:)
environment.animate(ms,2000,5) 

if (savePlot)
    Plotter.plot2svg('4LinkJointAnimate', gcf) %Save figure
    matlab2tikz('filename',['4LinkJointAnimate','.tex'],'width','0.75\columnwidth',...
        'extraAxisOptions',[...
        'ylabel style = {yshift = -1.5em,font = \large},'...
        'xlabel style = {yshift =  0.3em,font = \large},'...
        'xticklabel style = { font = \large},'...
        'yticklabel style = { font = \large},'
        ])
end


% % 
% [meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointVelocities', 1, [], {'r'});
% [meanValues, stdValues, figureHandles] = Plotter.PlotterData.plotTrajectoriesMeanAndStd(sampleData,'jointVelocities', 1, figureHandles, {'b'});
