classdef ParameterMixtureModelConfigurator < Experiments.ActionPolicies.ParameterPolicyConfigurator & Common.IASObject
    
    properties (SetObservable,AbortSet)
            numOptions =1
        
    end
    
    methods
        function obj = ParameterMixtureModelConfigurator(policyName)
            obj = obj@Experiments.ActionPolicies.ParameterPolicyConfigurator(policyName);
                        
            obj.linkProperty('numOptions');
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)            
            obj.addDefaultCriteria@ Experiments.ActionPolicies.ParameterPolicyConfigurator(trial, evaluationCriterion);
        end
        
        function preConfigureTrial(obj, trial)

           
            
            obj.preConfigureTrial@Experiments.ActionPolicies.ParameterPolicyConfigurator(trial);

%             trial.setprop('gaussianDist');
            trial.setprop('optionLearner',      @Learner.SupervisedLearner.LinearGaussianMLLearner);
            trial.setprop('optionInitializer',  @Distributions.Gaussian.GaussianLinearInFeatures);
            trial.setprop('gatingDist',         @Distributions.Discrete.SoftMaxDistribution);
            trial.setprop('gatingLearner',      @Learner.ClassificationLearner.MultiClassLogisticRegressionLearner);
            
            trial.setprop('parameterGatingInputVariables', 'contexts');
%             trial.setprop('numOptions', 10);

            trial.setprop('initMMLearner', @Learner.SupervisedLearner.InitMMLearner);

            
           
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupParameterPolicy(trial);                                  
            obj.postConfigureTrial@Experiments.Configurator(trial);                                 
        end
        
       
        function [] = setupScenarioForLearners(~, trial)
            trial.scenario.addInitObject(trial.parameterPolicy);   
            if(~isempty(trial.parameterPolicyLearner))
                trial.scenario.addInitObject(trial.parameterPolicyLearner);     
            end
            trial.scenario.addInitialLearner(trial.initMMLearner);
        end
        
        function [] = setupParameterPolicy(obj, trial)
             if(isempty(trial.parameterGatingInputVariables));
                error('trial.parameterGatingInputVariables needs to be set by the correct configurator first.\n')
             end
             
             settings = Common.Settings(); 
             obj.numOptions = settings.getProperty('numOptions');
             depth = trial.dataManager.getDataEntryDepth('parameters'); %used to be 2
             trial.dataManager.addDataEntryForDepth(depth, 'options', 1, 1, obj.numOptions);
             
            gaussianDist                = Distributions.Gaussian.GaussianLinearInFeatures(trial.dataManager, 'parameters', trial.parameterPolicyInputVariables, 'ActionPolicy');
            trial.optionLearner         = trial.optionLearner(trial.dataManager, gaussianDist);

%             trial.optionInitializer   = @Distributions.Gaussian.GaussianLinearInFeatures;
            trial.gatingDist            = trial.gatingDist(trial.dataManager, 'options', trial.parameterGatingInputVariables, 'Gating'); %Need access to policyFeatuers
%             trial.gatingDist.numItems = obj.numOptions;
            trial.gatingLearner         = trial.gatingLearner(trial.dataManager, trial.gatingDist, true); %false or true???
            

            trial.parameterPolicy       = Distributions.MixtureModel.MixtureModel.createParameterPolicy(...
                trial.dataManager, trial.gatingDist, trial.optionInitializer, 'parameters', trial.parameterPolicyInputVariables, 'options');

            trial.parameterPolicyLearner = Learner.SupervisedLearner.MixtureModelLearner(trial.dataManager, ...
                trial.parameterPolicy, trial.optionLearner, trial.gatingLearner, 'outputResponsibilities');
            
            trial.initMMLearner         = trial.initMMLearner(trial.dataManager, trial.parameterPolicyLearner);
            
            %not so sure about this..
            if( isprop(trial.sampler,'stageSampler') )
                trial.sampler.stageSampler.setParameterPolicy(trial.parameterPolicy);
            end
            
            
            

            
        end
    end
   
end
