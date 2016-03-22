classdef EnvironmentTest < Data.DataManipulator
   properties (Access=protected)  
        numContext = 2;
        numAction = 5;
        
   end
   
   methods
       function obj =  EnvironmentTest(dataManager, numContext, numAction)
            obj = obj@Data.DataManipulator(dataManager);
            
            if exist('numContext', 'var')
                obj.numContext = numContext;
            end
            
            if exist('numAction', 'var')
                obj.numAction = numAction;
            end
            
            
            dataManager.addDataEntry('contexts', obj.numContext, -ones(1, obj.numContext), ones(1, obj.numContext));
            dataManager.addDataEntry('rewards', 1, -ones(1,1), ones(1,1));
            dataManager.addDataEntry('parameters', obj.numAction, -ones(obj.numAction,1), ones(obj.numAction,1));
            
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleAction', {'contexts'}, {'parameters'});
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'parameters'}, {'rewards'});
            
            obj.addDataFunctionAlias('sampleParameter', 'sampleAction');
            obj.addDataFunctionAlias('sampleReturn', 'sampleReward');
       end
   
       function [context] = sampleContext(obj, numElements)
           context = randn(numElements, obj.numContext);
       end
       
       function [action] = sampleAction(obj, context)
            action = randn(size(context, 1), obj.numAction);
       end
       
       function [reward] = sampleReward(obj, context, action)
           reward = randn(size(context,1),1);
       end
           
   end
   
   
   
end