classdef PongPlotterConfigurator < Experiments.Configurator
    
    properties
        evalCriterion
    end
    
    methods
        function obj = PongPlotterConfigurator (evalCriterion)
            obj = obj@Experiments.Configurator('PongPlotter');
            
            obj.evalCriterion = evalCriterion;
            
        end
                
        
        function preConfigureTrial(obj, trial)
        end
        
        function postConfigureTrial(obj, trial)
            plotter = Evaluator.PongPlotter(trial.transitionFunction);
            obj.evalCriterion.registerEvaluator(plotter);
        end
        
    end    
end
