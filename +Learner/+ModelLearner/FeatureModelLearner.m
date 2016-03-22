classdef FeatureModelLearner < Learner.Learner & FeatureGenerators.FeatureGenerator
    %FeatureModelLearner Updates feature regression model and calculates
    %expected next features
    
    properties(SetObservable,AbortSet)
        stateFeature;
        stateactionFeature;
        
        theta
        phi_s1
        
        resetProbTimeSteps = 0.1
        featureTag = 1;
        lambda = 1e-6;
        
        sfeatureExtractor;
        nsfeatureExtractor;
        safeatureExtractor;
        
        expparamsopt;

        Regressionparamsstate;
        Regressionparamsactions;
        currentInputFeature;
        nextInputFeature;
        
        isFirstTimestep;
        initRegularizationModel
    end
    
    methods
        function obj = FeatureModelLearner(dataManager, stateIndices,sfeatureExtractor,nsfeatureExtractor, safeatureExtractor)

            featureVariables={{[cell2mat(safeatureExtractor.featureVariables{1}) sfeatureExtractor.featureName]}};
            numFeatureslocal = sfeatureExtractor.getNumFeatures();
            obj = obj@FeatureGenerators.FeatureGenerator(dataManager, featureVariables, 'ExpNextFeat', stateIndices,numFeatureslocal);

            obj = obj@Learner.Learner();
            
            obj.stateFeature = sfeatureExtractor.featureName;
            obj.stateactionFeature = safeatureExtractor.featureName;

            obj.sfeatureExtractor = sfeatureExtractor;
            obj.safeatureExtractor = safeatureExtractor;
            obj.nsfeatureExtractor = nsfeatureExtractor;
            obj.linkProperty('resetProbTimeSteps');
            obj.linkProperty('initRegularizationModel');
            obj.currentInputFeature = sfeatureExtractor.featureVariables{1}{1};
            obj.nextInputFeature = nsfeatureExtractor.featureVariables{1}{1};
        end
        
        function [features] = getFeaturesInternal(obj, numFeatures, inputFeatures)

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
                % |
                % v TODO - data is constant, can be pre-computed            
                trains = data.getDataEntry(obj.currentInputFeature, train_idx{:}); %states train
                vals = data.getDataEntry(obj.currentInputFeature, val_idx{:}); %states validate
                traina = data.getDataEntry('actions', train_idx{:}); %actions train
                vala = data.getDataEntry('actions', val_idx{:}); %actions validate
                valsprime =data.getDataEntry(obj.nextInputFeature, val_idx{:}); % next States validate
                trainsprime = data.getDataEntry(obj.nextInputFeature, train_idx{:}); %next states train
                % ^ constant up to here
                % |
                %locallambda_sa = exp(params(1));

                
                sf = @(s) obj.sfeatureExtractor.getFeatures(size(s,1), s);
                locallambda = exp(params(1));
                saf = @(s,a) obj.safeatureExtractor.getFeatures(size(a,1), [s,a]);

                phi_t_in = saf(trains, traina);
                phi_t_out = sf(trainsprime);
                phi_v_in = saf(vals,vala);
                phi_v_out = sf(valsprime);

                %theta_local = (phi_t_in * phi_t_in' + locallambda * eye(size(phi_t_in,1)))\phi_t_in*phi_t_out';
                theta_local = (phi_t_in' * phi_t_in + locallambda * eye(size(phi_t_in,2)))\phi_t_in'*phi_t_out;
                pred_ft = phi_v_in * theta_local ;
                true_ft = phi_v_out;
                prediction_error = pred_ft - true_ft;
                foldobjective = sum(sum(prediction_error.^2));
                
                objective = objective + foldobjective;
            end
        end
        
 
        
        function setOptimalHyperParams(obj, data)
            %'optimizing RKHS hyperparameters'

            paramsoptactions = obj.initRegularizationModel;
            if(any(paramsoptactions < 0))
                
                tooptimize_actions = find(paramsoptactions < 0);
                linitparams = log(-paramsoptactions(tooptimize_actions));           
                getparams = @(params) Experiments.test.mergeVectors(log(paramsoptactions), params, tooptimize_actions );
                [actionparamsopt,FVAL,EXITFLAG,OUTPUT] = fminunc(@(params)  obj.optimizationObjective(data,  getparams(params) ), linitparams);
                paramsopt = Experiments.test.mergeVectors(log(paramsoptactions), actionparamsopt, tooptimize_actions);           
            else
                paramsopt = log(paramsoptactions);
            end
            
            exp(paramsopt)
            
            nStateParam = numel(obj.sfeatureExtractor.kernel.getHyperParameters());
            stateParams = exp(paramsopt(1:nStateParam));
            obj.sfeatureExtractor.kernel.setHyperParameters(stateParams);
            obj.nsfeatureExtractor.kernel.setHyperParameters(stateParams);
            obj.safeatureExtractor.kernel.setHyperParameters(exp(paramsopt));
            
            obj.lambda = exp(paramsopt(1));

        end
        
        function obj = updateModel(obj, data)
            obj.featureTag = obj.featureTag + 1; 
                    
            obj.setOptimalHyperParams( data);
 
            states = data.getDataEntry(obj.currentInputFeature);
            statesInit = data.getDataEntry(obj.currentInputFeature,:,1);
            obj.isFirstTimestep = data.getDataEntry('timeSteps') == 1;
            actions = data.getDataEntry('actions');
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

