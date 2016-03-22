classdef PI_RKHS < Learner.Learner 
    
    %PI_RKHS Path integral approach based on RKHS embedding,
    % log-value function is approximated in hilbert space
    
    methods (Static)
        function [learner] = CreateFromTrial(trial)
            rewardname='rewards';
            stateFeatureName=trial.stateFeatures.outputName;
            nextStateFeatureName=trial.nextStateFeatures.outputName;
            trial.transitionFunction.registerControlNoiseInData();
            learner = Learner.SteadyStateRL.PI_RKHS(trial.dataManager, ...
                trial.psifunction, trial.actionPolicy, trial.transitionFunction, trial.stateFeatures, ...
                trial.nextStateFeatures, stateFeatureName, nextStateFeatureName, rewardname);
        end
    end  
    
    properties

        sampledStates
        embeddingStrengths
        
        psifunction
        policy
        rewardName

        stateFeatures
        nextStateFeatures
        dynamicalsystem
        sfeatureExtractor
        nsfeatureExtractor
        
       
    end
    
        
    properties (SetObservable, AbortSet)
         PathIntegralCostActionMultiplier %lambda in paper
         RKHSparamsstate;
          resetProb
    end
    
    
    methods
        
        function obj = PI_RKHS(dataManager, psifunction, policy, dynamicalsystem, sfeatureExtractor, nsfeatureExtractor, stateFeatures, nextStateFeatures, rewardName)
            obj = obj@Learner.Learner();

            obj.policy = policy;
            obj.linkProperty('PathIntegralCostActionMultiplier');
            obj.linkProperty('RKHSparamsstate');
            obj.linkProperty('resetProb');
            obj.dynamicalsystem = dynamicalsystem;
            obj.sfeatureExtractor = sfeatureExtractor;
            obj.nsfeatureExtractor = nsfeatureExtractor;
            obj.psifunction = psifunction;
            
            obj.stateFeatures = stateFeatures;
            
            obj.nextStateFeatures = nextStateFeatures;
            if (~exist('rewardName', 'var'))
                rewardName = 'returns';
            end
            

            obj.rewardName = rewardName;
            

            


            
            % to get data probabilities
            %obj.addDataPreprocessor(DataPreprocessors.DataProbabilitiesPreprocessor(dataManager, policy));
            % adds probabilities of selectecting actions:
            %                                       steps.logQActionsstates
            %obj.addDataPreprocessor(DataPreprocessors.TrajectoryProbabilityPreprocessor(dataManager, dynamicalSystem));
            % adds log probabilities of transitions:  steps.logProbTrans
            %obj.addDataPreprocessor(DataPreprocessors.PathIntegralPreprocessor(dataManager, dynamicalSystem));
            % adds log probabilities under uncontrolled dyn:
            %                                        steps.logProbTransUC
            
            
        end
        
        function obj = updateModel(obj, data)
            obj.sampledStates = data.getDataEntry('states');
            obj.calculateEmbeddingStrength(data);
        end
        
        function calculateEmbeddingStrength(obj, data)
            obj.sfeatureExtractor.setHyperParameters(obj.RKHSparamsstate);
            obj.nsfeatureExtractor.setHyperParameters(obj.RKHSparamsstate);
            
            stateF =  data.getDataEntry(obj.stateFeatures);
            stateF = stateF(:,1:size(stateF,1));
            nextStateF_normal = data.getDataEntry(obj.nextStateFeatures);
            
            ndata = size(nextStateF_normal,1);
            nextStateF_normal = nextStateF_normal(:,1:ndata);
            
            
            nextStateF_init  = data.getDataEntry(obj.nextStateFeatures,:,1);
            nextStateF_init  = nextStateF_init(:,1:ndata,1);
            nextStateF_init  = repmat(mean(nextStateF_init),ndata,1);
            
            nextStateF = (1-obj.resetProb)*nextStateF_normal + obj.resetProb*nextStateF_init;
            rewards = data.getDataEntry(obj.rewardName);
            
            
            logProbTrans =  obj.dynamicalsystem.callDataFunctionOutput('getTransitionProbabilities', data);
            logProbTransUC = obj.dynamicalsystem.callDataFunctionOutput('getUncontrolledTransitionProbabilities', data);
            logProbActions = zeros(size(logProbTrans)); % deterministic? data.getDataEntry('logQActionsstates');
            
            %importance weights
            W = diag(exp(logProbTransUC - logProbTrans - logProbActions));
            % X is set of states (basis) of current step
            % X' is set of next states of current step
            % A is basis of next step 
            % finite horizon: next states
            % infinite horizon: current states
            
            %alpha = zeros(size(nextStateF,2),1);
            %alphanew = ones(size(nextStateF,2),1);
            
            %maxdif = 1e-6;
            epsilon =1e-4;
            
            %reg = epsilon * m * eye(size(stateF));
            %[v,d]  = eig(-(stateF +  reg)\(W*diag(rewards)*nextStateF));
            
            %d= diag(d);
            %[m,i] = max(abs(d).*~imag(d)); %largest real eigenvalue
            %assert(m>0, 'largest eigenvector negative?')
            %alphanew = v(:,i);
            
            m = size(nextStateF,1);
            %maxi = 1;
            %lambdafix = 1
            
            alpha = zeros(size(nextStateF,2),1);
            alphanew = ones(size(nextStateF,2),1)/sqrt(size(nextStateF,2) ) ;
            maxdif = 1e-3;
            i = 1;
            %temperatureold = 1;
            
            
            while(norm(alpha - alphanew) > maxdif)
                i = i+1
                alpha = alphanew;
                reg = epsilon * m * eye(size(stateF));
                phi = exp(rewards/obj.PathIntegralCostActionMultiplier);
                
                %Vnext = rewards + temperatureold* log(nextStateF'*alpha);
                %Vnext = Vnext - max(Vnext);
                
                %temperature = lambdafix * (max(Vnext) - min(Vnext));
                
                %log(nextStateF'*alpha)
                %alphanew = (stateF +  reg)\W*exp(Vnext / temperature);
                alphanew =  (stateF +  reg)\(W*(phi .* (nextStateF'*alpha)));
                %alphanew = phi.* (nextStateF*((stateF +  reg)\alphanew ));
                %alphanew = (stateF +  reg)\W*phi* exp(log(nextStateF'*alpha).^0.98);
                %lambda = alpha' * alphanew;
                %if(lambda < 0)
                %    alphanew = -alphanew;
                %end
                alphanew = alphanew / norm(alphanew); 
                %temperatureold = temperature;
                %if(i>maxi)
                %end
                %scaling has no influence on actions - same as
                % subtracting a baseline
                %if(sum(imag(alpha))>0)
                %    keyboard
                %end
                dif= norm(alpha - alphanew)
            end

            obj.embeddingStrengths = alphanew;
            
            features = obj.sfeatureExtractor;
            if(~isprop(features, 'getExpectation'))
                features.addprop('getExpectation');
                features.addprop('getDerivative');
            end
            features.getExpectation = @(states) obj.sfeatureExtractor.getGramMatrix(states,obj.sampledStates);
            features.getDerivative = @(states) obj.sfeatureExtractor.getKernelDerivData(obj.sampledStates,states );
            
            
            % -lamda * log( a*phi(x)) = log( (a/exp(lambda)) * phi(x))
            
            obj.psifunction.setWeightsAndBias(obj.embeddingStrengths(1:size(obj.sampledStates,1) ), 0);
            obj.psifunction.setFeatureGenerator(features);
            
            %calculate FD hessian
%             states = data.getDataEntry('states');
%             [~,maxidx] = max(obj.psifunction.getExpectation(:,states) );
%             mode = fminunc(@(x) -obj.psifunction.getExpectation(:,x), states(maxidx,:));
%             obj.policy.mode = mode;
%             dimS = size(states,2);
%             hessian = zeros(dimS,dimS);
%             epsilon = 0.1*ones(1,dimS);
%             
%             for i = 1:dimS
%                 for j = i:dimS
%                     
%                     inc1 = false(1,dimS);
%                     inc2 = false(1,dimS);
%                     inc1(i) = true;
%                     inc2(j) = true;
%                     t12 = obj.psifunction.getExpectation(:,mode + epsilon.*inc1 + epsilon.*inc2);
%                     t1 = obj.psifunction.getExpectation(:,mode + epsilon.*inc1);
%                     t2 = obj.psifunction.getExpectation(:,mode + epsilon.*inc2);
%                     t = obj.psifunction.getExpectation(:,mode);
%                     
%                     hessian(i,j) = (t12 - t1 - t2 + t )/ (epsilon(inc1) * epsilon(inc2) );
%                     hessian(j,i) = hessian(i,j);
%                 end
%             end
%             obj.policy.hessianatmode = hessian;
        end
        
        
        function plotpsi(obj, alpha)
                        
            features = obj.sfeatureExtractor;
            if(~isprop(features, 'getExpectation'))
                features.addprop('getExpectation');
                features.addprop('getDerivative');
            end
            obj.embeddingStrengths = alpha;
            features.getExpectation = @(states) obj.sfeatureExtractor.getGramMatrix(states,obj.sampledStates);
            features.getDerivative = @(states) obj.sfeatureExtractor.getKernelDerivData(obj.sampledStates,states );
            
            
            % -lamda * log( a*phi(x)) = log( (a/exp(lambda)) * phi(x))
            
            obj.psifunction.setWeightsAndBias(obj.embeddingStrengths(1:size(obj.sampledStates,1) ), 0);
            obj.psifunction.setFeatureGenerator(features);
            d1 =-pi:0.1:pi;
            d2 = -10:0.1:10;
            [ns1, ns2] = meshgrid(d1,d2 );
            ns = [ns1(:), ns2(:)];
            psi = obj.psifunction.getExpectation(:,ns);
            
            psi = reshape(psi, size(ns1));
            
%             psiatmode = obj.policy.psifunction.getExpectation(:, obj.policy.mode);
%             nsminmode = bsxfun(@minus, ns, obj.policy.mode);
%             psiapprox = psiatmode + 0.5 * sum((nsminmode * obj.policy.hessianatmode) .* nsminmode,2);
%             psiapprox = reshape(psiapprox, size(ns1));
%             
%             usepsiapprox = exp(psiapprox) > exp(psi);
%             psi2 = psi;
%             psi2(usepsiapprox) = psiapprox(usepsiapprox);
            %figure(123)
            %set(3, 'Renderer','painters')
            %contour(d1,d2,psi) %doesn't use approx.
            imagesc(d1,d2, psi)
        end

        function plotPolicy(obj)
            d1 =-pi:0.1:pi;
            d2 = -10:0.5:10;
            [ns1, ns2] = meshgrid(d1,d2 );
            ns = [ns1(:), ns2(:)];
           
            pol = obj.policy.getExpectation(:,ns);
            
            pol = reshape(pol, size(ns1));
            imagesc(d1,d2,pol);
        end
        
            
    end
    
    

end



