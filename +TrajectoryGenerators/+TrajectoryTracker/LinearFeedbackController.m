classdef LinearFeedbackController < TrajectoryGenerators.TrajectoryTracker.ConstantTrajectoryTracker
        
    properties(SetObservable, AbortSet)    
       dimAction 
       dimState
    end
    
    methods
              
        function obj = LinearFeedbackController (dataManager, numParams) 
            obj = obj@TrajectoryGenerators.TrajectoryTracker.ConstantTrajectoryTracker(dataManager, numParams); 
            
            if(exist('numParams','var'))
                level = obj.dataManager.getDataManagerDepth('steps');
                obj.dataManager.addDataEntryForDepth(level,'parameters', numParams);
            end
            
            obj.dimAction   = dataManager.getNumDimensions('actions');
            obj.dimState    = dataManager.getNumDimensions('states');
            
        end     
              
        function [] = registerTrackingFunction(obj)
            obj.addDataManipulationFunction('getFeedbackControl', {'states', 'parameters'}, {'actions'});
            obj.addDataFunctionAlias('sampleAction','getFeedbackControl');
        end 
        
         
        function actions = getFeedbackControl(obj, states, parameters)
            actions = zeros(size(parameters,1),obj.dimAction);
            
            mu      = parameters(:,1:obj.dimAction);            
            for i = 1 : size(parameters,1)
                F               = reshape(parameters(i,obj.dimAction+1:end), obj.dimAction, obj.dimState);
                actions(i,:)    = mu(i) + F * states(i,:)';
            end
            
                
        end
              
  
        
    end        
    
                  
end