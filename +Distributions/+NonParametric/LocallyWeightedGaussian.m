classdef LocallyWeightedGaussian < Distributions.DistributionWithMeanAndVariance & Functions.Mapping & Functions.Function
    % LocallyWeightedGaussian 
    % regressor that works by locally fitting a gaussian. 
    % importance weights can be given as well (the weights are multiplied
    % with the locality weighting).
    
    properties(SetObservable, AbortSet)
        initSigma = 1;
    end
    
    properties
        trainingInput
        trainingOutput
        weighting
        
        kernel;
        
        learner
        distribution
        
    end
    
    methods
        function obj = LocallyWeightedGaussian(dataManager, kernel, varOut, varIn)

            obj = obj@Distributions.DistributionWithMeanAndVariance();
            obj = obj@Functions.Mapping(dataManager, varOut, varIn, 'locallyWeightedGaussian');
            obj.distribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, varOut, varIn, 'localGaussian');
            obj.learner = Learner.SupervisedLearner.LinearGaussianMLLearner( ...
                dataManager, obj.distribution);
            obj.kernel = kernel;

            obj.linkProperty('initSigma', ['initSigma', upper(obj.outputVariable(1)), obj.outputVariable(2:end)]);

            obj.registerMappingInterfaceDistribution();
            
        end
        

        
        function loglikelihood = likelihood(obj, valInput, valOutput, weighting, params)
            obj.kernel.setHyperParameters(params); % not the nicest solution...
            probs = getDataProbabilities(obj, valInput, valOutput);
            loglikelihood = probs'*weighting;
        end
        
        function [mean] = getExpectation(obj, ~, inputData)

            mean = zeros(size(inputData,1 ),size(obj.trainingOutput,2));
            
            
            if(size(obj.trainingOutput,1)==0)
                % no training set given, random policy              
                range = obj.dataManager.getRange(obj.outputVariable);
                mean = zeros(size(range));
            else
                if(isempty(obj.weighting))
                    obj.weighting = ones(size(obj.trainingInput,1),1);
                end
                for i = 1:size(inputData,1)

                    currentInput = inputData(i,:);
                    localweighting =  obj.weighting .* obj.kernel.getGramMatrix(obj.trainingInput, currentInput);
                    localweighting = localweighting / max(localweighting);
                    idxs = localweighting > 1e-3;

                    input = obj.trainingInput(idxs, :);
                    output = obj.trainingOutput(idxs,:);
                    localweighting = localweighting(idxs,:);

                    obj.learner.learnFunction(input, output, localweighting);

                    [localmean, ~] = obj.distribution.getExpectationAndSigma(1, currentInput);

                    mean(i,:) = localmean;


                end
            end        
        end
        

        function [mean, sigma] = getExpectationAndSigma(obj, ~, inputData)

            mean = zeros(size(inputData,1 ),size(obj.trainingOutput,2));
            sigma = zeros(size(inputData,1 ), size(obj.trainingOutput,2),size(obj.trainingOutput,2));
            
            if(size(obj.trainingOutput,1)==0)
                % no training set given, random policy
                
                range = obj.dataManager.getRange(obj.outputVariable);
            
                sigma = diag(range .* obj.initSigma);
                mean = zeros(size(range));
            else
                if(isempty(obj.weighting))
                    obj.weighting = ones(size(obj.trainingInput,1),1);
                end
                for i = 1:size(inputData,1)

                    currentInput = inputData(i,:);
                    localweighting =  obj.weighting .* obj.kernel.getGramMatrix(obj.trainingInput, currentInput);
                    localweighting = localweighting / max(localweighting);
                    idxs = localweighting > 1e-3;

                    input = obj.trainingInput(idxs, :);
                    output = obj.trainingOutput(idxs,:);
                    localweighting = localweighting(idxs,:);

                    obj.learner.learnFunction(input, output, localweighting);

                    [localmean, localsigma] = obj.distribution.getExpectationAndSigma(1, currentInput);

                    mean(i,:) = localmean;
                    sigma(i,:,:) = localsigma;

                end
            end
            
        end

    end
    
end

