classdef FeatureModelLearnernew < Learner.Learner & FeatureGenerators.FeatureGenerator
    %RKHSFEATURELEARNER Updates conditional RKHS model and calculates
    %features
    
    properties(SetObservable,AbortSet)
        stateActionFeature;
        nextStateFeature;
               
        theta; %learned parameters

        resetProbTimeSteps = 0.1
        featureTag = 1;
        lambda = 1e-6;
        
        nsfeatureExtractor;
        safeatureExtractor;
        sfeatureExtractor;

        expparamsopt;

        RKHSparams_V;
        RKHSparams_ns;
        
        isFirstTimestep;
        useslowness = false
        
        referenceStateActions
        referenceSetIndices
        
        currentInputFeature;
        nextInputFeature;
        actionFeature;
        
        phi_s1
    end
    
    methods
        function obj = FeatureModelLearnernew(dataManager, stateIndices,sfeatureExtractor, nsfeatureExtractor, safeatureExtractor)


            featureVariables= {safeatureExtractor.featureVariables{:}};
            
            numFeatureslocal = sfeatureExtractor.getNumFeatures();
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'ExpNextFeat', stateIndices,numFeatureslocal);

            obj = obj@Learner.Learner();
            
            obj.stateActionFeature = safeatureExtractor.featureName;
            obj.nextStateFeature = nsfeatureExtractor.featureName;
            
            
            obj.safeatureExtractor = safeatureExtractor;
            obj.nsfeatureExtractor = nsfeatureExtractor;
            obj.sfeatureExtractor = sfeatureExtractor;
            
            obj.linkProperty('resetProbTimeSteps');
            obj.linkProperty('RKHSparams_V');
            obj.linkProperty('RKHSparams_ns');
            
            obj.linkProperty('useslowness');

            obj.currentInputFeature = sfeatureExtractor.featureVariables{1}{1};
            obj.nextInputFeature = nsfeatureExtractor.featureVariables{1}{1};
            obj.actionFeature = safeatureExtractor.featureVariables{1}{end};
            %only support a single input feature now
        end
        
        function [features] = getFeaturesInternal(obj, numFeatures, inputMatrix)
            inputFeatures = obj.safeatureExtractor.getFeatures(:, inputMatrix );
            m1 = size(obj.phi_s1,1);
            n = size(inputFeatures,1);

            pred_ft = inputFeatures * obj.theta;
            gamma = 1-obj.resetProbTimeSteps;
            % normal 'least squares'
            features = gamma * pred_ft + (1-gamma) /m1 * ones(n, m1) * obj.phi_s1;
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
            obj.safeatureExtractor.setHyperParameters(exp(params(2:end)));
                
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
                traina = data.getDataEntry(obj.actionFeature, train_idx{:}); %actions train
                vala = data.getDataEntry(obj.actionFeature, val_idx{:}); %actions validate
                valsprime =data.getDataEntry(obj.nextInputFeature, val_idx{:}); % next States validate
                trainsprime = data.getDataEntry(obj.nextInputFeature, train_idx{:}); %next states train

                train_in = obj.safeatureExtractor.getFeatures(:,[trains, traina]);
                train_out = obj.nsfeatureExtractor.getFeatures(:,trainsprime);
                val_in = obj.safeatureExtractor.getFeatures(:,[vals, vala]);
                val_out = obj.nsfeatureExtractor.getFeatures(:,valsprime);
                
                locallambda = exp(params(1));

                localtheta = (train_in' * train_in + locallambda * eye(size(train_in,2)))\train_in' * train_out;


                pred_ft = val_in * localtheta;
                true_ft = val_out;
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

                train_s_feat = obj.sfeatureExtractor.getFeatures(:,st);
                train_ns_feat = obj.nsfeatureExtractor.getFeatures(:,spt);
                val_s_feat = obj.sfeatureExtractor.getFeatures(:,sv);
                val_ns_feat = obj.nsfeatureExtractor.getFeatures(:,spv);


                
                ft_dif_train = gamma*train_ns_feat - train_s_feat;
                ft_dif_val   = gamma*val_ns_feat - val_s_feat;
                
                rtc = rt - mean(rt);
                
                coefs = (ft_dif_train' * ft_dif_train+ locallambda_r * eye(size(ft_dif_train' * ft_dif_train)))\ ft_dif_train' * rtc;
                TD = ft_dif_val * coefs - (rv - mean(rt));
                
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

            feat_s = obj.safeatureExtractor.getFeatures(:,s);
            feat_ns = obj.safeatureExtractor.getFeatures(:,sp);
                        
            feat_s = bsxfun(@minus,feat_s, mean(feat_s, 2));
            feat_ns = bsxfun(@minus,feat_ns, mean(feat_ns, 2));
            
            feat_s=bsxfun(@rdivide, feat_s, std(feat_s,0,2));
            feat_ns = bsxfun(@rdivide,feat_ns, std(feat_s,0,2));
            
            slowness =sum(sum((feat_ns-feat_s).^2));          
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

                stateparamsopt = fminunc(objective, linitparams );
                
                paramsopt = getparams(stateparamsopt);
            else
                paramsopt = log(paramsoptstate);
            end
            %newStateParams = exp(paramsopt(1:numel(obj.sfeatureExtractor.kernel.getHyperParameters())));         
            obj.nsfeatureExtractor.setHyperParameters(exp(paramsopt(2:end)));
            obj.sfeatureExtractor.setHyperParameters(exp(paramsopt(2:end)));
            
            exp(paramsopt)
            paramsoptactions = obj.RKHSparams_ns;
            if(any(paramsoptactions < 0))
                lparamsopt_ns = log(obj.RKHSparams_ns);
                tooptimize_actions = find(paramsoptactions < 0);
                linitparams = log(-paramsoptactions(tooptimize_actions));           
                getparams = @(params) Experiments.test.mergeVectors(lparamsopt_ns, params, tooptimize_actions );
                [actionparamsopt,FVAL,EXITFLAG,OUTPUT] = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params) ), linitparams);
                paramsopt = Experiments.test.mergeVectors(lparamsopt_ns, actionparamsopt, tooptimize_actions);
            else
                paramsopt = log(paramsoptactions);
            end
            
            exp(paramsopt)
   
            obj.lambda = exp(paramsopt(1));
              
            obj.safeatureExtractor.setHyperParameters(exp(paramsopt(2:end)));            
            obj.expparamsopt = exp(paramsopt);
        end
        
        function obj = updateModel(obj, data)
            obj.featureTag = obj.featureTag + 1; 
                    
            obj.setOptimalHyperParams( data);
 
            states = data.getDataEntry(obj.currentInputFeature);
            statesInit = data.getDataEntry(obj.currentInputFeature,:,1);
            obj.isFirstTimestep = data.getDataEntry('timeSteps') == 1;
            actions = data.getDataEntry(obj.actionFeature);
            nextStates = data.getDataEntry(obj.nextInputFeature);
            
            %phi_s = obj.sfeatureExtractor.getFeatures(:,states);
            phi_sa = obj.safeatureExtractor.getFeatures(:,[states,actions]);
            %phi_sa = [phi_s, phi_a];
            phi_ns = obj.nsfeatureExtractor.getFeatures(:,nextStates);
            obj.phi_s1 = obj.sfeatureExtractor.getFeatures(:,statesInit);
            
            n = size(phi_sa, 2);
            obj.theta = (phi_sa' * phi_sa + obj.lambda * eye(n))\phi_sa' * phi_ns;
            

            
            
        end
    end
    
end

