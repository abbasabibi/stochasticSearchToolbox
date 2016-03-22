classdef EnvironmentSequentialTest < Data.DataManipulator
   properties (Access=protected)  
        numContext = 5;
        numAction = 2;
        numState = 4;
   end
   
   methods
       function obj =  EnvironmentSequentialTest(dataManager1, dataManager2)
            obj = obj@Data.DataManipulator(dataManager1);
            
            dataManager1.addDataEntry('contexts', obj.numContext, -ones(obj.numContext,1), ones(obj.numContext,1));
            dataManager1.addDataEntry('returns', 1, -ones(obj.numContext,1), ones(obj.numContext,1));
                       
            dataManager2.addDataEntry('actions', obj.numAction, -ones(obj.numAction,1), ones(obj.numAction,1));
            dataManager2.addDataEntry('states', obj.numState, -ones(obj.numState,1), ones(obj.numState,1));
            dataManager2.addDataEntry('nextStates', obj.numState, -ones(obj.numState,1), ones(obj.numState,1));
            dataManager2.addDataEntry('rewards', 1, -ones(1,1), ones(1,1));
            
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleAction', {'states'}, {'actions'});            
            obj.addDataManipulationFunction('sampleNextState', {'states', 'actions'}, {'nextStates'});            
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'states', 'actions', 'nextStates'}, {'rewards'});
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
            
            
            
       end
   
       function [context] = sampleContext(obj, numElements)
           context = randn(numElements, obj.numContext);
       end
       
       function [initialState] = sampleInitState(obj, context)
           initialState = context(:, 1:obj.numState);
       end
       
       function [action] = sampleAction(obj, state)
            action = randn(size(state,1) , obj.numAction);
       end
       
       function [nextState] = sampleNextState(obj, state, action)
            nextState = state;
            nextState(:, 1:obj.numAction) = action;
       end
       
       
       function [reward] = sampleReward(obj, context, state, action, nextState)
           reward = -sum(state.^2, 2) - sum(action.^2,2);
       end
               
   end
         
end