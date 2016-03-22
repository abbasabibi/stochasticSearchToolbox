classdef BanditLearningSetupForLocalReps < Experiments.Learner.BanditLearningSetup
    
    properties
    end
    
    methods
        function obj = BanditLearningSetupForLocalReps()
            obj = obj@Experiments.Learner.BanditLearningSetup('LocalREPS');
        end
          
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Learner.BanditLearningSetup(trial);
            
            trial.setprop('parameterPolicy', @Learner.EpisodicRL.LocalREPS.CreateFromTrial);
            trial.setprop('parameterPolicyLearner', []);
            trial.setprop('kernel', @FeatureGenerators.ExponentialQuadraticKernel);
            trial.setprop('learner', []);            
        end
        
        function postConfigureTrial(obj, trial)
            obj.setupKernel(trial);

            obj.postConfigureTrial@Experiments.Learner.BanditLearningSetup(trial);
        end
                
        function setupKernel(obj,trial)            
            maxfeatures = 0;
            trial.kernel = trial.kernel(trial.dataManager, {'contexts'}, ':', maxfeatures);             
        end
        
        function setupParameterPolicy(obj, trial)
            trial.parameterPolicy=trial.parameterPolicy(trial);
            trial.parameterPolicyLearner = [];
           
        end
        
        function setupLearner(obj, trial)
            trial.learner=trial.parameterPolicy;
        end
       
    end
    
end


