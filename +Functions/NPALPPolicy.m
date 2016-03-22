classdef NPALPPolicy < Functions.Mapping & Functions.Function
    %NPALP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % store so-called 'basic states' and associated values and actions
        basicstates
        basicactions
        basicv
        
    end
    
    properties (SetObservable, AbortSet)
        lipschitzConstant=1
        initSigma = 0.1
        epsilongreedy = 0.1
        explorationWidth = 0.3 %std dev as fraction of action spectrum
        featureScale
    end
    
    methods
        function obj=NPALPPolicy(dataManager)
            
            obj@Functions.Function();
            obj@Functions.Mapping(dataManager,'actions','states');


            
            obj.registerMappingInterfaceFunction();
            obj.addDataFunctionAlias('sampleAction', 'getExpectation');
            
            obj.linkProperty('lipschitzConstant');
            obj.linkProperty('epsilongreedy');
            obj.linkProperty('explorationWidth');
            obj.linkProperty('featureScale');
            
        end
        
        function [actions] =  getExpectation(obj, numElements, states)
            % for every state t find basic state s that maximizes
            % V(s)-L*d(s,t)
            if(~isempty(obj.basicstates) )
                if(~isempty(obj.featureScale))
                    Q = diag(obj.featureScale);
                else
                    Q = eye(size(states,2)); %allows changing of the metric
                end
                a = states;
                b = obj.basicstates;
                aQ = a * Q ; 
                sqdist = bsxfun ( @plus , sum ( aQ .* a , 2 ) ,sum ( b * Q .* b , 2 )' ) -2* aQ * b' ;
                dist = sqrt(sqdist);

                Vbound = bsxfun(@minus, obj.basicv', obj.lipschitzConstant*dist);
                [~,state_idx] = max(Vbound,[],2); % get the state index that maximizes the bound

                actions = obj.basicactions(state_idx,:); %select actions correspong to maximizing states
                nactions = size(actions,1);
                range = obj.dataManager.getRange('actions');
                actions = actions + bsxfun(@times, rand(nactions, 1) < obj.epsilongreedy, range * obj.explorationWidth) ;
            else
                
                range = obj.dataManager.getRange('actions');
                avAction = (obj.dataManager.getMaxRange('actions') + obj.dataManager.getMinRange('actions')) /2; 
                dimActions = size(range,2);
                sigma = diag(range .* obj.initSigma);
                actions = bsxfun(@plus, avAction, randn(size(states,1),dimActions) * sigma);
                
            end
        end
        
    end
    
end

