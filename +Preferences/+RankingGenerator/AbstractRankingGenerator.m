classdef AbstractRankingGenerator < FeatureGenerators.FeatureGenerator
    
    properties
        globalCalc = false;
        utilFunction;
    end
    
    properties(SetObservable)
        numTimeSteps;
        trajPrefsPerIteration = 1;
    end
    
    methods
        function obj =  AbstractRankingGenerator(dataManager,calculateGlobal, featureVariables)
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager,[featureVariables,'timeSteps','iterationNumber'], 'ranks', ':', 1);
            if (exist('calculateGlobal', 'var'))
                obj.globalCalc = calculateGlobal;
            end
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('trajPrefsPerIteration');
        end
        
        function [features] = getFeaturesInternal(obj, numElements, returns, selected, timeSteps, iterationNumber)            
            dim = size(returns,1);
            if ~obj.globalCalc
                dim=dim*iterationNumber(1);
            end
            state = obj.determineComplete(timeSteps, dim);
            max=size(state,1);
            min=max-size(returns,1)+1;
            state = state(min:max);
            
            returns(selected==0,:) = NaN;
            features = obj.getRanks(returns, state);
            features(selected==0,:) = NaN;
        end
        
        %returns the indexes of the trajectories to not use
        function [idx] = reduceTrajectories(obj, iterationNumber, featureExpectations)
            idx=[];
            uID = unique(iterationNumber);
            for i = 1:numel(uID)
                j = uID(i);
                M = iterationNumber(iterationNumber==j,:);
                fE = featureExpectations(iterationNumber==j,:);
                s = RandStream('mt19937ar','Seed',j);
                
                %Random version
                %idx = [idx randsample(s,size(M,1),size(M,1)-obj.trajPrefsPerIteration)+(j-min(uID))*size(M,1)];
                
                %best expected utility
                expectedUtility = obj.utilFunction.getExpectation(size(fE,1),fE);
                sortedUtility = sort(expectedUtility,'descend');
                limit = sortedUtility(obj.trajPrefsPerIteration);
                validIdx = find(expectedUtility>=limit);
                selectedIdx = randsample(s,size(validIdx,1),obj.trajPrefsPerIteration);
                nextIdx = 1:size(M,1);
                nextIdx(ismember(nextIdx,selectedIdx))=[];
                idx = [idx nextIdx+(j-min(uID))*size(M,1)];
            end
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            if obj.globalCalc
                isValid = zeros(size(featureTags));
            else
                isValid = obj.isValidFeatureTag@FeatureGenerators.FeatureGenerator(featureTags);
            end
        end
        
        function [state] = determineComplete(obj,timeSteps,dim)
            state = ones(dim,1);
            current = 1;
            for i=2:size(timeSteps,1)
                if timeSteps(i-1)>=timeSteps(i)
                    if timeSteps(i-1)==obj.numTimeSteps
                        state(current)=0;
                    end
                    current = current+1;
                end
            end
            if timeSteps(size(timeSteps,1))==obj.numTimeSteps
                state(dim)=0;
            end
        end
    end
    
    methods (Abstract)
        getRanks(obj, returns, reachedTerminal)
    end
end

