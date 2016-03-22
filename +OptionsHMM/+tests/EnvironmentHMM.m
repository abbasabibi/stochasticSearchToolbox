classdef EnvironmentHMM < Environments.TransitionFunction
  %ENVIRONMENTHMM Summary of this class goes here
  %   Detailed explanation goes here
  
  properties    
  end
  
  methods
    function obj = EnvironmentHMM(rootSampler)
      obj = obj@Environments.TransitionFunction(rootSampler, 2, 2);
      obj.dataManager.addDataEntry('contexts', 2, [-3 -3], [3, 3]);

    end
    
    function [nextStates] = transitionFunction(obj, states, actions)
      nextStates(:,1)   = max(min(states(:,1) + 0.2 * actions(:,1), 2), -2);
      nextStates(:,2)   = max(min(states(:,2) + 0.9 * states(:,1),8),-8); %Go up ob right side, down on left side
    
    end

  end
  
end

