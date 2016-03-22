classdef RKHSModelLearner < Learner.Learner & FeatureGenerators.FeatureGenerator
    %RKHSFEATURELEARNER Updates conditional RKHS model and calculates
    %features
    
    properties(SetObservable,AbortSet)
        stateFeature;
        stateActionFeature;
       
        
        K_sa_sa
        K_ref_sprime
        K_ref_s
        K_ref_s1
        operator
        resetProbTimeSteps = 0.1
        featureTag = 1;

        

        
        sfeatureExtractor;
        nsfeatureExtractor;
        safeatureExtractor;
        %numFeatures;

        expparamsopt;


        RKHSparamsstate;
        RKHSparamsactions;
        currentInputFeature;
        nextInputFeature;
        
        isFirstTimestep;
        usetomlab = false;
        useslowness = false
        
        regularizer = 1e-6;
    end
    
    methods
        function obj = RKHSModelLearner(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, safeatureExtractor)

            %featureVariables={{[cell2mat(safeatureExtractor.featureVariables{1}) safeatureExtractor.featureName]}};
            featureVariables=safeatureExtractor.outputName;
            numFeatureslocal = sfeatureExtractor.getNumFeatures();
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'ExpNextFeat', stateIndices,numFeatureslocal);

            obj = obj@Learner.Learner();
            
            obj.stateFeature = sfeatureExtractor.featureName;
            obj.stateActionFeature = safeatureExtractor.featureName;

            obj.sfeatureExtractor = sfeatureExtractor;
            obj.safeatureExtractor = safeatureExtractor;
            obj.nsfeatureExtractor = nsfeatureExtractor;
            obj.linkProperty('resetProbTimeSteps');
            obj.linkProperty('RKHSparamsstate');
            obj.linkProperty('RKHSparamsactions');
            obj.linkProperty('usetomlab');
            obj.linkProperty('useslowness');
            if(iscell(sfeatureExtractor.featureVariables{1}))
                obj.currentInputFeature = sfeatureExtractor.featureVariables{1}{1};
            else
                obj.currentInputFeature = sfeatureExtractor.featureVariables{1};
            end
            if(iscell(nsfeatureExtractor.featureVariables{1}))
                obj.nextInputFeature = nsfeatureExtractor.featureVariables{1}{1};
            else
                obj.nextInputFeature = nsfeatureExtractor.featureVariables{1};
            end
            %only support a single input feature now
        end
        
        function setHyperParameters(obj, params)
           obj.regularizer = params(1);
           nStateParam = obj.sfeatureExtractor.getNumHyperParameters();
           
           stateParams = params(2:(nStateParam+1));
           obj.sfeatureExtractor.setHyperParameters(stateParams);
           obj.nsfeatureExtractor.setHyperParameters(stateParams);
           obj.safeatureExtractor.setHyperParameters(params(2:end) );
        end
        
        function params = getHyperParameters(obj)
            p = obj.safeatureExtractor.getHyperParameters( );
            params = [obj.regularizer, p ];
        end
        
        function n = getNumHyperParameters(obj) 
            n = obj.safeatureExtractor.getNumHyperParameters( );
        end
        
        function [features] = getFeaturesInternal(obj, ~, inputMatrix)

            n = size(inputMatrix,1);
            m1 = size(obj.K_ref_s1,2);  
            gamma = 1-obj.resetProbTimeSteps;
            K_sa_sa_in = inputMatrix(:,1:size(obj.K_sa_sa ,1 ))'; 
            pred_ft = obj.operator * K_sa_sa_in; 
            
            features = (gamma * pred_ft + 1/m1*(1-gamma)*obj.K_ref_s1*ones(m1,n))';
            
            if(size(features,2) > obj.getNumFeatures())
                warning('RKHSModelLearner:numFeatures','amount of features not supported')
                features = features(:,1:obj.getNumFeatures());
            else
                zerofeatures = zeros(size(inputMatrix,1), obj.getNumFeatures()-size(features,2));
                features = [features, zerofeatures];
            end
        end
        
        function [numFeatures] = getNumFeatures(obj)
            numFeatures = obj.numFeatures;
        end
        
        function [featureTag] = getFeatureTag(obj)
            featureTag = obj.featureTag;
        end
     
        function [isValid] = isValidFeatureTag(obj, featureTags)
            isValid = featureTags == obj.featureTag;
        end

      
        function objective = optimizationObjective(obj, data, params)
            % maximize for reward prediction

            
            gamma = 1-obj.resetProbTimeSteps;
            n_episodes = data.getDataStructure.numElements;
            n_samples = data.getDataStructure.steps.numElements;
            objective = 0;
            obj.setHyperParameters(exp(params));
            
            for i = 1:2
                train_start = i;
                val_start = mod(i,2)+1;
                if(n_episodes ==1)
                    train_idx = {1, train_start:2:n_samples};
                    val_idx = {1, val_start:2:n_samples};
                else
                    train_idx = {train_start:2:n_episodes};
                    val_idx = {val_start:2:n_episodes};                        
                end

               
                st = data.getDataEntry(obj.currentInputFeature, train_idx{:});
                spt = data.getDataEntry(obj.nextInputFeature, train_idx{:});
                
                sv = data.getDataEntry(obj.currentInputFeature, val_idx{:});
                spv = data.getDataEntry(obj.nextInputFeature, val_idx{:});
                at = data.getDataEntry('actions', train_idx{:}); %actions train

                av = data.getDataEntry('actions', val_idx{:}); %actions validate

                s1t  = data.getDataEntry(obj.currentInputFeature, train_idx{:}, 1); % first states train
  


                
                
                skf = @(s1,s2) obj.sfeatureExtractor.kernel.getGramMatrix(s1, s2);           
                sakf = @(s1,a1,s2,a2) obj.safeatureExtractor.kernel.getGramMatrix([s1,a1], [s2,a2]);  

                K_sat_sav = sakf(st,at,sv,av);
                K_sat_sat = sakf(st,at,st,at);
                K_spt_spt = skf(spt,spt);
                K_spt_st  = skf(spt,st);
                K_spt_s1t = skf(spt,s1t);
                
                K_spt_spv = skf(spt,spv);

                m = size(K_spt_spt,1);
                m1 = size(K_spt_s1t,2);
                div_K_reg_K = (K_sat_sat + obj.regularizer*eye(m)) \ K_sat_sat;
                div_K_reg_K_in = (K_sat_sat + obj.regularizer*eye(m)) \ K_sat_sav;

                z = 1/(m^2) *ones(1,m)*div_K_reg_K *ones(m,1);
                
                % here we take sp as reference set
                %old: 
                term1 = K_spt_spt * (eye(m) - 1/(z*m^2) * div_K_reg_K * ones(m,m) );
                term2 = -1/(m1*m*gamma*z)*(1-gamma)*K_spt_s1t*ones(m1,m);
                term3 = 1/(m^2*gamma*z)*K_spt_st*ones(m,m);
                
                pred_ft = (term1 + term2 + term3)*div_K_reg_K_in;
                true_ft = K_spt_spv;
                prediction_error = pred_ft - true_ft;
                foldobjective = sum(sum(prediction_error.^2));

                if(imag(foldobjective)~= 0)
                    %fprintf('Warning: complex predictions!')
                    foldobjective = real(foldobjective);
                end
                objective = objective + foldobjective;
            end    
        end
        
        function objective = TDobjective(obj, data, params)
            % maximize for reward prediction

            obj.setHyperParameters(exp(params));
                
            gamma = 1-obj.resetProbTimeSteps;
            n_episodes = data.getDataStructure.numElements;
            n_samples = data.getDataStructure.steps.numElements;
            
            objective = 0;
            
            for i = 1:2
                train_start = i;
                val_start = mod(i,2)+1;
                if(n_episodes ==1)
                    train_idx = {1, train_start:2:n_samples};
                    val_idx = {1, val_start:2:n_samples};
                else
                    train_idx = {train_start:2:n_episodes};
                    val_idx = {val_start:2:n_episodes};                        
                end

                
                st = data.getDataEntry(obj.currentInputFeature, train_idx{:});
                spt = data.getDataEntry(obj.nextInputFeature, train_idx{:});
                
                sv = data.getDataEntry(obj.currentInputFeature, val_idx{:});
                spv = data.getDataEntry(obj.nextInputFeature, val_idx{:});
       
                rt = data.getDataEntry('rewards', train_idx{:});
                rv = data.getDataEntry('rewards', val_idx{:});



                skf = @(s1,s2) obj.sfeatureExtractor.kernel.getGramMatrix(s1, s2);           
                K_spt_spt = skf(spt,spt);
                K_spt_st  = skf(spt,st);


                K_spt_spv = skf(spt, spv);
                K_spt_sv = skf(spt,sv);
                
                ft_dif_train = gamma*K_spt_spt - K_spt_st;
                ft_dif_val   = gamma*K_spt_spv - K_spt_sv;
                
                rtc = rt - mean(rt);
                
                coefs = (ft_dif_train * ft_dif_train'+ obj.regularizer * eye(size(ft_dif_train * ft_dif_train')))\ ft_dif_train * rtc;
                TD = ft_dif_val' * coefs - (rv - mean(rt));
                
                foldobjective = norm(TD);

                if(imag(foldobjective)~= 0)
                    %fprintf('Warning: complex predictions!')
                    foldobjective = real(foldobjective);
                end
                objective = objective + foldobjective;
            end            
        end
        
        function slowness = slownessObjective(obj, data, params)

            obj.setHyperParameters(params)
                
            s = data.getDataEntry(obj.currentInputFeature);
            sp = data.getDataEntry(obj.nextInputFeature);

            skf = @(s1,s2) obj.sfeatureExtractor.kernel.getGramMatrix(s1, s2);         
            K_sp_sp = skf(sp,sp);
            K_sp_s  = skf(sp,s);
            
            %ft_s = K_sp_s';
            %ft_sp = K_sp_sp';
            
            %mean_ft = mean(ft_s);
            %[u,s,v] = svd(bsxfun(@minus, ft_s, mean_ft));
            
            %white_s = ft_s * u* s^(-0.5);
            %white_sp = ft_sp * u* s^(-0.5);
            K_sp_sp = bsxfun(@minus,K_sp_sp, mean(K_sp_sp, 2));
            K_sp_s = bsxfun(@minus,K_sp_s, mean(K_sp_sp, 2));
            
            K_sp_sp=bsxfun(@rdivide, K_sp_sp, std(K_sp_sp,0,2));
            K_sp_s = bsxfun(@rdivide,K_sp_s, std(K_sp_sp,0,2));
            
            
            
            
            % make features zero mean, unit var TODO 
            %slowness = sum(sum((white_s - white_sp).^2));
            slowness =sum(sum((K_sp_sp-K_sp_s).^2));
        
                
          
        end
        
        function setOptimalHyperParams(obj, data)
            %'optimizing RKHS hyperparameters'
            % tomlab options
            if(obj.usetomlab)
                Prob = ProbDef; 
                Prob.Solver.Tomlab = 'ucSolve';
            end
            
            paramsoptstate = obj.RKHSparamsstate;
            if(any(paramsoptstate < 0))
                
                lparamsoptstate = log(obj.RKHSparamsstate);
                tooptimize_state = find(paramsoptstate < 0);

                linitparams = log(-paramsoptstate(tooptimize_state));           
                getparams = @(params) Experiments.test.mergeVectors(lparamsoptstate, params, tooptimize_state );
                if(obj.useslowness)
                    objective = @(params) obj.slownessObjective(data,  getparams(params));
                    
                else
                    objective = @(params) obj.TDobjective(data,  getparams(params));
                end
                if(obj.usetomlab)
                    stateparamsopt = fminunc(objective, linitparams,[],Prob );
                else
                    
                     stateparamsopt = fminunc(objective, linitparams );
                end
                paramsopt = getparams(stateparamsopt);
            else
                paramsopt = log(paramsoptstate)
            end
            
            paramsoptactions = obj.RKHSparamsactions;
            if(any(paramsoptactions < 0))
                
                tooptimize_actions = find(paramsoptactions < 0);
                linitparams = log(-paramsoptactions(tooptimize_actions));           
                getparams = @(params) Experiments.test.mergeVectors(paramsopt, params, tooptimize_actions );
                if(obj.usetomlab)
                    [actionparamsopt,FVAL,EXITFLAG,OUTPUT] = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params) ), linitparams,[],Prob);
                else
                     [actionparamsopt,FVAL,EXITFLAG,OUTPUT] = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params) ), linitparams);
                end
                paramsopt = Experiments.test.mergeVectors(paramsopt, actionparamsopt, tooptimize_actions);           
            else
                paramsopt = log(paramsoptactions);
            end
            
            exp(paramsopt)
                       
            obj.setHyperParameters(exp(paramsopt));          
            obj.expparamsopt = exp(paramsopt);
        end
        
        function obj = updateModel(obj, data)
            obj.featureTag = obj.featureTag + 1; 
                    
            obj.setOptimalHyperParams( data);
 
            states = data.getDataEntry(obj.currentInputFeature);
            statesInit = data.getDataEntry(obj.currentInputFeature,:,1);
            obj.isFirstTimestep = data.getDataEntry('timeSteps') == 1;
            actions = data.getDataEntry('actions');
            nextStates = data.getDataEntry(obj.nextInputFeature);
            
            referenceSet = obj.safeatureExtractor.getReferenceSet();
            idx = obj.safeatureExtractor.getReferenceSetIndices();
            obj.K_sa_sa = obj.safeatureExtractor.kernel.getGramMatrix(referenceSet,referenceSet);
            %obj.K_sa_sa = obj.safeatureExtractor.getFeatures(:,[states,actions]);
            obj.K_ref_sprime = obj.nsfeatureExtractor.getFeatures(:,nextStates(idx,:))';
            obj.K_ref_s = obj.sfeatureExtractor.getFeatures(:,states(idx,:))';
            obj.K_ref_s1 = obj.sfeatureExtractor.getFeatures(:,statesInit)';
            
            %obj.K_sa_sa = data.getDataEntry([obj.currentInputFeature, 'actions', obj.stateActionFeature]);
            %obj.K_ref_sprime = data.getDataEntry([obj.nextInputFeature, obj.stateFeature])';
            %obj.K_ref_s = data.getDataEntry([obj.currentInputFeature, obj.stateFeature])';
            %obj.K_ref_s1 = data.getDataEntry([obj.currentInputFeature, obj.stateFeature],:,1)';

            n_ref = size(obj.K_ref_s,2);
            n_sa = size(obj.K_sa_sa,1);      
            
            obj.K_sa_sa = obj.K_sa_sa(:,1:n_sa);
            obj.K_ref_sprime = obj.K_ref_sprime(1:n_ref,:);
            obj.K_ref_s = obj.K_ref_s(1:n_ref,:);
            obj.K_ref_s1 = obj.K_ref_s1(1:n_ref,:);
            
            
            m = size(obj.K_sa_sa,1);
            m1 = size(obj.K_ref_s1,2);
            K_sa_sa_reg = obj.K_sa_sa + obj.regularizer * eye(m);
            div_K_reg_K = K_sa_sa_reg \ obj.K_sa_sa;
            z = 1/(m^2) *ones(1,m)*(div_K_reg_K)*ones(m,1);
            gamma = 1-obj.resetProbTimeSteps;
            term1 = obj.K_ref_sprime * (eye(m) - 1/(z*m^2) * div_K_reg_K * ones(m,m) );
            term2 = -1/(m1*m*gamma*z)*(1-gamma)*obj.K_ref_s1*ones(m1,m);
            term3 = 1/(m^2*gamma*z)*obj.K_ref_s*ones(m,m);
            
            obj.operator = (term1 + term2 + term3)/K_sa_sa_reg ;

        end
    end
    
end

