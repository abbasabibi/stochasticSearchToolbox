classdef KernelRegression < Learner.SupervisedLearner.SupervisedLearner
    %KernelRegression Perform kernel regression with optimized hyperparameters
    % Learns kernel hyperparameters by optimizing prediction accuracy
    
    properties
        kernel
        initialParameters
        
        inverseGrammian
        referenceInputs
        referenceOutputs
        referenceOutputsStart
        
        
        isDiscounted
        outputVariableIfDiscounted
        
        featureTag=1
    end
    
    properties(SetObservable,AbortSet)
        resetProbTimeSteps = 0.1
    end
    
    methods
        function obj = KernelRegression(dataManager,kernel, inputVariables, outputVariable, settingsParameterName, outputVariableIfDiscounted)
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, {}, {}, inputVariables, outputVariable);
            obj.kernel = kernel;
            
            obj.linkProperty('initialParameters', settingsParameterName);
            

            if(exist('variableIfDiscounted','var') && ~isempty(outputVariableIfDiscounted))
                
                obj.linkProperty('resetProbTimeSteps');
                obj.isDiscounted = true;
                obj.outputVariableIfDiscounted = outputVariableIfDiscounted;
            else
                obj.isDiscounted = false;
            end
                
        end
        
        function [features] = getFeaturesInternal(obj, numFeatures, inputMatrix)
            inputVectors = obj.kernel.getGramMatrix(obj.referenceInputs, inputMatrix ); 

            m = size(obj.referenceInputs,1);


            cond_embed = obj.invGrammian * inputVectors; 
            
            if(obj.isDiscounted)
                m1 = size(obj.referenceInputsStart,2);
                n = size(inputMatrix,1);
                gamma = 1-obj.resetProbTimeSteps;
                features = gamma * obj.referenceOutputs * cond_embed + (1-gamma) /m1 * obj.referenceOutputsStart*ones(m1,n);
            else
                features = obj.referenceOutputs * cond_embed;
            end
    

            if(size(features,2) > obj.getNumFeatures())
                warning('RKHSModelLearner_unc:numFeatures','amount of features not supported')
                features = features(1:obj.getNumFeatures(),:)';
            else
                zerofeatures = zeros(size(inputMatrix,1), obj.getNumFeatures()-size(features,1));
                features = [features', zerofeatures];
            end
        end
        

     
        function objective = optimizationObjective(obj, data, logparams)
            n_episodes = data.getDataStructure.numElements;
            n_samples = data.getDataStructure.steps.numElements;
            objective = 0;
            obj.kernel.setHyperParameters(exp(logparams));

            for i = 1:2
                train_start = i;
                val_start = mod(i,2)+1;
                if(n_episodes ==1)
                    train_idx = {1, train_start:2:n_samples};
                    val_idx = {1, val_start:2:n_samples};
                else
                    train_idx = {train_start:2:n_episodes};
                    val_idx = {val_start:2:n_episodes};                        
                end
                
                train_in = cell2mat(data.getDataEntryCellArray(obj.inputVariables, train_idx{:})); %input train
                val_in =  cell2mat(data.getDataEntryCellArray(obj.inputVariables, val_idx{:})); %input validate

                val_out =data.getDataEntry(obj.outputVariable, val_idx{:}); % output validate
                train_out = data.getDataEntry(obj.outputVariable, train_idx{:}); %output train


                
                kf = @(s1,s2) obj.kernel.getGramMatrix(s1,s2);
                locallambda = exp(logparams(1));

                Kt_in = kf(train_in, train_in);
                Ktv_in = kf(train_in, val_in);


                wts = (Kt_in + locallambda * eye(size(Kt_in))) \ Ktv_in;


                pred_output = wts'*train_out;
                true_output = val_out;
                prediction_error = pred_output - true_output;
                foldobjective = sum(sum(prediction_error.^2));
                
                objective = objective + foldobjective;
            end
        end

        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.featureTag;
        end
     
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end
        
        function updateModel(obj, data)
             obj.featureTag = obj.featureTag + 1; 
            inputData = cell2mat(data.getDataEntryCellArray(obj.inputVariables));
            outputData = data.getDataEntry(obj.outputVariable); 
            obj.referenceInputs = inputData;
            obj.referenceOutputs = outputData;            
            if(obj.isDiscounted)
                obj.referenceOutputsStart = data.getDataEntry(obj.outputVariableIfDiscounted,:,1);
            end
            
            if(any(obj.initialParameters < 0))
                
                lparamsopt = log(obj.initialParameters);
                tooptimize = find(obj.initialParameters < 0);

                linitparams = log(-obj.initialParameters(tooptimize)); 
         
                getparams = @(params) Experiments.test.mergeVectors(lparamsopt, params, tooptimize );
                %if(obj.usetomlab)
                %    Prob = ProbDef; 
                %    Prob.Solver.Tomlab = 'ucSolve';
                %    lparamsopt = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params)), linitparams,[],Prob );
                %else
                    lparamsopt = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params)), linitparams );
                %end
                paramsopt = exp(getparams(lparamsopt));
            else
                paramsopt = obj.initialParameters;
            end
            obj.kernel.setHyperParameters(paramsopt);

        end
        
        function learnFunction( ~, ~)
            error('use updateModel instead')
        end
    
    end
    
end

