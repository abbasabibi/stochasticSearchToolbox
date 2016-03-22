classdef EMHiREPS < Learner.ExpectationMaximization.ExpectationMaximization
    
    properties (SetObservable,AbortSet)

    end
    properties (SetAccess=protected)
      

    end
    
    % Class methods
    methods
        function obj = EMHiREPS(dataManager, mixtureModel, mixtureModelLearner, varargin)
            obj = obj@Learner.ExpectationMaximization.ExpectationMaximization(dataManager, mixtureModel, mixtureModelLearner, varargin{:});
           
            outputVar   = obj.mixtureModel.getOutputVariable();
            subManager  = dataManager.getDataManagerForEntry(outputVar);
%             subManager.registerDataEntry(obj.mixtureModelLearner.respName,
%             obj.mixtureModel.numOptions); Used to be this
            subManager.addDataEntry(obj.mixtureModelLearner.respName, obj.mixtureModel.numOptions);
            
            
               
        end
                
        
   
      function [] = init(obj, data)
        %Possibly K-Means initialization
        actionRange = range(data.dataStructure.actions);
        minAction   = min(data.dataStructure.actions);
        
        numOptions = obj.dataManager.getMaxRange('options');
        vars    = bsxfun(@times, eye(size(actionRange,2)), (actionRange/2).^2)/1;
        means   = mvnrnd(minAction + actionRange/2, vars, numOptions );
        
        for o = 1 : numOptions
           obj.mixtureModel.getOption(o).setBias(means(o,:)'); 
           obj.mixtureModel.getOption(o).setCovariance(vars);
        end
        
        
      end
      
      function [EMData] = EStep(obj, data)
%         obj.mixtureModel.getDataProbabilities()
        obj.mixtureModel.callDataFunction('getDataProbabilitiesAllOptions',data);
        
        prior = exp(obj.mixtureModelLearner.gatingLearner.functionApproximator.itemProb);
        qSAo = exp(data.dataStructure.logQAsoAllOptions);
        
        
        responsibilities = bsxfun(@times,qSAo,prior); 
        EMData.respNormalizers = sum(responsibilities,2);
        responsibilities = bsxfun(@rdivide, responsibilities, EMData.respNormalizers);
        data.setDataEntry('responsibilities', responsibilities);

        
        
      end
      
      function [] = MStep(obj, data, EMData)
          
          prior = sum(data.dataStructure.responsibilities,1);
          obj.mixtureModelLearner.gatingLearner.functionApproximator.setItemProb(log(prior));
          
          obj.mixtureModelLearner.updateModel(data);
      end
      
      function [llh] = getLogLikelihood(obj, data, EMData)
          llh = sum(log(EMData.respNormalizers) );
      end
      
    end
    
end




