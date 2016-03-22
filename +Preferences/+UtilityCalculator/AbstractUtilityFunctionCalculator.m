classdef AbstractUtilityFunctionCalculator < FeatureGenerators.FeatureGenerator & Learner.Learner
    
    properties (SetAccess=protected)
        numState;
        linearFunc;
        featureTag = 1;
        preferenceFeature;
        lastImportance;
    end
    
    properties (SetObservable)
        tradeoffC
        gamma
        useBias = false;
    end
    
    methods
        function obj =  AbstractUtilityFunctionCalculator(dataManager ,utilFunction , featureName, preferenceFeature, varargin)
            obj@FeatureGenerators.FeatureGenerator(dataManager, featureName, 'utilities', ':', 1);
            obj = obj@Learner.Learner(varargin{:});
            
            obj.linkProperty('tradeoffC', 'dynamicProgramC');
            obj.linkProperty('gamma', 'discountFactor');
            obj.linkProperty('useBias', 'useFEbias');
            
            obj.linearFunc = utilFunction;
            
            obj.preferenceFeature = preferenceFeature;
        end
        
        function obj = updateModel(obj, data)
            obj.featureTag = obj.featureTag + 1;
            obj.numState = size(data.getDataEntry(obj.featureVariables{1},1,1),2);
            
            featureExpectations=data.getDataEntry([cell2mat(obj.featureVariables{1}) 'featureExpectations']);
            
            
            collectedTrajs=unique(featureExpectations,'rows');
            preferences=data.getDataEntry(obj.preferenceFeature);
            utilityTime = tic;
            
            iterationNumber=data.getDataEntry('iterationNumber');
            
            %ranks = data.getDataEntry('returnsranks');
            %[~,order] = sort(ranks);
            %preferences = preferences(order,:);
            %preferences = preferences(:,order);
            %iterationNumber = iterationNumber(order);
            %featureExpectations = featureExpectations(order,:);
            
            %if ~isempty(obj.lastImportance)
            %    disp('Recalculating utility with new features');
            %    oldWeights = obj.calculateUtilityFunction(obj.tradeoffC,unique(featureExpectations(1:size(obj.lastImportance,1),:),'rows'),featureExpectations(1:size(obj.lastImportance,1),:),preferences(1:size(obj.lastImportance,1),1:size(obj.lastImportance,1)),iterationNumber(1:size(obj.lastImportance,1)),obj.lastImportance);
            %    if ~obj.useBias
            %        newWeights(1) = 0;
            %    end
            %
            %                obj.linearFunc.setWeightsAndBias(oldWeights(2:end), oldWeights(1));
            %           end
            
            %   expectedUtil = obj.linearFunc.getExpectation(size(featureExpectations,1),featureExpectations(:,2:end));
            % importance = expectedUtil-min(expectedUtil);
            
            %oldWeights = obj.linearFunc.getParameterVector();
            
            %sigma = eye(size(params,1));
            %r = mvnrnd(params',sigma,1000000);
            %values = r*featureExpectations';
            %importance = var(values);
            
            %  if(max(importance)==0 | isnan(importance))
            importance = ones(size(iterationNumber));
            %  end;
            
            %prefIds = find(preferences==Preferences.PreferenceGenerator.Preference.getIntRepresentation(Preferences.PreferenceGenerator.Preference.Preferred));
            %preferenceCount = size(prefIds,1);
            %if preferenceCount==0 || size(collectedTrajs,1)<2
            %    newWeights = -sum(collectedTrajs,1);
            %else
            try
                obj.lastImportance=importance;
                newWeights = obj.calculateUtilityFunction(obj.tradeoffC,collectedTrajs,featureExpectations,preferences,iterationNumber,importance);
                %end
                fprintf('Time to calculate the utility function: %f\n', toc(utilityTime));
                
                if size(newWeights,1) > 0
                    if ~obj.useBias
                        newWeights(1) = 0;
                    end
                    newWeights = newWeights(1,:);
                    %newWeights = newWeights/norm(newWeights); %l2 norm
                    obj.linearFunc.setWeightsAndBias(newWeights(2:end), newWeights(1));
                else
                    %obj.linearFunc.setWeightsAndBias(newWeights, 0);
                    %cant reuse old weights because featureSpace may have
                    %changed
                    
                    oldWeights = obj.calculateUtilityFunction(obj.tradeoffC,unique(featureExpectations(1:size(obj.lastImportance,1),:),'rows'),featureExpectations(1:size(obj.lastImportance,1),:),preferences(1:size(obj.lastImportance,1),1:size(obj.lastImportance,1)),iterationNumber(1:size(obj.lastImportance,1)),obj.lastImportance);
                    if size(oldWeights,1) > 0
                        if ~obj.useBias
                            oldWeights(1) = 0;
                        end
                        
                        obj.linearFunc.setWeightsAndBias(oldWeights(2:end), oldWeights(1));
                    end
                end
                %expectedUtil = obj.linearFunc.getExpectation(size(featureExpectations,1),featureExpectations(:,2:end));
                %obj.linearFunc.callDataFunction('getExpectation',data);
            catch e
            end
        end
        
        function func = getUtilitiyFunction(obj)
            func = obj.linearFunc;
        end
        
        function [] = initObject(obj)
            obj.initObject@FeatureGenerators.FeatureGenerator();
            obj.linearFunc.initObject();
        end
        
        function [features] = getFeaturesInternal(obj, numElements, varargin)
            features = obj.linearFunc.getExpectation(numElements,varargin{1});
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.featureTag;
        end
        
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end
    end
    
    methods (Abstract)
        calculateUtilityFunction(obj,c,trajs,fe,prefs,iteration)
    end
end

