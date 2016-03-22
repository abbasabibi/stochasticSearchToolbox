classdef ExpectationMaximization < Learner.Learner & Data.DataManipulator & Learner.AbstractInputOutputLearnerInterface
    
    properties (SetObservable,AbortSet)
        numIterations           = 1e3;
        
        logLikelihoodThreshold  = 1e-3;
        reinitialize            = false;
        
        initLearner = [];
        
        %         weightName
    end
    
    properties (SetAccess=protected)
        %             dataManager
        mixtureModel
        mixtureModelLearner
        logLikelihood     = inf;
        isInit            = false;
        iterEM            = 1;
        logLikeDifference
        
        analyseModelFunction = [];
    end
    
    % Class methods
    methods
        function obj = ExpectationMaximization(dataManager, mixtureModel, mixtureModelLearner, varargin)
            obj = obj@Learner.Learner(varargin{:});
            obj = obj@Data.DataManipulator(dataManager);
            obj = obj@Learner.AbstractInputOutputLearnerInterface(dataManager, mixtureModel, varargin{:});
            
            obj.linkProperty('numIterations','numIterationsEM');
            obj.linkProperty('logLikelihoodThreshold','logLikelihoodThresholdEM');
            obj.linkProperty('reinitialize','reinitializeEM');
            
            obj.mixtureModel = mixtureModel;
            obj.mixtureModelLearner = mixtureModelLearner;
            %             obj.dataManager = dataManager;
            
            
        end
        
        function [] = analyseModel(obj, data, EMData)
            if (~isempty(obj.analyseModelFunction))
                functionCall  = obj.analyseModelFunction;
                functionCall(obj, data, EMData);
            end
        end
        
        function [] = setAnalyseModelFunction(obj, analyseModelFunction)
            obj.analyseModelFunction = analyseModelFunction;
        end
        
        function [] = setInitLearner(obj, initLearner)
            obj.initLearner = initLearner;
        end
        
        %%
        function [] = updateModel(obj, data)
            EMData = obj.initEMData(data);
            if(~obj.isInit || obj.reinitialize)
                obj.init(data, EMData);
                obj.iterEM              = 1;
                obj.logLikeDifference   = inf;
            end
            
            obj.analyseModel(data, EMData);
            
            
            
            while ( obj.iterEM <= obj.numIterations && (obj.logLikeDifference<0 || obj.logLikeDifference > obj.logLikelihoodThreshold) )
                EMData = obj.EStep(data, EMData);
                
                obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMData);
                
                
                if(obj.iterEM > 1)
                    obj.logLikeDifference = obj.logLikelihood(obj.iterEM) - obj.logLikelihood(obj.iterEM-1);
                end
                
                if(obj.logLikeDifference< -1e-3)
                    warning(['llh diff is negative in EM obj.logLikeDifference=',num2str(obj.logLikeDifference)]);
                end
                
                
                obj.MStep(data, EMData);
                obj.analyseModel(data, EMData);
                
                
                msg = 'Iteration: ';
                fprintf('%50s %.3g\n', msg, obj.iterEM);
                msg = 'Log Likelihood: ';
                fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                
                obj.iterEM = obj.iterEM + 1;
                
                EMDataLLH = EMData;
                
                
                %             obj.MStep(data, EMData, 1);
                %             EMDataLLH = obj.EStep(data, EMDataLLH);
                %             obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                %             msg = 'Log Likelihood After Sub-Policy Update: ';
                %             fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                %
                %             obj.MStep(data, EMData, 2);
                %             EMDataLLH = obj.EStep(data, EMDataLLH);
                %             obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                %             msg = 'Log Likelihood After Sub-Policy Update: ';
                %             fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                
                
                continue
                
                obj.MStep(data, EMData, 1);
                EMDataLLH = obj.EStep(data, EMDataLLH);
                obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                msg = 'Log Likelihood After Termination Update: ';
                fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                
                obj.MStep(data, EMData, 2);
                EMDataLLH = obj.EStep(data, EMDataLLH);
                obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                msg = 'Log Likelihood After Gating Update: ';
                fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                
                obj.MStep(data, EMData, 3);
                EMDataLLH = obj.EStep(data, EMDataLLH);
                obj.logLikelihood(obj.iterEM) = obj.getLogLikelihood(EMDataLLH);
                msg = 'Log Likelihood After Sub-Policy Update: ';
                fprintf('%50s %.4g\n', msg, obj.logLikelihood(obj.iterEM));
                
                
                
            end
            %           obj.logLikeDifference;
        end
        
        
        function [] = setWeightName(obj, weightName)
            obj.setWeightName@Learner.AbstractInputOutputLearnerInterface(weightName);
            
            obj.mixtureModelLearner.setWeightName(weightName);
            if (~isempty(obj.initLearner))
                obj.initLearner.setWeightName(weightName);
            end
        end
        
        function [] = init(obj, data, EMData)
            if (~isempty(obj.initLearner))
                obj.initLearner.updateModel(data);
            end
        end
        
    end
    
    methods (Abstract)
        
        
        [EMData] = initEMData(obj, data)
        
        [EMData] = EStep(obj, data, EMData);
        
        [] = MStep(obj, data, EMData);
        
        [llh] = getLogLikelihood(obj, EMData);
        
    end
    
end
