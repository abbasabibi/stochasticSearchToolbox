classdef EMMixtureModels < Learner.ExpectationMaximization.ExpectationMaximization
    
    properties (SetObservable,AbortSet)
        
    end
    
    properties (SetAccess=protected)
        
        
    end
    
    methods (Static)
        function [EMLearner] = createLearnerSoftMaxGatingLinearPolicies(dataManager, mixtureModel)
            gatingLearner = Learner.ClassificationLearner.MultiClassLogisticRegressionLearner(dataManager, mixtureModel.gating, true); %false or true???
            optionLearner = Learner.SupervisedLearner.LinearGaussianMLLearner(dataManager, mixtureModel.options{1});
            
            mixtureModelLearner = Learner.SupervisedLearner.MixtureModelLearner(dataManager, mixtureModel, optionLearner, gatingLearner, 'responsibilities');
            EMLearner     = Learner.ExpectationMaximization.EMMixtureModels(dataManager, mixtureModel, mixtureModelLearner);
            
        end
    end
    
    
    % Class methods
    methods
        function obj = EMMixtureModels(dataManager, mixtureModel, mixtureModelLearner, varargin)
            obj = obj@Learner.ExpectationMaximization.ExpectationMaximization(dataManager, mixtureModel, mixtureModelLearner, varargin{:});
            
            outputVar   = obj.mixtureModel.getOutputVariable();
            subManager  = dataManager.getDataManagerForEntry(outputVar);
            %             subManager.registerDataEntry(obj.mixtureModelLearner.respName,
            %             obj.mixtureModel.numOptions); Used to be this
            dataManager.addDataEntry(mixtureModelLearner.respName, mixtureModel.numOptions);
            if(isempty(obj.mixtureModel.gating.inputVariables))
                obj.addDataManipulationFunction('computeResponsibilities', {mixtureModel.outputVariable }, {mixtureModelLearner.respName});
            else
                obj.addDataManipulationFunction('computeResponsibilities', {mixtureModel.outputVariable, mixtureModel.inputVariables{:}, mixtureModel.gating.inputVariables{:} }, {mixtureModelLearner.respName});
            end
            
            obj.initLearner       = Learner.SupervisedLearner.InitMMLearner(dataManager, mixtureModelLearner);
        end
        
        function [EMData] = initEMData(obj, data)
            if(isempty(obj.mixtureModel.gating.inputVariables))
                EMData.inputData = [];
            else
                EMData.inputData = data.getDataEntry(obj.mixtureModel.inputVariables{1});
            end
            EMData.outputData = data.getDataEntry(obj.mixtureModel.outputVariable);
            
            EMData.inputDataGating = [];
            if( ~isempty(obj.mixtureModel.gating.inputVariables) )
                EMData.inputDataGating = data.getDataEntry(obj.mixtureModel.gating.inputVariables{1});
            end
            
            if (~isempty(obj.weightName))
                EMData.weighting = data.getDataEntry(obj.weightName{1});
            else
                EMData.weighting = ones(size(EMData.inputData,1),1);
            end
            
        end
        
        
        %
        %         function [EMData] = init(obj, data, EMData)
        %             %Possibly K-Means initialization
        %             %             actionRange = range(data.dataStructure.actions);
        %             %             minAction   = min(data.dataStructure.actions);
        %             %
        %             %             numOptions = obj.dataManager.getMaxRange('options');
        %             %             vars    = bsxfun(@times, eye(size(actionRange,2)), (actionRange/2).^2)/1;
        %             %             means   = mvnrnd(minAction + actionRange/2, vars, numOptions );
        %             %
        %             %             stateRange = range(data.dataStructure.states);
        %             %             minState   = min(data.dataStructure.states);
        %             %
        %             %
        %             %             varsState  = bsxfun(@times, eye(size(stateRange,2)), (stateRange/2).^2)/1;
        %             %             meansState = mvnrnd(minAction + actionRange/2, vars, numOptions );
        %
        %             %             EMData = obj.kMeans(data, EMData);
        %             %             obj.mixtureModelLearner.learnFunction(EMData.inputData, EMData.inputDataGating, EMData.outputData, [],...
        %             %                 EMData.outputDataGating);
        %
        %
        %             %             for o = 1 : numOptions
        %             %                 obj.mixtureModel.getOption(o).setBias(means(o,:)');
        %             %                 obj.mixtureModel.getOption(o).setCovariance(vars);
        %             %             end
        %
        %             obj.initLearner.updateModel(data);
        %
        %         end
        
        
        
        function [responsibilities, respNormalizers] = computeResponsibilities(obj, actions, policyFeatures, gatingFeatures)
            %         obj.mixtureModel.getDataProbabilities()
            %             logQAso = obj.mixtureModel.callDataFunctionOutput('getDataProbabilitiesAllOptions',data);
            if(exist('policyFeatures','var'))
                logQAso = obj.mixtureModel.getDataProbabilitiesAllOptions(policyFeatures, actions);
                qOs   = obj.mixtureModel.gating.getItemProbabilities(size(actions,1),gatingFeatures);
            else
                logQAso = obj.mixtureModel.getDataProbabilitiesAllOptions([], actions);
                qOs   = obj.mixtureModel.gating.getItemProbabilities(size(actions,1));
            end
            
            
            %The itemprobabilities are the (possible state dependent)
            %probabilities of the options. The EM algorithm also works with the
            %state mixture model like that
            %             qOs   = obj.mixtureModel.gating.callDataFunctionOutput('getItemProbabilities',data);
            
            
            
            responsibilities = logQAso + log(qOs);
            respNormalizers  = sum(exp(responsibilities),2);
            
            %substract max, then exp then normalize. This is the most stable
            %version of getting the responsibilities
            responsibilities = bsxfun(@minus, responsibilities, max(responsibilities, [], 2));
            responsibilities = exp(responsibilities );
            responsibilities = bsxfun(@rdivide, responsibilities, sum(responsibilities,2));
        end
        
        function [EMData] = EStep(obj, data, EMData)
            actions = data.getDataEntry(obj.mixtureModel.outputVariable);
            
            if(isempty(obj.mixtureModel.gating.inputVariables))
                [EMData.responsibilities, EMData.respNormalizers] = obj.computeResponsibilities(actions);
            else
                policyFeatures  = data.getDataEntry(obj.mixtureModel.inputVariables{:});
                gatingFeatures  = data.getDataEntry(obj.mixtureModel.gating.inputVariables{:});
                [EMData.responsibilities, EMData.respNormalizers] = obj.computeResponsibilities(actions, policyFeatures, gatingFeatures);
            end
            
            %              obj.callDataFunction('computeResponsibilities', data);
            %             EMData.responsibilities = data.getDataEntry('responsibilities');
            %             EMData.respNormalizers = sum(EMData.responsibilities,2)
            
            
        end
        
        function [] = MStep(obj, data, EMData)
            obj.mixtureModelLearner.learnFunction(EMData.inputData, EMData.inputDataGating, EMData.outputData, [], EMData.responsibilities, EMData.weighting);
        end
        
        function [llh] = getLogLikelihood(obj, EMData)
            llh = sum(log(EMData.respNormalizers) .* EMData.weighting );
        end
        
    end
    
    
end




