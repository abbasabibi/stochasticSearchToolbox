classdef testFeatureModelLearner < matlab.unittest.TestCase
    %testFeatureModelLearner test whether the model based on fourier 
    % transform is similar to model learned on kernels.
    
    properties
        dataManager
    end
    
    methods(TestMethodSetup)
%         function initializeRNG(~)
%             
%             rng(3);
% 
%         end
%         
        function initDataManager(obj)
            dm2 = Data.DataManager('episodes');
            dm = Data.DataManager('steps');
            dm.addDataEntry('states', 2);
            dm.addDataEntry('nextStates', 2);
            dm.addDataEntry('rewards',1);
            dm.addDataEntry('actions',1);
            dm.addDataEntry('timeSteps',1);
            dm.finalizeDataManager();
            dm2.setSubDataManager(dm);
            dm2.finalizeDataManager();
            %dm2.
            obj.dataManager = dm2;
        end
    end
    methods(Test)
        % try with a linear system? then s-a-s -r tuples are easy to
        % generate...
        function testLinearSystem(obj)
            rng(3);
            nsamples = 100;
            states = randn(nsamples,2);
            actions = randn(nsamples,1);
            
            nextStates = [states(:,1) + 0.1 * states(:,2), states(:,2) + 0.1 * actions];
            rewards = 0.01 * actions.*actions + 0.1 * states(:,2).*states(:,2) + states(:,1).*states(:,1);
            newData = obj.dataManager.getDataObject([1,100]);

            newData.setDataEntry('states', states,1,':');
            newData.setDataEntry('nextStates', nextStates,1,':');
            newData.setDataEntry('rewards', rewards,1,':');
            newData.setDataEntry('actions', actions,1,':');
            newData.setDataEntry('timeSteps', (1:100)',1,':');
            
            
            skernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'expquad');
            sakernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 3,'expquad');
            nskernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'expquad');
            
            k_sfeatureExtractor = Kernels.KernelBasedFeatureGenerator(obj.dataManager, copy(skernel), {{'states'}},'skf');
            k_safeatureExtractor = Kernels.KernelBasedFeatureGenerator(obj.dataManager, copy(sakernel), {{'states','actions'}},'sakf');
            k_nsfeatureExtractor = Kernels.KernelBasedFeatureGenerator(obj.dataManager, copy(nskernel), {{'nextStates'}},'nskf');
            
            f_sfeatureExtractor = FeatureGenerators.FourierKernelFeatures(obj.dataManager, skernel, 500, {{'states'}});
            f_safeatureExtractor = FeatureGenerators.FourierKernelFeatures(obj.dataManager, sakernel, 500,{{'states','actions'}});
            f_nsfeatureExtractor = FeatureGenerators.FourierKernelFeatures(obj.dataManager, nskernel, 500,{{'nextStates'}});
            
            
            k_modelLearner = Learner.ModelLearner.RKHSModelLearnernew(obj.dataManager, ':',k_sfeatureExtractor,k_nsfeatureExtractor, k_safeatureExtractor.kernel);
            f_modelLearner = Learner.ModelLearner.FeatureModelLearnernew(obj.dataManager, ':',f_sfeatureExtractor,f_nsfeatureExtractor, f_safeatureExtractor);
            
%             k_modelLearner.RKHSparams_V = [-1e-2 -1 -5];
%             k_modelLearner.RKHSparams_ns = [-1e-2 -1 -5 -25];
%             
%             f_modelLearner.RKHSparams_V = [-1e-2 -1 -5];
%             f_modelLearner.RKHSparams_ns = [-1e-2 -1 -5 -25];
            
            k_modelLearner.sfeatureExtractor.setReferenceSet(newData,1:nsamples);
            k_modelLearner.nsfeatureExtractor.setReferenceSet(newData,1:nsamples);
            
%             k_modelLearner.updateModel(newData);
%             f_modelLearner.updateModel(newData);
%             
%             %check hyperparameters
%             k_modelLearner.sfeatureExtractor.getHyperParameters
%             k_modelLearner.sakernel.getHyperParameters
%             k_modelLearner.lambda
%             f_modelLearner.sfeatureExtractor.getHyperParameters
%             f_modelLearner.safeatureExtractor.getHyperParameters
%             f_modelLearner.lambda
            
            % compare without optimizing hyperparams
            k_modelLearner.RKHSparams_V = [1e-6 3 1.5];
            k_modelLearner.RKHSparams_ns = [1e-6 3 1.5 15];
            
            f_modelLearner.RKHSparams_V = [1e-6 3 1.5];
            f_modelLearner.RKHSparams_ns = [1e-6 3 1.5 15];

            k_modelLearner.updateModel(newData);
            f_modelLearner.updateModel(newData);
            
            ntest = 10;
            teststates = randn(ntest,2);
            testactions = randn(ntest,1);
            
            testnextStates = [teststates(:,1) + 0.1 * teststates(:,2), teststates(:,2) + 0.1 * testactions];
            
           
            %ff = f_modelLearner.safeatureExtractor.getFeatures(:,[teststates,testactions]);
            %kf = k_modelLearner.sakernel.getGramMatrix([teststates,testactions],[states, actions]);
            
            fpred = f_modelLearner.getFeatures(:,[teststates,testactions]);
            kpred = k_modelLearner.getFeatures(:,[teststates,testactions]);
            
            true_features_f = f_modelLearner.nsfeatureExtractor.getFeatures(:, testnextStates);
            true_features_k = k_modelLearner.nsfeatureExtractor.getFeatures(:, testnextStates);
            
            
            referenceFeatures = f_modelLearner.sfeatureExtractor.getFeatures(:, states);
            innerproduct_fpred = referenceFeatures * fpred';
            innerproduct_true_features_f = referenceFeatures * true_features_f';
            
%             %check prediction kernel
%             figure(1)
%             imagesc(kpred(:,1:100) - true_features_k(:,1:100))
%              median(median(abs(kpred(:,1:100) - true_features_k(:,1:100) )))
%             % check prediction features
%             figure(2)
%             imagesc(innerproduct_fpred' - innerproduct_true_features_f')
%             median(median(abs(innerproduct_fpred' - innerproduct_true_features_f')))
%             % features kernel vs fpred
%             figure(3)
%             imagesc(innerproduct_true_features_f' - true_features_k(:,1:100))
%             median(median(abs(innerproduct_true_features_f' - true_features_k(:,1:100))))
%             % prediction kernel vs fpred
%             figure(4)
%             imagesc(innerproduct_fpred' - kpred(:,1:100))
%             median(median(abs(innerproduct_fpred' - kpred(:,1:100))))

            %check prediction kernel
            obj.verifyEqual(kpred(:,1:100), true_features_k(:,1:100), 'AbsTol',1e-1);
            % check prediction features
            obj.verifyEqual(innerproduct_fpred', innerproduct_true_features_f', 'AbsTol',1e-1);
            % features kernel vs fpred
            obj.verifyEqual(innerproduct_true_features_f', true_features_k(:,1:100), 'AbsTol',1.6e-1);
            % prediction kernel vs fpred
            obj.verifyEqual(innerproduct_fpred', kpred(:,1:100), 'AbsTol',1.5e-1);

        end
%         
%         function testExponentialQuadraticBandwidths(obj)
% 
% 
%             states = randn(100,2);
%             kernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2,'expquad');
%             
%             kernel.bandWidth = [0.5, 2];
%             
%             g = kernel.getGramMatrix(states, states);
%             
% 
%             randStream = RandStream('mt19937ar','Seed',101);
%             nprojections = 80;
%             rp = kernel.getFourierProjection(nprojections, randStream, states);
%             b= rand(nprojections,1)*2*pi;
%             phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
%             
%             obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);            
%         end
%         
%         function testPeriodic(obj)
%             
%             states = randn(100,2);
%             kernel = Kernels.PeriodicKernel(obj.dataManager, 2,'periodic',2*pi);
%             
%             
%             g = kernel.getGramMatrix(states, states);
%             
%             randStream = RandStream('mt19937ar','Seed',101);
%             nprojections = 80;
%             rp = kernel.getFourierProjection(nprojections, randStream, states);
%             b= rand(nprojections,1)*2*pi;
%             phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
%             
%             obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);            
%         end
%         
%         function testProduct(obj)
%             states = randn(100,1);
%             states = sort(states);
%             kernel1 = Kernels.PeriodicKernel(obj.dataManager, 1,'periodic',2*pi);
%             kernel2 = Kernels.ExponentialQuadraticKernel(obj.dataManager, 1,'expquad');
%             
%             kernel = Kernels.ProductKernel(obj.dataManager, 1, {kernel1, kernel2}, {1, 1}, 'product' );
%             
% 
%             g = kernel.getGramMatrix(states, states);
%             
%             randStream = RandStream('mt19937ar','Seed',101);
%             nprojections =80;
%             rp = kernel.getFourierProjection(nprojections, randStream, states);
%             b= rand(nprojections,1)*2*pi;
%             phi = sqrt(2/nprojections)*cos(bsxfun(@plus, rp, b'));
%             
%             obj.verifyLessThanOrEqual(median(median( abs(g-phi*phi'))), 0.1);  
%         end
    end
end

