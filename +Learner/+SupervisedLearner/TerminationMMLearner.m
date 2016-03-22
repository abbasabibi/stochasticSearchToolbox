classdef TerminationMMLearner < Learner.SupervisedLearner.MixtureModelLearner
    
    properties (SetObservable,AbortSet)
    end
    
    properties (SetAccess=protected)
      terminationLearner      
    end
    
    % Class methods
    methods
        function obj = TerminationMMLearner(dataManager, mixtureModel, mixtureComponentLearner, gatingLearner, terminationLearner, respName, varargin)
            obj = obj@Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, ...
                mixtureComponentLearner, gatingLearner, respName, varargin);
            obj.terminationLearner = terminationLearner;
            
            
            %What's the difference between setInput and setAdditionalInput?
            obj.setAdditionalInputArguments(obj.respName, obj.functionApproximator.terminationName); %which one?  
%             obj.setAdditionalInputArguments(obj.respName, obj.terminationLearner.outputVariable);
            obj.setInputVariablesForLearner(mixtureModel.inputVariables, mixtureModel.gating.inputVariables, ...
                mixtureModel.terminationMM.inputVariables); 
                   
        end
        
        %%
        function [] = learnFunction(obj, inputData, inputDataGating, inputDataTermination, ...
                outputData, optionsOld, outputDataGating, outputDataTermination, ...
                weightsPolicy, weightsGating, weightsTermination, weighting, varargin)
            
            if (~exist('weighting', 'var') || isempty(weighting) )
                weighting = ones(size(outputDataGating));
            end
            
            if(~exist('weightsPolicy', 'var') || size(weightsPolicy,2) ~= size(outputDataGating,2) )
%                 weightsPolicy = ones(size(inputData,1),obj.functionApproximator.numOptions);
                weightsPolicy = outputDataGating;
            end
            if(~exist('weightsGating', 'var'))
                weightsGating = [];
            end
            if(~exist('weightsTermination', 'var'))
                weightsTermination = ones(size(inputData,1),obj.functionApproximator.numOptions);
            end
            
            
            
            if(isempty(varargin))
                updateIdx = 0;
            else
                updateIdx = varargin{1};
            end
            
            %I think this can only be active if o == optionsOld. Probably
            %we fix this through the weights.
            
            %Temporary workaround, framework would expect that
            %outputDataTermination is 1D, but we kinda need it to have dim
            %= numOptions
            if(updateIdx ==0 || updateIdx == 1)
            if(~isempty(inputDataTermination) && size(outputDataTermination,2) == obj.functionApproximator.numOptions) 
                for o = 1 : obj.functionApproximator.numOptions
                    obj.terminationLearner.setFunctionApproximator(obj.functionApproximator.terminationMM.getTerminationOption(o) );
                    obj.terminationLearner.learnFunction(inputDataTermination, outputDataTermination(:,o), weightsTermination(:,o));
                end
            end
            end
            

            if(updateIdx ==0 || updateIdx == 2)
                obj.gatingLearner.learnFunction(inputDataGating, outputDataGating, weightsGating);
            end
            
            
            if(updateIdx ==0 || updateIdx == 3)
                for o = 1 : obj.functionApproximator.numOptions
                    if(sum(weightsPolicy(:,o)) > 0 ) %used to be > 1
                        obj.mixtureComponentLearner.setFunctionApproximator(obj.functionApproximator.getOption(o)); %this gets an option from the MM and sets it as active for the learner
                        obj.mixtureComponentLearner.learnFunction(inputData, outputData, weightsPolicy(:,o) );
                    else
                        %                     keyboard;
                    end
                end
            end
            
            
%          learnFunction@Learner.SupervisedLearner.MixtureModelLearner(obj, inputData, inputDataGating, outputData, options, responsibilities, weighting);
            obj.plotFunction(inputData, inputDataGating, outputData, [], outputDataGating, weighting);
            
        end
    end
    
end
