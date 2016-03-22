classdef DistributionPlotterProMP < Evaluator.Evaluator
   
   
    
  
    methods
        function [obj] = DistributionPlotterProMP()
            obj = obj@Evaluator.Evaluator('distMatch', {'afterPreProc'}, Experiments.StoringType.ACCUMULATE);          
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)               
            
            fig1 = figure(1);
            clf;
            fig2 = figure(2);
            clf;
            
            trial.trajectoryGenerator.plotStateDistribution(0, [fig1, fig2]);
            Plotter.PlotterData.plotTrajectoriesMeanAndStd(newData, 'jointPositions', :, [fig1, fig2], {'r', 'LineWidth', 1});
        %    keyboard;
            evaluation = 0;
        end
                
    end   
    
end