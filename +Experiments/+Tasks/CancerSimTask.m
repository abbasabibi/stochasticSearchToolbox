classdef CancerSimTask < Experiments.Tasks.StepBasedTask
    
    methods
        function obj = CancerSimTask(varargin)
            obj = obj@Experiments.Tasks.StepBasedTask('CancerSim', varargin{:})
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.StepBasedTask(trial);
            
            trial.setprop('cancerEval', @Environments.Cancer.CancerTrajectoryEvaluator);
            %trial.setprop('trajectoryRanker', @Environments.Cancer.CancerTrajectoryRanker);
            
            Common.SettingsManager.activateDebugMode();
            
            Common.Settings().setProperty('discreteActionBuckets',4);
        end
        
        function setupEnvironment(obj, trial)
            trial.transitionFunction = Environments.Cancer.CancerSim(trial.sampler);
            trial.transitionFunction.initObject();
            trial.rewardFunction = trial.transitionFunction;
            trial.initialStateSampler = trial.transitionFunction;
            trial.contextSampler = trial.transitionFunction;
            
            trial.setprop('discreteActions', Environments.DiscreteActionGenerator(trial.dataManager,trial.transitionFunction));
            
            %Should be in setupSampler, but environment is not initialized
            environmentActive = Sampler.IsActiveStepSampler.IsActiveEnvironment(trial.dataManager,trial.sampler.getStepSampler().isActiveSampler, trial.transitionFunction);
            trial.sampler.getStepSampler().setIsActiveSampler(environmentActive);
        end
        
        function setupSampler(obj, trial)
            obj.setupSampler@Experiments.Tasks.StepBasedTask(trial);
            
            trial.cancerEval = trial.cancerEval(trial.sampler);
        end
        
        function registerSamplers(obj, trial)
            obj.registerSamplers@Experiments.Tasks.StepBasedTask(trial);
            
            trial.sampler.addSamplerFunctionToPool('Episodes','evalFunction',trial.cancerEval);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)
            obj.addDefaultCriteria@Experiments.Tasks.StepBasedTask(trial, evaluationCriterion);
       
           evaluator = Environments.Cancer.CancerSolutionEvaluator();
           evaluationCriterion.registerEvaluator(evaluator);
        end
    end
    
end
