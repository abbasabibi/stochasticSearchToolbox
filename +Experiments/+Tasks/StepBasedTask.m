classdef StepBasedTask < Experiments.Tasks.BanditTask
    
    properties
        isInfiniteHorizon
    end
    
    methods
        function obj = StepBasedTask(taskName, isInfiniteHorizon)
            obj = obj@Experiments.Tasks.BanditTask(taskName);
            if (~exist('isInfiniteHorizon', 'var'))
                isInfiniteHorizon = false;
            end
            obj.isInfiniteHorizon = isInfiniteHorizon;
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.Tasks.BanditTask(trial);
            trial.setprop('actionName', 'actions');
            trial.setprop('sampler', @Sampler.EpisodeWithStepsSampler );
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('rewardFunction');
            trial.setprop('actionPolicy');
            trial.setprop('transitionFunction');
            trial.setprop('initialStateSampler');   
            
            
            
            Common.Settings().setProperty('numIterations', trial.numIterations);
            
            
            obj.postConfigureTrial@Experiments.Tasks.BanditTask(trial);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Experiments.Tasks.BanditTask(trial, evaluationCriterion);

            evaluationCriterion.addSaveDataEntry('states');
            evaluationCriterion.addSaveDataEntry('actions');
            evaluationCriterion.addSaveDataEntry('rewards');
            evaluationCriterion.addSaveDataEntry('nextStates');
            evaluationCriterion.addSaveDataEntry('timeSteps');

        end
        
        
        function  setupSampler(obj, trial)
            
            trial.sampler       = trial.sampler();
            trial.dataManager   = trial.sampler.getEpisodeDataManager();    
            
            if (obj.isInfiniteHorizon)
                isActiveSampler = Sampler.IsActiveStepSampler.IsActiveFixedGamma(trial.dataManager);
            else
                isActiveSampler = Sampler.IsActiveStepSampler.IsActiveNumSteps(trial.dataManager);
%                Common.Settings().setProperty('numTimeSteps', trial.numTimeSteps);            
            end

            trial.sampler.getStepSampler().setIsActiveSampler(isActiveSampler);

            trial.dataManager = trial.sampler.getEpisodeDataManager();                       
            trial.dataManager.addDataEntry('returns',1);

            trial.dataManager.finalizeDataManager();
        end
        
        function registerSamplers(obj, trial)
            
            if (~isempty(trial.rewardFunction))
                trial.sampler.setRewardFunction(trial.rewardFunction);
            end
                       
            if (~isempty(trial.transitionFunction))
                trial.sampler.setTransitionFunction(trial.transitionFunction);
            end
            
            if (trial.isProperty('actionPolicy') && ~isempty(trial.actionPolicy))
                trial.sampler.setActionPolicy(trial.actionPolicy);
            end
            
            if (isempty(trial.returnSampler))
                if(obj.isInfiniteHorizon)
                    trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(trial.dataManager);
                    %should use the average return evaluator...
                else
                    trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(trial.dataManager);
                end
            end
            
            if (isempty(trial.contextSampler) && trial.dataManager.isDataAlias('contexts'))
                trial.contextSampler = Sampler.InitialSampler.InitialContextSamplerStandard(trial.sampler);
            end
            
            
            
            if (~isempty(trial.contextSampler) && isempty(trial.initialStateSampler))
                trial.initialStateSampler = Sampler.InitialSampler.InitialStateSamplerStandard(trial.sampler);
                trial.initialStateSampler.setInitStateFromContext(true);
            end
            
            if (~isempty(trial.initialStateSampler))
                trial.sampler.setInitialStateSampler(trial.initialStateSampler);
            end            
            
            obj.registerSamplers@Experiments.Tasks.BanditTask(trial);
        end
    end
end


