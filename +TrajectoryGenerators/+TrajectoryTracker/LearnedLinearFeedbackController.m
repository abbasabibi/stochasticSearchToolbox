classdef LearnedLinearFeedbackController < TrajectoryGenerators.TrajectoryTracker.IFbGainsProvider & Data.DataManipulator & Learner.Learner
    
    properties
        trajDistrib
    end
    
    properties(AbortSet, SetObservable)
        
        estimateNoise = true;        
        fullNoiseMatrix = false;
        stochasticCtl = false;
        
        numCtl = 0;        
        numTimeSteps = 100;
        dt = 0.01;
        
        observationName 
        controlName
        
        Kp_t = [];
        Kd_t = [];
        k_t = [];
        Sigma_ut = [];        

        SysActionNoise = [];
        Noise_std;
        
        regularizationFactorFeedBackController = 10^-10;
    end
    
    methods
        
        function obj = LearnedLinearFeedbackController(dataManager, observationName, controlName, numJoints)
            obj@TrajectoryGenerators.TrajectoryTracker.IFbGainsProvider();
            obj@Data.DataManipulator(dataManager);
                        
            obj.observationName = observationName;
            obj.controlName = controlName;
            
            
            
            obj.linkProperty('dt');
            obj.linkProperty('numTimeSteps');
            obj.linkProperty('estimateNoise');
            obj.linkProperty('stochasticCtl');
            obj.linkProperty('Noise_std');
            obj.linkProperty('regularizationFactorFeedBackController');
            obj.unlinkProperty('regularizationFactorFeedBackController');
            
            obj.numCtl = numJoints;
            obj.SysActionNoise = eye(obj.numCtl) * obj.Noise_std^2;          
            
            obj.addDataManipulationFunction('getFeedbackGains', {}, ...
                      {''}, Data.DataFunctionType.PER_EPISODE, false );                                                        
            obj.setTakesData('getFeedbackGains', true);
            
            obj.addDataManipulationFunction('updateModel', {}, ...
                      {}, Data.DataFunctionType.ALL_AT_ONCE, false );                                                        
            obj.setTakesData('updateModel', true);
            
            
        end
        
        %% Interface implementation 
        
        function [] =  updateModel ( obj, data)  
            basis = data.getDataEntry('basis');
            observations = data.getDataEntry(obj.observationName);
            actions = data.getDataEntry(obj.controlName);
                                    
            X = basis;
            for i = 1:size(observations,2)
                X = [X, bsxfun(@times, basis, observations(:,i))];
            end
            
            theta = (X' * X + eye(size(X,2)) * obj.regularizationFactorFeedBackController) \ X' * actions;
            
            numBasis = size(basis,2);
            
            basisSingle = data.getDataEntry('basis', 1);
            obj.k_t = basisSingle  * theta(1:numBasis,:);
            for i = 1:obj.numCtl
                obj.Kp_t(:, i, :) = basisSingle * theta((1:numBasis) + numBasis * i,:);
                obj.Kd_t(:, i, :) = basisSingle * theta((1:numBasis) + numBasis * i + obj.numCtl * numBasis,:);
            end
        end
        
        function  [Kp_t, Kd_t, k_t, Sigma_u]  = getFeedbackGainsForT (obj, tms)
            
            
            t = tms(1); %TODO
            
            Kp_t = squeeze(obj.Kp_t(t,:, :))';
            Kd_t = squeeze(obj.Kd_t(t,:, :))';
            k_t  = squeeze(obj.k_t(t, :))'; 
            
            if ( obj.stochasticCtl)
                Sigma_u = obj.Sigma_ut(idxPos+t,:);                
            else
                Sigma_u = zeros(obj.numCtl, obj.numCtl);
            end
            
        end
                
        function [Kp, Kd, kff, SigmaCtl] = getFeedbackGains(varargin)
            Kp = obj.Kp_t;
            Kd = obj.Kd_t;
            kff = obj.k_t;
            if ( obj.stochasticCtl)
                SigmaCtl= obj.Sigma_ut;                
            else
                SigmaCtl = zeros(size(obj.Sigma_ut));
            end
        end
            
    end

end
