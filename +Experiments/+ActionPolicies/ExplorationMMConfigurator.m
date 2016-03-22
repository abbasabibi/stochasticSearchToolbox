classdef ExplorationMMConfigurator < Experiments.ActionPolicies.ActionPolicyConfigurator & Common.IASObject
    
    properties (SetObservable,AbortSet)
        numOptions =1
        
    end
    
    methods
        function obj = ExplorationMMConfigurator  (policyName)
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator(policyName);
            
            obj.linkProperty('numOptions');
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@ Experiments.ActionPolicies.ActionPolicyConfigurator(trial, evaluationCriterion);
        end
        
        
        
        
        function preConfigureTrial(obj, trial)
            
            
            
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);
            
            
            trial.setprop('terminationPolicyInitializer',   @Distributions.Discrete.LogisticDistribution)
            trial.setprop('terminationPolicy',              @Distributions.Discrete.LogisticDistribution)
            trial.setprop('terminationLearner',             @Learner.ClassificationLearner.LogisticRegressionLearner);
            trial.setprop('optionLearner',                  @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('optionInitializer',              @Distributions.Gaussian.GaussianLinearInFeatures);
            trial.setprop('gatingDist',                     @Distributions.Discrete.SoftMaxDistribution);
            trial.setprop('gatingLearner',                  @Learner.ClassificationLearner.MultiClassLogisticRegressionLearner);
            
            trial.setprop('mixtureModelLearner',            @Learner.SupervisedLearner.TerminationMMLearner);
            trial.setprop('explorationPolicy');
            trial.setprop('controller',                     @TrajectoryGenerators.TrajectoryTracker.LinearFeedbackController);
            
            trial.setprop('actionGatingInputVariables', 'states');
            trial.setprop('terminationInputVariables', 'states');
            %             trial.setprop('numOptions', 10);
            
            trial.setprop('initMMLearner', @Learner.SupervisedLearner.InitMMLearner);
            
            
            
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupActionPolicy(trial);
            obj.postConfigureTrial@Experiments.Configurator(trial);
        end
        
        
        function [] = setupScenarioForLearners(~, trial)
            trial.scenario.addInitObject(trial.actionPolicy);
            if(~isempty(trial.policyLearner))
                trial.scenario.addInitObject(trial.policyLearner);
                trial.scenario.addInitObject(trial.mixtureModelLearner);
                %                 trial.scenario.addInitObject(trial.mixtureModel);
            end
            trial.scenario.addInitialLearner(trial.initMMLearner);
        end
        
        function [] = setupActionPolicy(obj, trial)
            if(isempty(trial.actionGatingInputVariables));
                error('trial.actionGatingInputVariables needs to be set by the correct configurator first.\n')
            end
            
            settings                   = Common.Settings();
            obj.numOptions             = settings.getProperty('numOptions');
            depth                      = trial.dataManager.getDataEntryDepth('states');
            trial.dataManager.addDataEntryForDepth(depth, 'options', 1, 1, obj.numOptions);
            
            dimActions  = trial.dataManager.getNumDimensions('actions');
            numParams   = dimActions * (1+ trial.dataManager.getNumDimensions('states'));
            trial.dataManager.addDataEntryForDepth(depth, 'parameters', numParams);
            trial.dataManager.addDataEntryForDepth(depth, 'parametersOld', numParams );
            
            %the state dim determines the search space for the linear
            %feedback term. We would need to set this in a smarter way...
            minRangeParams                  = ones(1,numParams) * -1; 
            minRangeParams(1:dimActions)    = trial.dataManager.getMinRange('actions');
            
            maxRangeParams                  = ones(1,numParams) * 1;
            maxRangeParams(1:dimActions)    = trial.dataManager.getMaxRange('actions');
            trial.dataManager.setRange('parameters', minRangeParams, maxRangeParams);
            
            
            gaussianDist                = Distributions.Gaussian.GaussianLinearInFeatures(trial.dataManager, 'parameters', '', 'ActionPolicy');
            trial.optionLearner         = trial.optionLearner(trial.dataManager, gaussianDist);
            
            trial.terminationPolicy     = trial.terminationPolicy(trial.dataManager, 'terminations', trial.terminationInputVariables, 'terminationFunction');
            trial.terminationLearner    = trial.terminationLearner(trial.dataManager,trial.terminationPolicy, true);
            
            trial.gatingDist            = trial.gatingDist(trial.dataManager, 'options', trial.actionGatingInputVariables, 'Gating'); %Need access to policyFeatuers
            trial.gatingLearner         = trial.gatingLearner(trial.dataManager, trial.gatingDist, true); %false or true???
            
            
            
            trial.explorationPolicy     = Distributions.MixtureModel.MixtureModelExploration.createParameterPolicy(...
                trial.dataManager, trial.gatingDist, ...
                trial.optionInitializer, 'parameters', trial.policyInputVariables, ...
                trial.terminationPolicy.inputVariables{1}, trial.terminationPolicyInitializer, 'options', 'optionsOld');
            
            
            trial.mixtureModelLearner   = trial.mixtureModelLearner(trial.dataManager, trial.explorationPolicy, ...
                trial.optionLearner, trial.gatingLearner, trial.terminationLearner, 'outputResponsibilities');
            
            
            trial.policyLearner         = Learner.ExpectationMaximization.EMExploration(...
                trial.dataManager, trial.explorationPolicy, trial.mixtureModelLearner);
            
            trial.initMMLearner         = trial.initMMLearner(trial.dataManager, trial.mixtureModelLearner);
            
            
            
            
            
            trial.actionPolicy          = trial.controller(trial.dataManager, numParams);
            trial.sampler.setActionPolicy(trial.actionPolicy);
            trial.sampler.stepSampler.addSamplerFunctionToPool('Policy', 'sampleFromDistribution', trial.explorationPolicy, -1);
            
            
            
            
            
        end
    end
    
end
