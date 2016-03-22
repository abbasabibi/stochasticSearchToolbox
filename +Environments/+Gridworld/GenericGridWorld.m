classdef GenericGridWorld < Environments.TransitionFunction %& Sampler.IsActiveStepSampler.IsActiveStepSampler
    
    properties (Access=protected)
        numContext = 2; %start state
        
        actions = [0,-1;1,0;0,1;-1,0] %1=left,2=down,3=right,4=up
        
        rewardMap
    end
    
    properties (Access=protected)
        map;
        initialState = [1 1];
    end
    
    methods
        function obj =  GenericGridWorld(sampler, map, initialState)
            obj@Environments.TransitionFunction(sampler, 2, 1)
            %obj@Sampler.IsActiveStepSampler.IsActiveStepSampler(sampler.dataManager)
            obj.dataManager.addDataEntry('contexts', obj.numContext, -ones(obj.numContext,1), ones(obj.numContext,1));
            obj.map = map;
            
            if (exist('initialState', 'var'))
                obj.initialState = initialState;
            end
            
            obj.rewardMap = containers.Map;
            obj.rewardMap('#') = -5;
            obj.rewardMap('.') = -1;
            obj.rewardMap('G') = 0;
            obj.rewardMap('S') = -1;
            obj.rewardMap('X') = -10;
            
            obj.actions = obj.getActions();
            
            obj.dataManager.setRange('actions', 1, size(obj.actions,1));
            
            obj.dataManager.setRange('states', [0 0], size(obj.map));
            obj.dataManager.setRange('nextStates', [0 0], size(obj.map));
            
            obj.dataManager.addDataEntry('steps.rewards', 1, -ones(1,1), ones(1,1));
            
            obj.addDataManipulationFunction('sampleContext', {}, {'contexts'});
            obj.addDataManipulationFunction('sampleAction', {'states'}, {'actions'});
            obj.addDataManipulationFunction('sampleReward', {'contexts', 'states', 'actions', 'nextStates'}, {'rewards'});            
            obj.addDataManipulationFunction('sampleInitState', {'contexts'}, {'states'});
        end
        
        function [actions] = getActions(obj) 
            actions = obj.actions;
        end
        
        function [] = setInitialStates(obj, initStates)
            obj.initialState = initStates;
        end
        
        function [context] = sampleContext(obj, numElements)
            indexInitialState = randi([1,size(obj.initialState,1)], numElements , 1);
            context = obj.initialState(indexInitialState,:);
        end
        
        function [initialState] = sampleInitState(obj, context)
            initialState = context;
        end
        
        function [action] = sampleAction(obj, state)
            action = randi([1,size(obj.actions,1)],size(state,1) , 1);
        end
        
        
        function [reward] = sampleReward(obj, context, state, action, nextState)
            symbol = obj.map(transpose(obj.getIndexByGrid(nextState)));
            
            reward = cellfun(@(symbol)obj.rewardMap(symbol), symbol);
        end
        
        function [index] = getIndexByGrid(obj, states)
            indexCell = num2cell(transpose(states),2);
            index = sub2ind(size(obj.map),indexCell{:});
        end
        
        
        function [nextState] = transitionFunction(obj, state, action, varargin)
            %transition
            indexCell = num2cell(action,1);
            nextState = state+obj.actions(sub2ind(size(obj.actions),indexCell{:}),:);
            %border
            nextState = max(1,nextState);
            nextState = [min(size(obj.map,1),nextState(:,1)),min(size(obj.map,2),nextState(:,2))];
            %wall
            invalidActions = cellfun((@(symbol) symbol == '#'), obj.map(obj.getIndexByGrid(nextState)));
            nextState = nextState-bsxfun(@times,obj.actions(sub2ind(size(obj.actions),indexCell{:}),:),transpose(invalidActions));
            %goal states
            goalStates = cellfun((@(symbol) symbol == 'G'), obj.map(obj.getIndexByGrid(state)));
            nextState(goalStates,:) = state(goalStates,:);
        end
        
        function value = isActiveStep(obj, states)
            value = transpose(cellfun((@(symbol) symbol ~= 'G'), obj.map(obj.getIndexByGrid(states))));
        end
        
        function features = getFeatures(obj,~,inputMatrix)
            [~,index] = ismember(cell2mat(obj.map(transpose(obj.getIndexByGrid(inputMatrix)))),cell2mat(obj.rewardMap.keys'),'rows');
            features = zeros(size(index,1),size(obj.rewardMap,1));
            for i=1:size(index)
                features(i,index(i))=1;
            end
        end
        
        %function numTimeSteps = toReserve(obj)
        %    numTimeSteps = Inf;
        %end
        
        function dim = getFeatureDim(obj)
            dim =  size(obj.rewardMap,1);
        end
        
    end
    
end

