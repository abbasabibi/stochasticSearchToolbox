classdef ProMPDistributionLearner < Experiments.Configurator;
    
    properties(SetAccess=protected)
        type;
        
       
    end
    
    methods
        
        function obj = ProMPDistributionLearner()
            obj = obj@Experiments.Configurator('ProMPLearner');
        end              
                
        function preConfigureTrial(obj, trial)               
            trial.setprop('policyLearner', @TrajectoryGenerators.ImitationLearning.ParameterDistributionImitationLearner.createFromTrial);
        end
        
        function postConfigureTrial(obj, trial)
            
            obj.setupLearner(trial);
        end
        
        function setupLearner(obj, trial)
            trial.policyLearner=trial.policyLearner(trial);
        end
        
        function setupScenarioForLearners(obj, trial)
            
            if (~isempty(trial.learner))
                trial.scenario.addInitObject(trial.policyLearner); 
            end
        end               
        

    end
        
end

