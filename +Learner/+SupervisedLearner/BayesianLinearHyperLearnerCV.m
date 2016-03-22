classdef BayesianLinearHyperLearnerCV < Learner.SupervisedLearner.BayesianLinearHyperLearner
    % Cross-validation to determine parameters for bayesian linear model
    
    properties
        validationSetIndices
        CVtype
    end
    
   
    
    methods
        function obj = BayesianLinearHyperLearnerCV(dataManager, learner)
            obj = obj@Learner.SupervisedLearner.BayesianLinearHyperLearner(dataManager, learner);
            obj.CVtype = 'trajectory';
        end
        
        function [] = processTrainingData(obj, data)
            obj.processTrainingData@Learner.SupervisedLearner.BayesianLinearHyperLearner(data);
           
            numPoints = sum(cat(1, data.getDataStructureForLayer(2).numElements ));
            switch(obj.CVtype)
                case 'trajectory'
                    n_samples_per_episode = cat(1, data.getDataStructureForLayer(2).numElements );
                    n_episodes = data.getDataStructure.numElements;
                    episode_per_sample = cell2mat(arrayfun(@(n,i) repmat(i,n,1), n_samples_per_episode, (1:n_episodes)', 'UniformOutput', false));                   
                    %episode_per_sample_reference = episode_per_sample(obj.gpReferenceSetLearner.kernelReferenceSet.getReferenceSetIndices);
                    %validationSets = arrayfun(@(i) find(episode_per_sample_reference == i),      1:n_episodes, 'UniformOutput', false);
                    validationSets = arrayfun(@(i) find(episode_per_sample == i),      1:n_episodes, 'UniformOutput', false);
                    obj.validationSetIndices = validationSets;
                case 'leaveoneout'
                    validationSets = num2cell((1:numPoints)');
                    obj.validationSetIndices = validationSets;
            end
        end
        
        function [logLike, gradient] = objectiveFunction(obj, params)
            
            
            if (nargin > 1)
                obj.setParametersToOptimize(params);
                phi = obj.getInputData();
                obj.learner.learnFunction(obj.getInputData, obj.outputData, obj.weighting);
            else
                phi = obj.getInputData();
            end

            n = numel(obj.validationSetIndices);          
            logLike = 0; %negative log pseudo-likelihood

            cholA   = obj.functionApproximator.cholA; 
                       
            A = obj.outputData;
            R = diag(obj.weighting);
            
            %alpha = 1/obj.learner.functionApproximator.priorVariance; -> already inside cholA
            beta = 1/obj.learner.functionApproximator.regularizer;
            
            phiRA = phi'*R*A;
            
            for fold = 1:n
                
                idxs = obj.validationSetIndices{fold};
                if(numel(idxs)~=0)
                    
                    v = sqrt(beta*R(idxs,idxs)) * phi(idxs,:); %'update' for CHOL
                    phiRAfold = phiRA - phi(idxs,:)' * R(idxs, idxs) * A(idxs,:); 
                    
                    temp =  Common.Helper.cholrankup.cholrankup(cholA, v',-v', phi(idxs,:)');
                    % = (alpha * eye(2) + phi(~idxs,:)' * beta * R(~idxs, ~idxs) * phi(~idxs,:)) \ phi(idxs,:)'
                    
                    %foldMean = beta * phi(idxs,:)*Common.Helper.cholrankup.cholrankup(cholA, v',-v', phiRAfold );
                    foldMean = beta*(phiRAfold'*temp)';
                    
                    pointVar = 1/beta + sum(phi(idxs,:).*temp',2);

                    for dim = 1:size(obj.outputData,2)
                        outputFold = obj.outputData(idxs, dim);
                        wt = obj.weighting(idxs);
                        logLikelihoodFold = -0.5*wt'*log(pointVar)  ...
                            -sum(0.5*(outputFold - foldMean).^2.*wt./pointVar)  ...
                            -0.5*sum(wt)*log(2*pi);
                        logLike = logLike + logLikelihoodFold;
                    end
                end
                
            end
            if(isnan(logLike) || isinf(logLike))
                 error('BayesianLinearHyperLearnerCV:objective','Objective is inf or nan' );
            end
        end
        
                        
    end
    
end
