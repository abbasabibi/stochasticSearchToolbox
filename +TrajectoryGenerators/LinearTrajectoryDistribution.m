classdef LinearTrajectoryDistribution < StateDistributions.Distribution
  properties
    
      weightDistribution
      trajectoryGenerator 
      trajectoryWeights
  end
  
  methods
    function obj = LinearTrajectoryDistribution(settings, trajectoryGenerator)
      
       
        
      superargs = {};
      if(nargin > 0 )
        superargs = {settings, 'q', 'trajectoryWeightDistribution'};
      end
      obj = obj@StateDistributions.Distribution(superargs{:});
        
       
      if(nargin > 0 )
          
          obj.trajectoryGenerator = trajectoryGenerator;
          obj.weightDistribution = StateDistributions.GaussianDistribution(settings, 'trajectoryWeights', 'weightDistribution');
          obj.initModel(settings);
      end      
      
    end
    
    function obj = initModel(obj, settings)
        settings.addVariable('trajectoryWeights', obj.trajectoryGenerator.dimParameters, obj.trajectoryGenerator.minRangeAction, obj.trajectoryGenerator.maxRangeAction);
        
        obj.initModel@StateDistributions.Distribution(settings); 
        obj.weightDistribution.initModel(settings);              
      
    end
    
    function obj = updateModel(obj, data)
        data.trajectoryWeights = zeros(length(data.(obj.outputVariables{1})), obj.trajectoryGenerator.dimParameters);
        %figure;
        %hold all;
        for i = 1:length(data.(obj.outputVariables{1}))
            obj.settings.setParameter('tau', 1 / (size(data.q{i}, 1)) * size(data.q{1},1));
            obj.trajectoryGenerator.learnTrajectoryFromImitation(data, i);
            
            data.trajectoryWeights(i, :) = obj.trajectoryGenerator.getCurrentParameters();
            %plot(data.q{i}(:, 1), 'b');
            %plot(obj.trajectoryGenerator.generateTrajectory(), 'g');
        end
        obj.weightDistribution.updateModel(data);
        obj.trajectoryWeights = data.trajectoryWeights;
    end    
    
    function newObj = conditionOnTrajectory(obj, data, conditionalVariables, conditionalSigma)
        features = obj.trajectoryGenerator.getMultiOutputTrajectoryFeatures(data, conditionalVariables);
        targetVector = obj.trajectoryGenerator.getMultiOutputTargetFunctionData(data, conditionalVariables);
        
 
        numTargets = length(targetVector);
        A = diag(repmat(conditionalSigma, 1, numTargets)) + features * obj.weightDistribution.Sigma * features';
        
        Mu = obj.weightDistribution.Mu;
        Sigma = obj.weightDistribution.Sigma;
        
        newMeanWeights = Mu + Sigma * features' * (A \ (targetVector -  features * Mu));
        newCovWeights = Sigma - Sigma * features' * (A \ features * Sigma);
        
        if (nargout == 0)
            obj.weightDistribution.setDistribution(newMeanWeights, newCovWeights, 1);
        else
            newObj = obj.clone();
            newObj.weightDistribution.setDistribution(newMeanWeights, newCovWeights, 1);
        end
    end
    
    function [newObj] = clone(obj)
        newObj = obj.clone@StateDistributions.Distribution();
        newObj.weightDistribution = obj.weightDistribution.clone();
        
    end            
    
    function q = sampleFunc(obj, outputVariable, varargin)
        weights = obj.weightDistribution.sampleFunc('trajectoryWeights');
        outputVars = obj.trajectoryGenerator.getTrajectory([], [], weights);
        q = outputVars{1};
    end
    
    
  end
end