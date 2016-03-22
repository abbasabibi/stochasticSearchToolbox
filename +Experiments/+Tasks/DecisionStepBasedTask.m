classdef DecisionStepBasedTask < Experiments.ConfiguredTask
    
    properties
        isInfiniteHorizon
    end
    
    methods
        function obj = DecisionStepBasedTask(taskName, isInfiniteHorizon)
            obj = obj@Experiments.ConfiguredTask(taskName, Experiments.LearnerType.TypeA);
            if (~exist('isInfiniteHorizon', 'var'))
                isInfiniteHorizon = false;
            end
            obj.isInfiniteHorizon = isInfiniteHorizon;
        end
        
        function preConfigureTrial(obj, trial)
            obj.preConfigureTrial@Experiments.ConfiguredTask(trial);
            trial.setprop('actionName', 'actions');
            trial.setprop('parameterName', 'parameters');
        end
        
        function postConfigureTrial(obj, trial)
            trial.setprop('contextSampler');
            trial.setprop('returnSampler');
            
            trial.setprop('rewardFunction');
            trial.setprop('actionPolicy');
            trial.setprop('parameterPolicy');

            trial.setprop('transitionFunction');
            trial.setprop('initialStateSampler');
            trial.setprop('endStageSampler');
            trial.setprop('decisionTerminationSampler');
            
            
            trial.setprop('stepIsActiveSampler');
            
            Common.Settings().setProperty('numIterations', trial.numIterations);
            
            obj.setupEnvironment(trial);
            obj.postConfigureTrial@Experiments.ConfiguredTask(trial);
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
            obj.addDefaultCriteria@Experiments.ConfiguredTask(trial, evaluationCriterion);

            evaluationCriterion.addSaveDataEntry('states');
            evaluationCriterion.addSaveDataEntry('actions');
            evaluationCriterion.addSaveDataEntry('rewards');
            evaluationCriterion.addSaveDataEntry('nextStates');
            evaluationCriterion.addSaveDataEntry('timeSteps');
            evaluationCriterion.addSaveDataEntry('parameters');
            evaluationCriterion.addSaveDataEntry('contexts');

        end
        
        
        function  setupSampler(obj, trial)
            
            trial.sampler       = Sampler.EpisodeWithDecisionStagesSampler();
            trial.dataManager   = trial.sampler.getEpisodeDataManager();    
            
            if (obj.isInfiniteHorizon)
                isActiveSampler = Sampler.IsActiveStepSampler.IsActiveFixedGamma(trial.dataManager, 'decisionSteps');
            else
                isActiveSampler = Sampler.IsActiveStepSampler.IsActiveNumSteps(trial.dataManager, 'decisionSteps');
            end

            trial.sampler.stageSampler.setIsActiveSampler(isActiveSampler);

               
            
            
            trial.dataManager.finalizeDataManager();
        end
        
        function registerSamplers(obj, trial)
            
            if (~isempty(trial.rewardFunction))
                trial.sampler.stageSampler.setRewardFunction(trial.rewardFunction);
            end
                       
            if (~isempty(trial.transitionFunction))
                trial.sampler.setTransitionFunction(trial.transitionFunction);
            end
            
            if (trial.isProperty('actionPolicy') && ~isempty(trial.actionPolicy))
                trial.sampler.stageSampler.setActionPolicy(trial.actionPolicy);
            end
            
            if (isempty(trial.returnSampler))
                if(obj.isInfiniteHorizon)
                    assert(false);
%                     trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(trial.sampler);
                    %should use the average return evaluator...
                else
                    trial.returnSampler = RewardFunctions.ReturnForEpisode.ReturnSummedReward(trial.sampler);
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
            
            if(isempty(trial.endStageSampler) )
                trial.endStageSampler = Sampler.test.TransitionContextSampler(trial.dataManager, 6, trial.contextSampler);
            end
            
            
            
            
            trial.sampler.setContextSampler(trial.contextSampler);
            trial.sampler.stageSampler.setEndStateTransitionSampler(trial.endStageSampler);
            trial.sampler.stageSampler.stepSampler.setIsActiveSampler(trial.decisionTerminationSampler);
            trial.sampler.stageSampler.setReturnFunction(trial.returnSampler);
            
            
            
            obj.registerSamplers@Experiments.ConfiguredTask(trial);
        end
    end
    
    methods (Abstract)
        [] = setupEnvironment(obj, trial)
    end
end


