classdef testBayesianLinearPolicy < matlab.unittest.TestCase
    %TESTBAYESIANLINEARPOLICY test learning and hyperparameterlearning
    % of the bayesian linear policy
    
    properties
        dataManager
        linearBayesianPolicy
        linearGP %for comparison
        
        primalPolicy
        primalLearner
        dualPolicy
        dualLearner
    end
    
    methods(TestMethodSetup)
        function initializeRNG(~)
            rng(3);
        end
        
        function initDataManager(obj)
            dm2 = Data.DataManager('episodes');
            dm = Data.DataManager('steps');
            dm.addDataEntry('states', 2);
            dm.addDataEntry('nextStates', 2);
            dm.addDataEntry('rewards',1);
            dm.addDataEntry('actions',1);
            dm.addDataEntry('timeSteps',1);
            dm.addDataEntry('weights',1);
            dm.finalizeDataManager();
            dm2.setSubDataManager(dm);
            dm2.finalizeDataManager();
            %dm2.
            obj.dataManager = dm2;
        end
        

    end
    
    methods(Test)
        function testFixedHyperParams(obj)
            obj.primalPolicy = Distributions.Gaussian.GaussianLinearInFeaturesQuadraticCovariance(obj.dataManager, 'actions', {'states'}, 'primal');
            obj.primalLearner = Learner.SupervisedLearner.BayesianLinearPolicyLearner(obj.dataManager, obj.primalPolicy);
            
            kernel = Kernels.LinearKernel(obj.dataManager, 2, 'linear');
            obj.dualPolicy = Kernels.GPs.GaussianProcess(obj.dataManager, kernel,'actions', {'states'});
            obj.dualLearner = Learner.SupervisedLearner.GPLearner(obj.dataManager, obj.dualPolicy);
            
            obj.primalLearner.setHyperParameters([1 0  1 1e-3]);
            obj.dualLearner.setHyperParameters([1 0  1 1e-3]);
            obj.dualLearner.setWeightName('weights' );
            obj.dualPolicy.setWeightName('weights' );
            
            states = randn(50,2);
            actions = sin(sum(states,2)) + 0.4 * randn(50,1);
            weights = exp ( -(sin(sum(states,2)) - actions).^2* 10);

            myData = obj.dataManager.getDataObject([1,50]);
            myData.setDataEntry('states', states);
            myData.setDataEntry('actions', actions);
            myData.setDataEntry('timeSteps', [1:50]');
            myData.setDataEntry('weights',weights);
            
            obj.dualPolicy.setReferenceSet(myData, 1:50 )
            obj.primalLearner.learnFunction(states, actions, weights )
            obj.dualLearner.learnFunction(states, actions, weights )
            
            [x1, x2] = meshgrid(-2.5:0.2:2.5);
            [zdual,sigmadual] = obj.dualPolicy.getExpectationAndSigma(numel(x1), [x1(:), x2(:) ]);
            [zprimal,sigmaprimal] = obj.primalPolicy.getExpectationAndSigma(numel(x1), [x1(:), x2(:) ]);
            
%             figure(1)
%             scatter3(states(:,1), states(:,2), actions, weights*100)
%             hold on
%             surf(x1, x2, reshape(zdual,26,26)) 
%             hold off
%             
%             figure(2)
%             scatter3(states(:,1), states(:,2), actions, weights*100)
%             hold on
%             surf(x1, x2, reshape(zprimal,26,26)) 
%             hold off    
            obj.verifyEqual(zdual, zprimal, 'AbsTol', 1e-6 )
            obj.verifyEqual(sigmadual, sigmaprimal, 'AbsTol', 1e-6 )
        end
        
        function testCrossValidationFunction(obj)
            %kernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2, 'expQuad');
            %features = Kernels.KernelBasedFeatureGenerator(obj.dataManager, kernel, 'states', '~sqexpfeatures');
            %kernel2 = Kernels.LinearKernel(obj.dataManager, 50, 'linearKernel');
            %obj.primalPolicy = Distributions.Gaussian.GaussianLinearInFeaturesQuadraticCovariance(obj.dataManager, 'actions', {features.outputName}, 'primal');
            obj.primalPolicy = Distributions.Gaussian.GaussianLinearInFeaturesQuadraticCovariance(obj.dataManager, 'actions', {'states'}, 'primal');
            obj.primalLearner = Learner.SupervisedLearner.BayesianLinearPolicyLearner(obj.dataManager, obj.primalPolicy);
            
            
            %obj.dualPolicy = Kernels.GPs.GaussianProcess(obj.dataManager, kernel2,'actions', {features.outputName});
            %obj.dualLearner = Learner.SupervisedLearner.GPLearner(obj.dataManager, obj.dualPolicy);    
            
            myData = obj.dataManager.getDataObject([2,25]);
            states = randn(50,2);
            actions = sin(sum(states,2)) + 0.4 * randn(50,1);
            weights = 0.01+exp ( -(sin(sum(states,2)) - actions).^2* 10);
            weights(1:25) = weights(1:25)/ max(weights(1:25));
            weights(26:50) = weights(26:50)/ max(weights(26:50));
            myData.setDataEntry('states', states);
            myData.setDataEntry('actions', actions);
            myData.setDataEntry('timeSteps', [1:25, 1:25]');
            myData.setDataEntry('weights',weights);
            
            primalHyperLearner = Learner.SupervisedLearner.BayesianLinearHyperLearnerCV(obj.dataManager, obj.primalPolicy);
            %dualHyperLearner = Kernels.Learner.GPHyperParameterLearnerCVTrajLikelihood.CreateWithStandardReferenceSet(obj.dataManager, obj.dualPolicy);
            
            primalHyperLearner.setWeightName('weights')
            primalHyperLearner.processTrainingData(myData);
            %dualHyperLearner.processTrainingData(myData);
            primalHyperLearner.initializeParameters(myData)
            primalHyperLearner.initializeOptimizer()
            
            likely1 = primalHyperLearner.objectiveFunction([1 1e-3 ]);
            %dualHyperLearner.objectiveFunction([1 1 1 1e-3 ])
            
            s1 = states(1:25,:);
            s2 = states(26:50,:);
            a1 = actions(1:25,:);
            a2 = actions(26:50,:);
            w1 = weights(1:25,:);
            w2 = weights(26:50,:);
            obj.primalLearner.learnFunction(s1, a1,  w1);
            %[mu_a,sigma_a] = obj.primalPolicy.getExpectationAndSigma(25, s2);
            %likely2a = 
            pa = obj.primalPolicy.getDataProbabilities(s2, a2);
            
            obj.primalLearner.learnFunction(s2,a2,w2)
            pb = obj.primalPolicy.getDataProbabilities(s1, a1);
            %[mu_b,sigma_b] = obj.primalPolicy.getExpectationAndSigma(25, s1);
            
            likely2 = pa' * w2 + pb' * w1;
            
            obj.verifyEqual(likely1, likely2, 'RelTol', 1e-6 )
        end
        
%         function testHyperParameterLearning(obj)
%             kernel = Kernels.ExponentialQuadraticKernel(obj.dataManager, 2, 'expQuad');
%             features = Kernels.KernelBasedFeatureGenerator(obj.dataManager, kernel, 'states', '~sqexpfeatures');
%             kernel2 = Kernels.LinearKernel(obj.dataManager, 50, 'linearKernel');
%             obj.primalPolicy = Distributions.Gaussian.GaussianLinearInFeaturesQuadraticCovariance(obj.dataManager, 'actions', {features.outputName}, 'primal');
%             obj.primalLearner = Learner.SupervisedLearner.BayesianLinearPolicyLearner(obj.dataManager, obj.primalPolicy);
%             
%             
%             obj.dualPolicy = Kernels.GPs.GaussianProcess(obj.dataManager, kernel2,'actions', {features.outputName});
%             obj.dualLearner = Learner.SupervisedLearner.GPLearner(obj.dataManager, obj.dualPolicy);
%             
%             primalHyperLearner = Learner.SupervisedLearner.BayesianLinearHyperLearnerCV(obj.dataManager, obj.primalPolicy);
%             dualHyperLearner = Kernels.Learner.GPHyperParameterLearnerCVTrajLikelihood.CreateWithStandardReferenceSet(obj.dataManager, obj.dualPolicy);
%             
%             
%             myData = obj.dataManager.getDataObject([2,25]);
%             states = randn(50,2);
%             actions = sin(sum(states,2)) + 0.4 * randn(50,1);
%             myData.setDataEntry('states', states);
%             myData.setDataEntry('actions', actions);
%             myData.setDataEntry('timeSteps', (1:50)');
%             myData.setDataEntry('weights',exp ( -(sin(sum(states,2)) - actions).^2* 10));
%             
%             primalHyperLearner.updateModel(myData);
%             primalHyperLearner.getHyperParameters;
%             
%             dualHyperLearner.updateModel(myData);
%             dualHyperLearner.getHyperParameters;
%         end
    end
    
end

