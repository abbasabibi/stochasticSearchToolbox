classdef BanditTask < Experiments.ConfiguredTask
    
    properties
        
    end
    
    methods
        function obj = BanditTask(taskName)
            obj = obj@Experiments.ConfiguredTask(taskName, Experiments.LearnerType.TypeA);
        end
                
        
        function postConfigureTrial(obj, trial)
            obj.postConfigureTrial@Experiments.ConfiguredTask(trial);
                        
            trial.setprop('contextSampler');
            trial.setprop('returnSampler');
            
            trial.setprop('virtualSampler');
            
            obj.setupEnvironment(trial);
        end
                       
        
        function  setupSampler(obj, trial)
            
            trial.sampler = Sampler.EpisodeSampler();
            
            trial.dataManager = trial.sampler.getEpisodeDataManager();            
            trial.dataManager.finalizeDataManager();

            
        end
        
        function registerSamplers(obj, trial)
            
            if (trial.isProperty('contextSampler') && ~isempty(trial.contextSampler))                
                trial.sampler.setContextSampler(trial.contextSampler);                        
            end           
            if (~isempty(trial.returnSampler))    
                trial.sampler.setReturnFunction(trial.returnSampler);
            end
        end
        
        function addDefaultCriteria(obj, trial, evaluationCriterion)  
           %evaluationCriterion.addCriterion('endLoop', 'data', 'avgReturn', Experiments.StoringType.ACCUMULATE, @(data)mean(data.getDataEntry('returns')));
           evaluator = Evaluator.ReturnEvaluatorNewSamples();
           evaluationCriterion.registerEvaluator(evaluator);
           
           evaluationCriterion.addSaveDataEntry('returns');
           if (trial.dataManager.isDataEntry('contexts'))
               evaluationCriterion.addSaveDataEntry('contexts');
           end
           if (trial.dataManager.isDataEntry('parameters'))
               evaluationCriterion.addSaveDataEntry('parameters');
           end
           
        end                
    end
    
    methods (Abstract)
        [] = setupEnvironment(obj, trial)            
    end
end


