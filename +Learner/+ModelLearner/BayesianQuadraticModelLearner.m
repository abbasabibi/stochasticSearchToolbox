classdef BayesianQuadraticModelLearner < Learner.SupervisedLearner.SupervisedLearner
    
    properties(SetObservable, AbortSet)
              
        bayesNoiseSigma =1;
        bayesParametersSigma = 10e-3;
                
    end
    
    
    % Class methods
    methods
        function obj = BayesianQuadraticModelLearner(dataManager, linearfunctionApproximator, varargin)
            
            obj = obj@Learner.SupervisedLearner.SupervisedLearner(dataManager, linearfunctionApproximator, varargin{:});
            
            obj.linkProperty('bayesNoiseSigma');
            obj.linkProperty('bayesParametersSigma');
    
        end
        
        function [features]= getQuadraticFeatures(obj, inputMatrix)
            
            numStates = size ( inputMatrix , 2 );
            numFeatures = 2 * numStates + numStates * (numStates - 1 ) / 2;
            features = zeros(size(inputMatrix,1), numFeatures);
            
            index = 0;
            
            features(:, index +  (1:numStates)) = inputMatrix(:,1:numStates);
            
            index = index + numStates + 1;
            
            for i = 1:numStates
                features(:, index : (index + numStates - i)) = bsxfun(@times, inputMatrix(:, i:numStates), inputMatrix(:, i));
                index = index + numStates - i + 1;
            end
            features = [ones(size(features,1),1), features];
        end
                               
        
        function [parameters] = bayesianParameterUpdate(obj, inputData, outputData, weighting)
            
            
            trainX = inputData;
            trainY = outputData;
            trainXW = bsxfun(@times, trainX, weighting);
         
            tauThetaMat = eye(size(inputData,2)) * obj.bayesParametersSigma;
            tauThetaMat(1,1) = 10^10;
            
            A = ( 1/obj.bayesNoiseSigma ) * ( trainXW'*trainX ) + inv(tauThetaMat);
            parameters = (1/obj.bayesNoiseSigma)*eye(size(A,1)) * (A \ (trainXW' * trainY));
                        
        end        
                
        
        function [] = learnFunction(obj, inputData, outputData, weighting)
                                    
            if (~exist('weighting', 'var'))
                weighting = ones(size(inputData,1),1);
            end
            
            R = zeros (obj.functionApproximator.dimInput,obj.functionApproximator.dimInput);
            r = zeros (1, obj.functionApproximator.dimInput) ;
            bias = zeros (1, 1) ;
            
            trainX = inputData ;
            trainY = outputData ;
                                                      
            quadTrainX = obj.getQuadraticFeatures(inputData);
                               
            parameters = obj.bayesianParameterUpdate(quadTrainX,trainY, weighting);
            bias = parameters(1);
            r(1,:) = parameters (2:obj.functionApproximator.dimInput+1);
                
            AQuadratic = zeros(obj.functionApproximator.dimInput);
            ind = logical(tril(ones(obj.functionApproximator.dimInput)));
            AQuadratic(ind) = parameters(obj.functionApproximator.dimInput+2:end);
            R = (AQuadratic + AQuadratic') / 2;
            assert(not(any(isnan(R(:)))));
            
            obj.functionApproximator.setParameters(R, r, bias);
                        
        end
    end
    
end
