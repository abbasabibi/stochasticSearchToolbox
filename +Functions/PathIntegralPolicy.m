classdef PathIntegralPolicy < Functions.Mapping & Functions.Function
    
    properties
        
        psifunction
        dynamicalSystem
       
        mode
        hessianatmode
        
    end
    
    properties (SetObservable, AbortSet)
        uFactor % H in paper
         PathIntegralCostActionMultiplier %lambda in paper
    end
    
    methods
        function obj = PathIntegralPolicy(dataManager, psifunction, dynamicalSystem)

            obj@Functions.Function();
            obj@Functions.Mapping(dataManager,'actions','states');
            obj.linkProperty('uFactor');
            obj.linkProperty('PathIntegralCostActionMultiplier');
            obj.psifunction = psifunction;
            obj.dynamicalSystem = dynamicalSystem;

            
            obj.registerMappingInterfaceFunction();
            obj.addDataFunctionAlias('sampleAction', 'getExpectation');
        end
        
        function setInputVariables(obj,inputVars)
            if(~strcmp(inputVars , 'states'))
                assert(false, 'only works on dynamical systems')
            end
            setInputVariables@Functions.Mapping(obj,inputVars)
        end
        
        function [actions] =  getExpectation(obj, numElements, states)
            lambda = obj.PathIntegralCostActionMultiplier;
            psiatmode = obj.psifunction.getExpectation(numElements, obj.mode);
            psi = obj.psifunction.getExpectation(numElements, states );
            psideriv = obj.psifunction.getExpectationDerivative(numElements, states );
            costtogoderiv = - lambda * psideriv;
            n = size(states,1);
            actions = zeros(n,obj.dynamicalSystem.dimAction);            
            
            if(false & ~isempty(obj.hessianatmode))
                statesminmode = bsxfun(@minus, states, obj.mode);
                psi_approx = psiatmode + 0.5 * sum((statesminmode * obj.hessianatmode) .* statesminmode,2);
                use_psi_approx = exp(psi_approx) > exp(psi);
                for state_idx = find(~use_psi_approx)'
                    [~,~, f_u] = obj.dynamicalSystem.getLinearizedDynamics(states(state_idx,: ));
                    actions(state_idx) = -obj.uFactor\f_u'*costtogoderiv(state_idx,:)';
                end
                for state_idx = find(use_psi_approx)'
                    [~,~, f_u] = obj.dynamicalSystem.getLinearizedDynamics(states(state_idx,: ));
                    actions(state_idx) = lambda * (obj.uFactor\f_u')*0.5 * obj.hessianatmode * statesminmode(state_idx,:)';
                end
                %figure(10);
                %obj.plotpolicy
            else
                dynamics = zeros(n, obj.dynamicalSystem.dimState);
                for state_idx = 1:n
                    
                    [~,~, f_u] = obj.dynamicalSystem.getLinearizedDynamics(states(state_idx,: ));
                    dynamics(state_idx,:) = f_u';
                end 
                actions = (-obj.uFactor\sum(dynamics.*costtogoderiv,2));
            end
        end
        
        function plotpolicy(obj )
            [s1 s2] = meshgrid(-pi:0.6:pi, -10:2:10 );
            states = [s1(:) s2(:)];
            

            actions = obj.getExpectation(:, states);

            imagesc([-pi pi], [-10 10], reshape(actions, 11,11))
            title('policy')
        end
    end
    
end