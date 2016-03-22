classdef TransitionContextSampler < Data.DataManipulator
    properties (Access=protected)
        resampleIdx
        contextSampler
    end
    
    methods
        function obj =  TransitionContextSampler(dataManager, resampleIdx, contextSampler )
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.resampleIdx     = resampleIdx;
            obj.contextSampler  = contextSampler;
            
            obj.addDataManipulationFunction('sampleStageTransition', {'nextStates', 'actions'}, {'nextContexts'});
            
        end
        
        function [nextContexts] = sampleStageTransition(obj, states, actions)
            sampledContexts = obj.contextSampler.sampleContext(size(states,1));
            nextContexts = states;
            nextContexts(:,obj.resampleIdx) = sampledContexts(:,obj.resampleIdx);
            %            nextContexts = zeros(size(states));
        end
    end
    
end