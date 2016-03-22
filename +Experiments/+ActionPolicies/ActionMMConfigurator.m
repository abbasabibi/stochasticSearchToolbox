classdef ActionMMConfigurator  < Experiments.ActionPolicies.ActionPolicyConfigurator & Common.IASObject
    
    properties (SetObservable,AbortSet)
    end
    
    methods
        function obj = ActionMMConfigurator (policyName)
            obj = obj@Experiments.ActionPolicies.ActionPolicyConfigurator(policyName);
                        
            obj.linkProperty('numOptions');
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.ActionPolicies.ActionPolicyConfigurator(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)

           
            
            obj.preConfigureTrial@Experiments.ActionPolicies.ActionPolicyConfigurator(trial);

            trial.setprop('numOptions', 10);
            
            trial.setprop('optionLearner',                  @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('optionInitializer',              @Distributions.Gaussian.GaussianLinearInFeatures);
            trial.setprop('gatingDist',                     @Distributions.Discrete.SoftMaxDistribution);
            trial.setprop('gatingLearner',                  @Learner.ClassificationLearner.MultiClassLogisticRegressionLearner);
%             trial.setprop('mixtureModelLearner',            @Learner.SupervisedLearner.MixtureModelLearner);
            
            trial.setprop('actionGatingInputVariables', 'states');

            trial.setprop('initMMLearner',                  @Learner.SupervisedLearner.InitMMLearner);

            
           
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupActionPolicy(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
        
       
        function [] = setupScenarioForLearners(~, trial)
            trial.scenario.addInitObject(trial.actionPolicy);   
            if(~isempty(trial.policyLearner))
                trial.scenario.addInitObject(trial.policyLearner);     
            end
            trial.scenario.addInitialLearner(trial.initMMLearner);
        end
        
        function [] = setupActionPolicy(obj, trial)
            if(isempty(trial.settings.actionGatingInputVariables));
                error('trial.actionGatingInputVariables needs to be set by the correct configurator first.\n')
            end
            
            settings                   = trial.settings();
            numOptions                 = settings.getProperty('numOptions');
            depth                      = trial.dataManager.getDataEntryDepth('states');
            trial.dataManager.addDataEntryForDepth(depth, 'options', 1, 1, numOptions);
            
            gaussianDist                = Distributions.Gaussian.GaussianLinearInFeatures(trial.dataManager, 'actions', trial.policyInputVariables, 'ActionPolicy');
            optionLearnerInit = settings.optionLearner;
            trial.optionLearner         = optionLearnerInit(trial.dataManager, gaussianDist);
            
            gatingDistInit = settings.gatingDist;
            trial.gatingDist            = gatingDistInit(trial.dataManager, 'options', trial.settings.actionGatingInputVariables, 'Gating'); %Need access to policyFeatuers
            gatingLearnerInit = settings.gatingLearner;
            trial.gatingLearner         = gatingLearnerInit(trial.dataManager, trial.gatingDist, true); %false or true???
            
            
            trial.actionPolicy          = Distributions.MixtureModel.MixtureModel.createPolicy(...
                trial.dataManager, trial.gatingDist, ...
                trial.optionInitializer, 'actions', trial.policyInputVariables, 'options');
            
            
%             trial.mixtureModelLearner = trial.mixtureModelLearner(trial.dataManager, trial.actionPolicy, ...
%                 trial.optionLearner, trial.gatingLearner, 'outputResponsibilities');
            
            
            trial.policyLearner         = Learner.SupervisedLearner.MixtureModelLearner(trial.dataManager, trial.actionPolicy, ...
                trial.optionLearner, trial.gatingLearner, 'outputResponsibilities');
            
            initMMLearnerInit           = settings.initMMLearner;
            trial.initMMLearner         = initMMLearner(trial.dataManager, trial.policyLearner);
            
            
            trial.sampler.setActionPolicy(trial.actionPolicy);
            
            
            

            
        end
    end
   
end
