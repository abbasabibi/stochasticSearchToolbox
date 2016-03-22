classdef ImportanceSamplingLastKPolicies < DataPreprocessors.DataPreprocessor
    
   properties
      currentPolicy;
      
      lastPolicies;             
            
      importanceWeightName;
      importanceWeightSumName;
      
   end
   
   properties (SetObservable, AbortSet)
       numLastPoliciesImportanceSampling = 50;
       iterationDiscount = 1;
   end
   
   methods (Static)
       function [preprocessor] = CreateFromTrial(trial)
           preprocessor = DataPreprocessors.ImportanceSamplingLastKPolicies(trial.dataManager, trial.parameterPolicy);
           
       end
   end
   
   % Class methods
   methods
      function obj = ImportanceSamplingLastKPolicies(dataManager, currentPolicy)
            obj = obj@DataPreprocessors.DataPreprocessor();
            
            obj.currentPolicy = currentPolicy;
            
            depth = dataManager.getDataEntryDepth(currentPolicy.outputVariable);
            subManager = dataManager.getDataManagerForDepth(depth);
            
            obj.importanceWeightName = obj.getNameWithSuffix('importanceWeights');
            obj.importanceWeightSumName = obj.getNameWithSuffix('importanceWeightsSum');
            
            
            subManager.addDataEntry(obj.importanceWeightName, 1);            
            subManager.addDataEntry(obj.importanceWeightSumName, 1);  
            
            obj.linkProperty('numLastPoliciesImportanceSampling');
            obj.linkProperty('iterationDiscount');
      end 
            
      function data = preprocessData(obj, data)          
          % Importance weighting: Sampling distribution is mixture of old
          % sampling distributions!
          importanceWeightsSum = data.getDataEntry(obj.importanceWeightSumName);
          dataProbabilityLog = obj.currentPolicy.callDataFunctionOutput('getDataProbabilities', data);
          
          iterations = data.getDataEntry('iterationNumber');
          
          iterationIndex = iterations == max(iterations);
          
          obj.lastPolicies{end + 1} = obj.currentPolicy.copy();
          if (numel(obj.lastPolicies) > obj.numLastPoliciesImportanceSampling)
              obj.lastPolicies = obj.lastPolicies(2:end);
          end  
          
          newData = data.cloneDataSubSet(find(iterationIndex)); 
          importanceWeightsSum = exp(dataProbabilityLog);
          for i = 1:length(obj.lastPolicies)
              dataProbabilityLogLastPolicy = obj.lastPolicies{i}.callDataFunctionOutput('getDataProbabilities', data);
              dataProbability = exp(dataProbabilityLogLastPolicy);
              importanceWeightsSum(end - size(dataProbability,1) + 1:end) = importanceWeightsSum(end - size(dataProbability,1) + 1:end) + dataProbability;
          end          
                                      
          importanceWeights = exp(dataProbabilityLog) ./ importanceWeightsSum;
          importanceWeights(isnan(importanceWeights))=0;
          
          importanceWeights = importanceWeights .* (obj.iterationDiscount .^ abs(iterations - max(iterations)));
          
          importanceWeights = importanceWeights  / sum(importanceWeights);
          
          data.setDataEntry(obj.importanceWeightSumName, importanceWeightsSum);
          data.setDataEntry(obj.importanceWeightName, importanceWeights);
          
          fprintf('Number of Effective Samples: %f\n', 1 / sum(importanceWeights.^2));
      end
   
   end
end
