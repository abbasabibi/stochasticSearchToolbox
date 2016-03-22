classdef EnvironmentStageTest < Data.DataManipulator
   properties (Access=protected)    
        
   end
   
   methods
       function obj =  EnvironmentStageTest(dataManager)
            obj = obj@Data.DataManipulator(dataManager);
                                                
            obj.addDataManipulationFunction('sampleStageTransition', {'nextStates', 'actions'}, {'nextContexts'});
            
       end
   
       function [nextContexts] = sampleStageTransition(obj, states, actions)
           nextContexts = states;
%            nextContexts = zeros(size(states));
       end     
   end      
   
end