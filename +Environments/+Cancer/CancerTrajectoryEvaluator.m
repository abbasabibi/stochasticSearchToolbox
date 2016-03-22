classdef CancerTrajectoryEvaluator < Common.IASObject & Data.DataManipulator
    
    properties
                       
    end
    
    methods
        function obj = CancerTrajectoryEvaluator(episodeSampler)
           obj = obj@Common.IASObject();
           obj = obj@Data.DataManipulator(episodeSampler.getDataManagerForSampler());
           
           obj.dataManager.addDataEntry('cancerEval', 3);
           
           obj.addDataManipulationFunction('evalFunction', {'states','nextStates'}, {'cancerEval'}, false);
        end                     
        
        function [cancerEval] = evalFunction(obj, states, nextStates)
            allStates = [states(1,:);nextStates];
            cancerEval = [nextStates(end,1),max(allStates(:,2)),max(nextStates(:,3))];
        end
    end
end