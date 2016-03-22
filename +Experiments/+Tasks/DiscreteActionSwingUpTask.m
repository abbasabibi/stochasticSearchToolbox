classdef DiscreteActionSwingUpTask < Experiments.Tasks.SwingUpTask
    
    properties
        
    end
    
    methods
        function obj = DiscreteActionSwingUpTask(isInfiniteHorizon)
            obj = obj@Experiments.Tasks.SwingUpTask(isInfiniteHorizon);
        end
        
        function setupEnvironment(obj, trial)
            obj.setupEnvironment@Experiments.Tasks.SwingUpTask(trial);
            
            trial.setprop('discreteActions', Environments.DiscreteActionGenerator(trial.dataManager,trial.transitionFunction));
        end
    end
    
end

