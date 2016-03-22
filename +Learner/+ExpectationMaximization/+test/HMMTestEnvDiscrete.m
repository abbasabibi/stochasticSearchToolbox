classdef HMMTestEnvDiscrete < Data.DataManipulator
   properties (Access=protected)  
        dimContext = 1;
        dimAction = 1;
        dimState = 1;
        
        numStates = 3;
   end
   
   methods
       function obj =  HMMTestEnvDiscrete(dataManager)
            obj = obj@Data.DataManipulator(dataManager);
            
            subDataManager = dataManager.getSubDataManager();
            
            dataManager.addDataEntry('contexts', obj.dimContext, -ones(obj.dimContext,1), ones(obj.dimContext,1));
            dataManager.addDataEntry('returns', 1, -ones(obj.dimContext,1), ones(obj.dimContext,1));
                       
            subDataManager.addDataEntry('actions', obj.dimAction, -ones(obj.dimAction,1), ones(obj.dimAction,1));
            subDataManager.addDataEntry('states', obj.dimState, -ones(obj.dimState,1), ones(obj.dimState,1));
            subDataManager.addDataEntry('nextStates', obj.dimState, -ones(obj.dimState,1), ones(obj.dimState,1));
            subDataManager.addDataEntry('rewards', 1, -ones(1,1), ones(1,1));
            subDataManager.addDataEntry('terminations', 1, 1, 2);
            
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleAction', {'states'}, {'actions'});            
            obj.addDataManipulationFunction('sampleNextState', {'states', 'actions'}, {'nextStates'});            
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'states', 'actions', 'nextStates'}, {'rewards'});
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
            
       end
      
       function [context] = sampleContext(obj, numElements)
           context = randi(obj.numStates, numElements, obj.dimContext) + obj.dataManager.getMinRange('contexts') -1;
       end
       
       function [initialState] = sampleInitState(obj, context)
           initialState = context(:, 1:obj.dimState);
       end
       
       function [action] = sampleAction(obj, state)
            action = randn(size(state,1) , obj.dimAction);
       end
       
       function [nextState] = sampleNextState(obj, state, action)
                        
            actionEffect = [1,0,-1];
            minState = obj.dataManager.getMinRange('states');
            maxState = obj.dataManager.getMaxRange('states');
            nextState = state + actionEffect(action)';
            nextState = max(min(nextState, maxState), minState);
       end
       
       
       function [reward] = sampleReward(obj, context, state, action, nextState)
           reward = -sum(state.^2, 2) - sum(action.^2,2);
       end
               
   end
         
end