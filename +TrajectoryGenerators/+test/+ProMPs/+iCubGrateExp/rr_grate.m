function rr_grate ( fNameIn, fNameOut )



load( fNameIn );

settings = Common.Settings();
settings.setProperty('dt', imlearn.dt);
settings.setProperty('numTimeSteps', length(imlearn.q{1}));

dimObsState = size(imlearn.q{1},2)/2;
dimCtls = size(imlearn.u{1},2);


settings.setProperty('numBasis', 50);
settings.setProperty('widthFactorBasis', 4);
settings.setProperty('Noise_std', 0.0);


sampler = Sampler.EpisodeWithStepsSampler();

dataManager = sampler.getEpisodeDataManager();
sampler.getStepSampler.setIsActiveSampler(Sampler.IsActiveStepSampler.IsActiveNumSteps(dataManager));


% Env is needed only for setting up the steps in this script
environment = Environments.DynamicalSystems.LinearSystem(sampler, dimObsState);
environment.masses = ones(1,dimObsState);
dataManager.setRange('actions',-1e10*ones(1,dimObsState),1e10*ones(1,dimObsState));
dataManager.setRestrictToRange('actions', false);
environment.initObject();

sampler.setTransitionFunction(environment);

trajectoryGenerator = TrajectoryGenerators.ProMPsModelFree(dataManager, dimObsState, dimCtls);
distributionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, trajectoryGenerator.distributionW);
distributionLearner.minCov = 0.0;
distributionLearner.maxCorr = 1.0;

gainGenerator = TrajectoryGenerators.ProMPsModelFreeCtl(dataManager, trajectoryGenerator);

corrCtl = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearControllerDistributionCorrection...
                                          (dataManager, trajectoryGenerator, dimCtls, gainGenerator);

trajectoryGenerator.initObject();

sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseD');
sampler.addParameterPolicy(trajectoryGenerator.phaseGenerator,'generatePhaseDD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisD');
sampler.addParameterPolicy(trajectoryGenerator.basisGenerator,'generateBasisDD');

% ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, dimCtls, gainGenerator);
ctrTraj = TrajectoryGenerators.TrajectoryTracker.TimeVarLinearController(dataManager, dimCtls, corrCtl);
sampler.setActionPolicy(ctrTraj);

imitationLearner = TrajectoryGenerators.ImitationLearning.LinearTrajectoryImitationLearner...
                      (dataManager, trajectoryGenerator, 'jointStateAction');
                  
imitationLearnerDistribution = TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner...
                                (dataManager, imitationLearner, distributionLearner, trajectoryGenerator);
                         
imitationLearner.imitationLearningRegularization = 1e-6;
                         
sampler.addParameterPolicy(gainGenerator,'updateModel');

sampler.setInitialStateSampler(trajectoryGenerator);


dataManager.addDataEntry('steps.jointStateAction', dimObsState+dimCtls);

dataManager.finalizeDataManager();



nSamples = length(imlearn.q);
trLength = size(imlearn.q{1},1);

trData = dataManager.getDataObject([nSamples trLength]);


figure(100);hold all;
figure(101);hold all;
for i = 1:nSamples
    figure(100);plot(imlearn.q{i}(:,1));    
    figure(101);plot(imlearn.u{i});
    trData.setDataEntry('jointStateAction', ...
        [imlearn.q{i}(:,1:2:end) , imlearn.u{i}], i);
%     trData.setDataEntry('actions', imlearn.u{i}, i);

    
    trData.setDataEntry('jointPositions', imlearn.q{i}(:,1:2:end), i);  %for comp plotting
    trData.setDataEntry('jointVelocities', imlearn.q{i}(:,2:2:end), i);
end

imitationLearnerDistribution.updateModel(trData);


% trajectoryGenerator.conditionTrajectory(4.5, 70, 1e-6, [1 0 0 0]);


phase  = trajectoryGenerator.phaseGenerator.generatePhase();
basis  = trajectoryGenerator.basisGenerator.generateBasis(phase);
basisD = trajectoryGenerator.basisGenerator.generateBasisD(phase);
[mu_t, Sigma_t] = trajectoryGenerator.getExpectationAndSigma(basis, basisD, []);
[K_t, k_t, Sigma_u_all] = gainGenerator.getCtlGains ( mu_t, Sigma_t );


% Desired vs Training Data
figH = trajectoryGenerator.plotStateDistribution(0,[],'r');
Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions',1:dimObsState, figH, {'b'});
Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointStateAction',(1:dimCtls)+dimObsState, figH((dimObsState+1):end), {'b'});

% Desired Control vs Position Data
% figH = trajectoryGenerator.plotStateDistribution(0,[],'r');
% mod_h = figH((dimObsState+1):end);
% mod_h(1:2) = mod_h([2,1]);
% Plotter.PlotterData.plotTrajectoriesMeanAndStd(trData,'jointPositions',1:dimCtls, mod_h, {'b'});


meanEnc = reshape(mu_t,[],2*(dimObsState + dimCtls));
nJoints = dimObsState - dimCtls;

%% Plot desCtl vs specified deviation vs imtraj 

desCtl = zeros(trLength, dimCtls);  % mean
desCtl2 = zeros(trLength, dimCtls); % imTraj
desCtl3 = zeros(trLength, dimCtls); % mean no Force vel
desCtl4 = zeros(trLength, dimCtls); % imtraj no Forece vel

imIdx = 6;
imTraj = zeros(trLength,2*dimObsState);
imTraj(:,1:(end/2)) =  imlearn.q{imIdx}(:,1:2:end);
imTraj(:,(end/2+1):end) =  imlearn.q{imIdx}(:,2:2:end)*5;
imCtl = imlearn.u{imIdx};

dev = zeros(trLength,2*dimObsState);
dev(:,1:(end/2)) = repmat(...
    interp1([1,  trLength/2, trLength], [ -5, 0, 5],1:trLength,'spline')',1,dimObsState);


for t = 1:trLength
    idx = ((1:dimCtls)-1)*trLength + t;
    idxObs = [(1:dimObsState)-1, ( (1:dimObsState)+dimObsState + dimCtls -1)] * trLength+t;

    desCtl(t,:)  =  K_t(idx,:) *  ( mu_t(idxObs )+ dev(t,:)' )  + k_t(idx);
    desCtl2(t,:) =  K_t(idx,:) *     imTraj(t,:)'    + k_t(idx);
    desCtl3(t,:) =  K_t(idx,1:(dimObsState+nJoints)) *  mu_t(idxObs(1:(dimObsState+nJoints)) )  + k_t(idx);
    desCtl4(t,:) =  K_t(idx,1:(dimObsState+nJoints)) *  imTraj(t,1:(dimObsState+nJoints))'  + k_t(idx);
end

for i = 1:dimCtls
    figure; hold on;
    plot(desCtl(:,i),'b','Linewidth',2.0);
    plot(desCtl2(:,i),'g','Linewidth',2.0);
    plot(imCtl,'k','Linewidth',2.0);
    plot(meanEnc(:,i+dimObsState),'r-.','Linewidth',2.0)
    legend({'Spec dev', 'ImTraj', 'Real', 'Mean'})
end

for i = 1:dimCtls
    figure; hold on;
    plot(desCtl3(:,i),'b','Linewidth',2.0);
    plot(desCtl4(:,i),'g','Linewidth',2.0);
    plot(meanEnc(:,i+dimObsState),'r-.','Linewidth',2.0)
    legend({'Spec dev', 'ImTraj', 'Mean'})
end
figure; plot (dev,'Linewidth',2.0);


%% Saving gains and info to file

%No K_d for ext. obs
KpIdx = 1:dimObsState;
KdIdx = dimObsState+(1:dimCtls);

prompData.K_t = K_t(:,[KpIdx,KdIdx]);
prompData.Kp_t = K_t(:,KpIdx);
prompData.Kd_t = K_t(:,KdIdx);
prompData.k_t = k_t;

prompData.numSteps = trLength;
prompData.dt = imlearn.dt;

prompData.q0 = mu_t(1:trLength:end);
prompData.q0 = [prompData.q0(1:dimObsState);prompData.q0((1:nJoints)+dimObsState+dimCtls)];

prompData.torqueCtl = imlearn.ctlTorque;

prompData.meanEnc = meanEnc(:,(1:dimCtls)+dimObsState);

prompData.actionNames = imlearn.actionNames;
prompData.inputNames = imlearn.jointNames;

save(fNameOut,'prompData');


keyboard

%%


return
