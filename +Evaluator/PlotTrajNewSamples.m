classdef PlotTrajNewSamples < Evaluator.Evaluator
   
   
    
  
    methods
        function [obj] = PlotTrajNewSamples ()
            obj = obj@Evaluator.Evaluator('plot', {'endLoop'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            figure(19)
            clf            
            subplot(2,1,1)
            hold on
            for i =1 :  newData.dataStructure.numElements
                tmp = newData.getDataEntry('jointPositions', i, :); 
                plot(newData.getDataEntry('jointPositions', i, :))
            end
            subplot(2,1,2)
            hold on
            for i =1 :  newData.dataStructure.numElements
                plot(newData.getDataEntry('referencePos', i, :))
            end
            pause(0.2);
            evaluation = 0;
        end
                
    end   
    
end