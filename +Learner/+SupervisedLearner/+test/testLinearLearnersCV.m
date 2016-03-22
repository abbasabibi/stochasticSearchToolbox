classdef testLinearLearnersCV < matlab.unittest.TestCase
    
    methods(TestMethodSetup)
        function initializeRNG(~)
            
            rng(3);

        end
    end
    methods(Test)
        function testRegression(obj)
            dataManager = Data.DataManager('steps');
            dataManager.addDataEntry('states', 2);
            dataManager.addDataEntry('actions', 2);

            dataManager.addDataEntry('rewardWeighting', 1);
            dataManager.finalizeDataManager();
            newData = dataManager.getDataObject(1000);
            newData.setDataEntry('states', randn(1000,2));
            gaussianDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', {'states'}, 'ActionPolicy');

            gaussianDistribution.initObject();

            weights = randn(gaussianDistribution.dimOutput, gaussianDistribution.dimInput);
            bias =  randn(gaussianDistribution.dimOutput,1);
            Sigma2 = [0.02, 0.01; 0.01, 0.04];
            gaussianDistribution.setWeightsAndBias(weights, bias);
            gaussianDistribution.setCovariance(Sigma2);

            gaussianDistribution.callDataFunction('sampleFromDistribution', newData);

            %First test the linear regression
            learnerFunction = Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(dataManager, gaussianDistribution);
            learnerFunction.updateModel(newData);

            obj.verifyEqual(bias, gaussianDistribution.bias,'AbsTol',0.1);
            
            obj.verifyEqual(weights, gaussianDistribution.weights, 'AbsTol',0.1);%0.1 tolerance

        end
        
        function testCrossValidation(obj)
            dimstates = 5;
            nsamples = 100;
            dataManager = Data.DataManager('steps');
            dataManager.addDataEntry('states', dimstates);
            dataManager.addDataEntry('actions', 1);

            dataManager.addDataEntry('rewardWeighting', 1);
            dataManager.finalizeDataManager();
            newData = dataManager.getDataObject(nsamples);
            newData.setDataEntry('states', randn(nsamples,dimstates));
            gaussianDistribution = Distributions.Gaussian.GaussianLinearInFeatures(dataManager, 'actions', {'states'}, 'ActionPolicy');

            gaussianDistribution.initObject();

            weights = randn(gaussianDistribution.dimOutput, gaussianDistribution.dimInput);
            bias =  randn(gaussianDistribution.dimOutput,1);
            Sigma2 = [10];
            gaussianDistribution.setWeightsAndBias(weights, bias);
            gaussianDistribution.setCovariance(Sigma2);

            gaussianDistribution.callDataFunction('sampleFromDistribution', newData);

            %First test the linear regression
            learnerFunction = Learner.SupervisedLearner.LinearFeatureFunctionMLLearner(dataManager, gaussianDistribution);
            
            optimizer = Learner.ParameterOptimization.CVHyperParameterOptimizer(dataManager, learnerFunction, @(fa, ti,to,w) -Learner.ParameterOptimization.CVHyperParameterOptimizer.negLogLikelihood(fa, ti,to,w), 2, 1e-5, 'regularizationOpt',true );
            optimizer.debugMessages = false;
            optimizer.updateModel(newData);
            %optimizer.optimizeHyperParameters( );
            learnerFunction.updateModel(newData);
            lambda = optimizer.getParametersToOptimize;
            obj.verifyEqual(lambda, 0.02,'AbsTol',0.01); %for this particular example / random seed
        end
    end
end




