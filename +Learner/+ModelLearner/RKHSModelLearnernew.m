classdef RKHSModelLearnernew < Learner.Learner & FeatureGenerators.FeatureGenerator
    %RKHSFEATURELEARNER Updates conditional RKHS model and calculates
    %features
    
    properties(SetObservable,AbortSet)
        stateFeature;

               
        K_sa_sa
        K_ref_sprime
        K_ref_s
        K_ref_s1

        resetProbTimeSteps = 0.1
        featureTag = 1;
        lambda = 1e-6;
        
        sfeatureExtractor;
        nsfeatureExtractor;
        sakernel;

        expparamsopt;

        RKHSparams_V;
        RKHSparams_ns;
        currentInputFeature;
        nextInputFeature;
        
        isFirstTimestep;
        usetomlab = false;
        useslowness = false
        
        referenceStateActions
        referenceSetIndices
    end
    
    methods
        function obj = RKHSModelLearnernew(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, stateactionkernel)
            if(iscell(sfeatureExtractor.featureVariables{1}))
                featureVariables= {[sfeatureExtractor.featureVariables{:}, 'actions']};
            else
            %assumes inputDataEntry is a depth-1 cell array like {'states'}
            % will make featureVariables something like
            % {{'states','actions'}}
                featureVariables= {[sfeatureExtractor.featureVariables, 'actions']};
            end
            
            numFeatureslocal = sfeatureExtractor.getNumFeatures();
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'ExpNextFeat', stateIndices,numFeatureslocal);

            obj = obj@Learner.Learner();
            
            obj.stateFeature = sfeatureExtractor.featureName;
            
            obj.sfeatureExtractor = sfeatureExtractor;
            obj.sakernel = stateactionkernel;
            obj.nsfeatureExtractor = nsfeatureExtractor;
            obj.linkProperty('resetProbTimeSteps');
            obj.linkProperty('RKHSparams_V');
            obj.linkProperty('RKHSparams_ns');
            obj.linkProperty('usetomlab');
            obj.linkProperty('useslowness');
            obj.currentInputFeature = sfeatureExtractor.featureVariables{1}{1};
            obj.nextInputFeature = nsfeatureExtractor.featureVariables{1}{1};
            %only support a single input feature now
        end
        
        function [features] = getFeaturesInternal(obj, numFeatures, inputMatrix)
            inputVectors = obj.sakernel.getGramMatrix(obj.referenceStateActions, inputMatrix ); 
            K_sa = obj.K_sa_sa;
            
            m1 = size(obj.K_ref_s1,2);
            n = size(inputMatrix,1);

            cond_embed = (K_sa + obj.lambda*eye(size(K_sa)))\inputVectors; %one column for every (S,A) predict
            gamma = 1-obj.resetProbTimeSteps;
            % normal 'least squares'
            features = gamma * obj.K_ref_sprime * cond_embed + (1-gamma) /m1 * obj.K_ref_s1*ones(m1,n);
    

            if(size(features,2) > obj.getNumFeatures())
                warning('RKHSModelLearner_unc:numFeatures','amount of features not supported')
                features = features(1:obj.getNumFeatures(),:)';
            else
                zerofeatures = zeros(size(inputMatrix,1), obj.getNumFeatures()-size(features,1));
                features = [features', zerofeatures];
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
            n_episodes = data.getDataStructure.numElements;
            n_samples = data.getDataStructure.steps.numElements;
            objective = 0;
            obj.sakernel.setHyperParameters(exp(params(2:end)));
                
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
      
                trains = data.getDataEntry(obj.currentInputFeature, train_idx{:}); %states train
                vals = data.getDataEntry(obj.currentInputFeature, val_idx{:}); %states validate
                traina = data.getDataEntry('actions', train_idx{:}); %actions train
                vala = data.getDataEntry('actions', val_idx{:}); %actions validate
                valsprime =data.getDataEntry(obj.nextInputFeature, val_idx{:}); % next States validate
                trainsprime = data.getDataEntry(obj.nextInputFeature, train_idx{:}); %next states train

                
                skf = @(s1,s2) obj.sfeatureExtractor.kernel.getGramMatrix(s1,s2);
                locallambda = exp(params(1));
                sakf = @(sa1,sa2) obj.sakernel.getGramMatrix(sa1,sa2);

                Kt_in = sakf([trains, traina], [trains, traina]);
                Kt_out = skf(trainsprime,trainsprime);
                Ktv_in = sakf([trains, traina], [vals, vala]);
                Ktv_out = skf(trainsprime, valsprime);

                wts = (Kt_in + locallambda * eye(size(Kt_in))) \ Ktv_in;

                sumK_out = 0;
                for j = 1:size(vals,1)
                    sumK_out = sumK_out + skf(valsprime(j,:), valsprime(j,:));
                end
                pred_ft = Kt_out * wts;
                true_ft = Ktv_out;
                prediction_error = pred_ft - true_ft;
                foldobjective = sum(sum(prediction_error.^2));

                objective = objective + foldobjective;
            end
        end
        
        function objective = TDobjective(obj, data, params)
            % maximize for reward prediction
            % params: lambda_sa, lambda_r, stateparams, actionparams
            locallambda_r= exp(params(1));
            stateParams = exp(params(2:end));
            obj.sfeatureExtractor.kernel.setHyperParameters(stateParams);
            obj.nsfeatureExtractor.kernel.setHyperParameters(stateParams);
                
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
                
                coefs = (ft_dif_train * ft_dif_train'+ locallambda_r * eye(size(ft_dif_train * ft_dif_train')))\ ft_dif_train * rtc;
                TD = ft_dif_val' * coefs - (rv - mean(rt));
                
                foldobjective = sum(TD.^2);

                if(imag(foldobjective)~= 0)
                    %fprintf('Warning: complex predictions!')
                    foldobjective = real(foldobjective);
                end
                objective = objective + foldobjective;
            end            
        end
        
        function slowness = slownessObjective(obj, data, params)

            nStateParam = numel(obj.sfeatureExtractor.kernel.getHyperParameters());
            stateParams = exp(params(1:nStateParam));
            obj.sfeatureExtractor.kernel.setHyperParameters(stateParams);
            obj.nsfeatureExtractor.kernel.setHyperParameters(stateParams);
                
            s = data.getDataEntry(obj.currentInputFeature);
            sp = data.getDataEntry(obj.nextInputFeature);

            skf = @(s1,s2) obj.sfeatureExtractor.kernel.getGramMatrix(s1, s2);         
            K_sp_sp = skf(sp,sp);
            K_sp_s  = skf(sp,s);
            
            K_sp_sp = bsxfun(@minus,K_sp_sp, mean(K_sp_sp, 2));
            K_sp_s = bsxfun(@minus,K_sp_s, mean(K_sp_sp, 2));
            
            K_sp_sp=bsxfun(@rdivide, K_sp_sp, std(K_sp_sp,0,2));
            K_sp_s = bsxfun(@rdivide,K_sp_s, std(K_sp_sp,0,2));
            
            slowness =sum(sum((K_sp_sp-K_sp_s).^2));          
        end
        
        function setOptimalHyperParams(obj, data)         
            paramsoptstate = obj.RKHSparams_V;
            if(any(paramsoptstate < 0))               
                lparamsoptstate = log(obj.RKHSparams_V);
                tooptimize_state = find(paramsoptstate < 0);
                linitparams = log(-paramsoptstate(tooptimize_state));           
                getparams = @(params) Experiments.test.mergeVectors(lparamsoptstate, params, tooptimize_state );
                if(obj.useslowness)
                    objective = @(params) obj.slownessObjective(data,  getparams(params));
                    
                else
                    objective = @(params) obj.TDobjective(data,  getparams(params));
                end
                if(obj.usetomlab)
                    Prob = ProbDef; 
                    Prob.Solver.Tomlab = 'ucSolve';
                    stateparamsopt = fminunc(objective, linitparams,[],Prob );
                else
                    stateparamsopt = fminunc(objective, linitparams );
                end
                paramsopt = getparams(stateparamsopt);
            else
                paramsopt = log(paramsoptstate);
            end
            %newStateParams = exp(paramsopt(1:numel(obj.sfeatureExtractor.kernel.getHyperParameters())));         
            obj.nsfeatureExtractor.kernel.setHyperParameters(exp(paramsopt(2:end)));
            obj.sfeatureExtractor.kernel.setHyperParameters(exp(paramsopt(2:end)));
            
            exp(paramsopt)
            paramsoptactions = obj.RKHSparams_ns;
            if(any(paramsoptactions < 0))
                lparamsopt_ns = log(obj.RKHSparams_ns);
                tooptimize_actions = find(paramsoptactions < 0);
                linitparams = log(-paramsoptactions(tooptimize_actions));           
                getparams = @(params) Experiments.test.mergeVectors(lparamsopt_ns, params, tooptimize_actions );
                if(obj.usetomlab)
                    Prob = ProbDef; 
                    Prob.Solver.Tomlab = 'ucSolve';
                    [actionparamsopt,FVAL,EXITFLAG,OUTPUT] = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params) ), linitparams,[],Prob);
                else
                     [actionparamsopt,FVAL,EXITFLAG,OUTPUT] = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params) ), linitparams);
                end
                paramsopt = Experiments.test.mergeVectors(lparamsopt_ns, actionparamsopt, tooptimize_actions);
            else
                paramsopt = log(paramsoptactions);
            end
            
            exp(paramsopt)
   
            obj.lambda = exp(paramsopt(1));
              
            obj.sakernel.setHyperParameters(exp(paramsopt(2:end)));            
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
            
            idx = obj.sfeatureExtractor.getReferenceSetIndices();
            obj.referenceSetIndices = idx;
            obj.referenceStateActions = [states, actions];
            obj.referenceStateActions = obj.referenceStateActions(idx,:);
            
            obj.K_sa_sa = obj.sakernel.getGramMatrix(obj.referenceStateActions,obj.referenceStateActions);
            obj.K_ref_sprime = obj.nsfeatureExtractor.getFeatures(:,nextStates(idx,:))';
            obj.K_ref_s = obj.sfeatureExtractor.getFeatures(:,states(idx,:))';
            obj.K_ref_s1 = obj.sfeatureExtractor.getFeatures(:,statesInit)';
            
            

            n_ref = size(obj.K_ref_s,2);
            n_sa = size(obj.K_sa_sa,1);      
            
            obj.K_sa_sa = obj.K_sa_sa(:,1:n_sa);
            obj.K_ref_sprime = obj.K_ref_sprime(1:n_ref,:);
            obj.K_ref_s = obj.K_ref_s(1:n_ref,:);
            obj.K_ref_s1 = obj.K_ref_s1(1:n_ref,:);
            
            
        end
    end
    
end

