classdef SaveDataAndTrial < Evaluator.Evaluator
   
    properties
       % data
       
    end
    
    properties (SetObservable, AbortSet)

    end
    
    methods
        function [obj] = SaveDataAndTrial()
            obj = obj@Evaluator.Evaluator('dummy', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          

        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            %if (isempty(obj.data))
            %    obj.data = trial.dataManager.getDataObject(0);
            %end
            %trial.iterIdx
            %trial.trialdir            
            save([trial.trialDir, '/', num2str(trial.iterIdx)  'data.mat'], 'data', 'trial','-v7.3');
            evaluation = 0;
        end
        
        
    end   
    
end