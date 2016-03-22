classdef DataProbabilitiesPreprocessor < DataPreprocessors.DataPreprocessor
    
   properties
      distribution;
      learner
      dataFunctionName
   end
   
   % Class methods
   methods
      function obj = DataProbabilitiesPreprocessor(dataManager, distribution, learner, dataFunctionName)
            obj = obj@DataPreprocessors.DataPreprocessor();
            
            obj.distribution = distribution;
            if (exist('learner', 'var'))
                obj.learner = learner;
            else
                obj.learner = [];
            end
            
            if(~exist('dataFunctionName', 'var') || isempty(dataFunctionName))
                obj.dataFunctionName = 'getDataProbabilities';
            else
                obj.dataFunctionName = dataFunctionName;
            end
            
            depth = dataManager.getDataEntryDepth(distribution.outputVariable);
            layerName = dataManager.getDataManagerForDepth(depth).getManagerName();
            distribution.registerProbabilityNames(dataManager, layerName);
            
      end 
            
      function data = preprocessData(obj, data)          
          
          if (~isempty(obj.learner))
              if (obj.learner.isWeightedLearner())
                  weightName = obj.learner.getWeightName();
                  depth = data.dataManager.getDataEntryDepth(weightName);
                  numElements = data.getNumElementsForDepth(depth);
                  
                  data.setDataEntry(obj.learner.getWeightName(), ones(numElements, 1));                  
              end
              obj.learner.updateModel(data);
          end
          
          obj.distribution.callDataFunction(obj.dataFunctionName, data);
          
          
      end
   
   end
end
