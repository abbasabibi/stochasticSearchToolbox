classdef RKHSModelLearner2 < Learner.ModelLearner.RKHSModelLearner
    %RKHSFEATURELEARNER Constrains to observed next state features instead
    % of observed state features
    

    
    methods
        function obj = RKHSModelLearner2(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, safeatureExtractor)
            obj@Learner.ModelLearner.RKHSModelLearner(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, safeatureExtractor);

        end        
        function [features] = getFeaturesInternal(obj, ~, inputMatrix)

            K_sa_sa_in = inputMatrix(:,1:size(obj.K_sa_sa ,1 ))'; 
            m = size(obj.K_sa_sa,1);
            m1 = size(obj.K_ref_s1,2);
            n = size(inputMatrix,1);
            K_sa_sa_reg = obj.K_sa_sa + obj.lambda * eye(m);
            div_K_reg_K = K_sa_sa_reg \ obj.K_sa_sa;
            div_K_reg_K_in = K_sa_sa_reg \ K_sa_sa_in;
            z = 1/(m^2) *ones(1,m)*(div_K_reg_K)*ones(m,1);
            gamma = 1-obj.resetProbTimeSteps;
            term1 = obj.K_ref_sprime * (eye(m) - 1/(z*m^2) * div_K_reg_K * ones(m,m) );
            %term2 = -1/(m1*m*gamma*z)*(1-gamma)*obj.K_ref_s1*ones(m1,m);
            %term3 = 1/(m^2*gamma*z)*obj.K_ref_sprime*ones(m,m);
            term2 = 0;
            term3 = 1/(m^2*z)*obj.K_ref_sprime*ones(m,m);
            
            pred_ft = (term1 + term2 + term3)*div_K_reg_K_in;
            
            
            
            features = (gamma * pred_ft + 1/m1*(1-gamma)*obj.K_ref_s1*ones(m1,n))';
            
            if(size(features,2) > obj.getNumFeatures())
                warning('RKHSModelLearner2:numFeatures','amount of features not supported')
                features = features(:,1:obj.getNumFeatures());
            else
                zerofeatures = zeros(size(inputMatrix,1), obj.getNumFeatures()-size(features,2));
                features = [features, zerofeatures];
            end
        end
        

      
        function objective = optimizationObjective(obj, data, params)
            % maximize for reward prediction
            % params: lambda_sa, lambda_r, stateparams, actionparams
            
            gamma = 1-obj.resetProbTimeSteps;
            n_episodes = data.getDataStructure.numElements;
            train_idx = 1:2:n_episodes;
            val_idx = 2:2:n_episodes;
            objective = 0;
            
            for i = 1:2
                if(i==2)
                    temp = train_idx;
                    train_idx =val_idx;
                    val_idx = temp;
                end

                
                st = data.getDataEntry(obj.currentInputFeature, train_idx);
                spt = data.getDataEntry(obj.nextInputFeature, train_idx);
                
                sv = data.getDataEntry(obj.currentInputFeature, val_idx);
                spv = data.getDataEntry(obj.nextInputFeature, val_idx);
                at = data.getDataEntry('actions', train_idx); %actions train

                av = data.getDataEntry('actions', val_idx); %actions validate

                s1t  = data.getDataEntry(obj.currentInputFeature, train_idx, 1); % first states train
  

                locallambda_sa = exp(params(1));
                nStateParam = numel(obj.sfeatureExtractor.getHyperParameters());
                stateParams = exp(params(1:nStateParam));
                obj.sfeatureExtractor.setHyperParameters(stateParams);
                obj.nsfeatureExtractor.setHyperParameters(stateParams);
                obj.safeatureExtractor.setHyperParameters(exp(params));
                
                skf = @(s1,s2) obj.sfeatureExtractor.getGramMatrix(s1, s2);           
                sakf = @(s1,a1,s2,a2) obj.safeatureExtractor.getGramMatrix([s1,a1], [s2,a2]);  

                K_sat_sav = sakf(st,at,sv,av);
                K_sat_sat = sakf(st,at,st,at);
                K_spt_spt = skf(spt,spt);
                K_spt_st  = skf(spt,st);
                K_spt_s1t = skf(spt,s1t);
                
                K_spt_spv = skf(spt,spv);

                m = size(K_spt_spt,1);
                m1 = size(K_spt_s1t,2);
                div_K_reg_K = (K_sat_sat + locallambda_sa*eye(m)) \ K_sat_sat;
                div_K_reg_K_in = (K_sat_sat + locallambda_sa*eye(m)) \ K_sat_sav;

                z = 1/(m^2) *ones(1,m)*div_K_reg_K *ones(m,1);
                
                % here we take sp as reference set
                %old: 
                term1 = K_spt_spt * (eye(m) - 1/(z*m^2) * div_K_reg_K * ones(m,m) );
                %term2 = -1/(m1*m*gamma*z)*(1-gamma)*K_spt_s1t*ones(m1,m);
                %term3 = 1/(m^2*gamma*z)*K_spt_spt*ones(m,m);
                term2 = 0;
                term3 = 1/(m^2*z)*K_spt_spt*ones(m,m);
                pred_ft = (term1 + term2 + term3)*div_K_reg_K_in;
                true_ft = K_spt_spv;
                prediction_error = pred_ft - true_ft;
                foldobjective = sum(sum(prediction_error.^2));
                
                % to be multiplied with psi_spt
                embedding = (eye(m) - 1/(z*m^2) * div_K_reg_K * ones(m,m) + 1/(m^2*gamma*z)*ones(m,m))*div_K_reg_K_in;
                
                
                % traditional |psi_true - psi_pred|
                %psitest * psitest = const
                % -2 psitest * psi_predict
                %foldobjective = -2 * K_spt_spv' * embedding;
                % psi_predict * psi_predict
                %foldobjective = foldobjective + embedding' * K_spt_spt * embedding;
                %foldobjective = 0;
                %foldobjective = foldobjective - 2 * sum(sum(K_spt_spv'.* embedding'));
                %foldobjective = foldobjective + sum(sum(embedding.*(K_spt_spt*embedding)));
                


                if(imag(foldobjective)~= 0)
                    %fprintf('Warning: complex predictions!')
                    foldobjective = real(foldobjective);
                end
                objective = objective + foldobjective;
            end    
        end
        

 
     end
    
end

