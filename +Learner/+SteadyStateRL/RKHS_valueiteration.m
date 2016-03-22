classdef RKHS_valueiteration < Learner.Learner
    %RKHS_VALUEITERATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        modellearner
        rewardfunction
        policy
        inputVar = 'states'
        inputFeatures = 'ProdKernel'
        
        nextVfunction
    end
    
    properties (SetObservable, AbortSet)
        resetProb
    end
    
    methods
        function obj = RKHS_valueiteration(dataManager, modellearner, rewardfunction, policy, inputVar, inputFeatures)
            obj = obj@Learner.Learner();
            obj.modellearner = modellearner;
            obj.rewardfunction = rewardfunction;
            obj.policy = policy;
            obj.nextVfunction = policy.nextVfunction;
            obj.linkProperty('resetProb');
            if(exist('inputVar','var'))
                obj.inputVar = inputVar;
            end
            if(exist('inputFeatures','var'))
                obj.inputFeatures = inputFeatures;
            end
        end
        
%         function [objective,g] = crossValidationLambda(obj, v, sfeatures, llambda)
%             lambda = exp(llambda);
%             n = size(v,1);
%             train_idx = 1:round(n/2);
%             val_idx = (round(n/2)+1):n;
%             objective = 0;
%             g = 0;
%             
%             for i = 1:2
%                 if(i==2)
%                     temp = train_idx;
%                     train_idx =val_idx;
%                     val_idx = temp;
%                 end
%                 
%                 vt = v(train_idx);
%                 vv = v(val_idx);
%                 phit = sfeatures(train_idx,train_idx);
%                 phiv = sfeatures(val_idx,train_idx);
%                 ntrain = size(vt,1);
%                 alphat = (phit+lambda*eye(ntrain) ) \  vt;
%                 predv = phiv*alphat;
%                 objective = objective + sum((predv - vv).^2);
%                 %g = g + 2*vv'*phiv/(phit+lambda*eye(ntrain))*((phit+lambda*eye(ntrain))\vt);
%                 %g = g - 2*vt'/(phit+lambda*eye(ntrain))*(phiv'*phiv)/(phit+lambda*eye(ntrain))/(phit+lambda*eye(ntrain))*vt;
%                 
%             end
%         end
        
%         function [objective,g] = bellmanError(obj, sfeatures, expectedfeatures, rewards,  v, llambda)
%                 m = size(expectedfeatures,1);
%                 embeddingstrengths = (sfeatures+exp(llambda)*eye(m) ) \  v;
%                 expnextv = sum(bsxfun(@times, expectedfeatures, embeddingstrengths'),2);
%                 q = rewards + (1-obj.resetProb) * permute(expnextv,[1,3,2]);
%                 vpred = max(q,[],2);
%                 vdir = sfeatures* embeddingstrengths;%direct estimate
%                 objective = sum( (vpred - vdir).^2);
%         end
        
        function updateModel(obj, data)
            actions = obj.policy.actions;
            
            statefeatures = data.getDataEntry([obj.inputVar, obj.inputFeatures]);
            states = data.getDataEntry([obj.inputVar]);
            rawstates = data.getDataEntry('states'); %original states for reward fc
            m = size(statefeatures,1);
            
            
            %TODO only works for 1d actions!
            expectedfeatures = zeros(m, m, numel(actions)); 
            rewards = zeros(m, numel(actions));
            
            for i = 1:numel(actions)
                
                safeatures = obj.modellearner.safeatureExtractor.getFeatures(:,[states, repmat(actions(i), m, 1) ] );
                ef = obj.modellearner.getFeatures(:,safeatures);
                expectedfeatures(:,:,i) = ef(:,1:m);
                rewards(:,i) = obj.rewardfunction.rewardFunction(rawstates, repmat(actions(i), m, 1));
            end

            sfeatures = obj.modellearner.sfeatureExtractor.getFeatures(:,states);
            sfeatures = sfeatures(:,1:m);
            embeddingstrengths = zeros(m,1); 
            expnextv = sum(bsxfun(@times, expectedfeatures, embeddingstrengths'),2);
            q = rewards + (1-obj.resetProb) * permute(expnextv,[1,3,2]);
            v = max(q,[],2);            
            lambda = 1;
            %opt = optimset('LargeScale', 'off');
            %llambda = fminunc(@(llambda)obj.crossValidationLambda(v,sfeatures,llambda), log(lambda), opt);
            %lambda = exp(llambda);
                
            
            n = 1;
            error = 1;
            maxn = 100;
            'valueiteration'
            while n < maxn && error/norm(embeddingstrengths) > 1e-3
                % expectedfeatures * embeddingstrengths
                expnextv = sum(bsxfun(@times, expectedfeatures, embeddingstrengths'),2);
                q = rewards + (1-obj.resetProb) * permute(expnextv,[1,3,2]);
                v = max(q,[],2);
                newembeddingstrengths = (sfeatures+lambda*eye(m,m) ) \  v;
                warning('TODO: not really the pseudoinverse in last line!')
                error = norm(newembeddingstrengths - embeddingstrengths);
                embeddingstrengths = newembeddingstrengths;
                n=n+1;

                %c = exp(-(v-max(v))/(min(v)-max(v)));
                %scatter3(states(:,1), states(:,2), v,c*10,c);
                %pause(0.01)

            end
            if(n == maxn)
                warning('RKHS_valueiteration: no solution found in nmax iterations')
            end
                        
            % -lamda * log( a*phi(x)) = log( (a/exp(lambda)) * phi(x))
            if(isempty(obj.nextVfunction.featureGenerator))
                obj.nextVfunction.setFeatureGenerator(obj.modellearner);
            end
            
            weights = [embeddingstrengths; zeros(obj.modellearner.safeatureExtractor.getNumFeatures - m, 1)];
            obj.nextVfunction.setWeightsAndBias(weights', 0);
            

            
        end
        
    end
    
end

