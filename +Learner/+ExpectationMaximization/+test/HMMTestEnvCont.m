classdef HMMTestEnvCont < Data.DataManipulator
   properties (Access=protected)  
        dimContext = 2;
        dimAction = 1;
        dimState = 2;
        
        mixtureModel
   end
   
   methods
       function obj =  HMMTestEnvCont(dataManager, mixtureModel)
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.mixtureModel = mixtureModel;
            
            subDataManager = dataManager.getSubDataManager();
            
            dataManager.addDataEntry('contexts', obj.dimContext, -ones(obj.dimContext,1), ones(obj.dimContext,1));
            dataManager.addDataEntry('returns', 1, -ones(obj.dimContext,1), ones(obj.dimContext,1));
                       
            subDataManager.addDataEntry('actions', obj.dimAction, -ones(obj.dimAction,1), ones(obj.dimAction,1));
            subDataManager.addDataEntry('states', obj.dimState, -ones(obj.dimState,1), ones(obj.dimState,1));
            subDataManager.addDataEntry('nextStates', obj.dimState, -ones(obj.dimState,1), ones(obj.dimState,1));
            subDataManager.addDataEntry('rewards', 1, -ones(1,1), ones(1,1));
%             subDataManager.addDataEntry('terminations', 1, 1, 2); 
            
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
%             obj.addDataManipulationFunction('sampleAction', {'states'}, {'actions'});            
            obj.addDataManipulationFunction('sampleNextState', {'states', 'actions'}, {'nextStates'});            
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'states', 'actions', 'nextStates'}, {'rewards'});
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
            
       end
      
       function [context] = sampleContext(obj, numElements)
           context = bsxfun(@plus, rand(numElements, obj.dimContext), obj.dataManager.getMinRange('contexts') -1);
       end
       
       function [initialState] = sampleInitState(obj, context)
           initialState = context(:, 1:obj.dimState);
       end
       
%        function [actions] = sampleAction(obj, states)
% %             action = randn(size(state,1) , obj.dimAction);
%             actions = obj.mixtureModel.sampleFromDistribution(states);
% 
%        end
       
       function [nextStates] = sampleNextState(obj, states, actions)
            
           nextStates(:,1) = max(min(states(:,1) + 1 * actions(:,1), 2), -2);
           nextStates(:,2) = max(min(states(:,2) + 1 * states(:,1),8),-8);
            
       end
       
       
       function [reward] = sampleReward(obj, context, state, action, nextState)
           reward = -sum(state.^2, 2) - sum(action.^2,2);
       end
               
   end
         
end