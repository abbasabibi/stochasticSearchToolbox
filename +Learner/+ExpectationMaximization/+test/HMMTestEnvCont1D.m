classdef HMMTestEnvCont1D < Data.DataManipulator
   properties (Access=protected)  
        dimContext = 1;
        dimAction = 1;
        dimState = 1;
        
        mixtureModel
   end
   
   methods
       function obj =  HMMTestEnvCont1D(dataManager, mixtureModel)
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.mixtureModel = mixtureModel;
            
            subDataManager = dataManager.getSubDataManager();
            
            dataManager.addDataEntry('contexts', obj.dimContext, -ones(obj.dimContext,1), ones(obj.dimContext,1));
            dataManager.addDataEntry('returns', 1, -ones(obj.dimContext,1), ones(obj.dimContext,1));
                       
            subDataManager.addDataEntry('actions', obj.dimAction, -ones(obj.dimAction,1), ones(obj.dimAction,1));
            subDataManager.addDataEntry('states', obj.dimState, -ones(obj.dimState,1), ones(obj.dimState,1));
            subDataManager.addDataEntry('nextStates', obj.dimState, -ones(obj.dimState,1), ones(obj.dimState,1));
            subDataManager.addDataEntry('rewards', 1, -ones(1,1), ones(1,1));
            subDataManager.addDataEntry('terminations', 1, 1, 2);
            
            
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
            
%            nextStates   = (rand(size(states))-0.5) * 20;
           nextStates(:,1) = max(min(states(:,1) + 0.5 * actions(:,1), 10), -10);
%            nextStates(:,2) = max(min(states(:,2) + 4 * states(:,1),8),-8);
            
       end
       
       
       function [reward] = sampleReward(obj, context, state, action, nextState)
           reward = -sum(state.^2, 2) - sum(action.^2,2);
       end
               
   end
         
end