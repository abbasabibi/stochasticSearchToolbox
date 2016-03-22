classdef NoReuseSampling < DataPreprocessors.DataPreprocessor
          
   methods (Static)
       function [preprocessor] = CreateFromTrial(trial)
           preprocessor = DataPreprocessors.RejectionSampling(trial.dataManager, trial.parameterPolicy);
           
       end
   end
   
    methods
        function obj = NoReuseSampling(dataManager, currentPolicy)
            obj = obj@DataPreprocessors.DataPreprocessor();
            
            depth = dataManager.getDataEntryDepth(currentPolicy.outputVariable);
            subManager = dataManager.getDataManagerForDepth(depth);
            
            subManager.addDataEntry('importanceWeights', 1);
        end
        
        function data = preprocessData(obj, data)
            
            iterNr = data.getDataEntry('iterationNumber');
            timeSteps = data.getDataEntry('timeSteps');
            idx = find(timeSteps==0 | timeSteps==1);
            
            samples = numel(iterNr(iterNr==(max(iterNr))));
            minIdx = idx(max(1,end-samples+1));
                        
            importanceWeights = zeros(size(timeSteps));
            importanceWeights(minIdx:end) = 1;
            importanceWeights = importanceWeights/sum(importanceWeights);
            
            data.setDataEntry('importanceWeights', importanceWeights);
            
            fprintf('Number of Effective Samples: %f\n', sum(importanceWeights) / max(importanceWeights));
        end
   
   end
end
