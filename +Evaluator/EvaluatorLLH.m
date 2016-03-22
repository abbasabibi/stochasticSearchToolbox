classdef EvaluatorLLH < Evaluator.Evaluator
   
   properties (Access = protected)
        fileName        
    end
    
  
    methods
        function [obj] = EvaluatorLLH(fileName)
            obj = obj@Evaluator.Evaluator('llhOnTestset', {'preLoop'}, Experiments.StoringType.ACCUMULATE);          
            obj.fileName = fileName;
        end                        
        
        function [llhOnTestset] = getEvaluation(obj, data, newData, trial)               
            
            load(obj.fileName)
            
            newData.copyValuesFromDataStructure(data);
            numEpisodesToKeep   = 500;
            numStepsToKeep      = 50;
            newData.reserveStorage([numEpisodesToKeep, numStepsToKeep])
            
%             obj.numEpisodes, obj.numOptions, obj.numTimeSteps
            trial.policyLearner.numEpisodes     = numEpisodesToKeep;
            trial.policyLearner.numTimeSteps    = numStepsToKeep;
            EMDataTest      = trial.policyLearner.EStep( newData, []);
            llhOnTestset    = trial.policyLearner.getLogLikelihood(EMDataTest);
            

            msg = 'llh on test-set:';
            fprintf('%50s %.3g\n', msg, llhOnTestset);
        end
                
    end   
    
end