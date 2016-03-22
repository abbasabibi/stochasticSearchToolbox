classdef ObservationModelLearner < Learner.Learner & Data.DataManipulator & Learner.ParameterOptimization.HyperParameterObject
    %OBSERVATIONMODELLEARNERSTD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (AbortSet, SetObservable)
        lambdaO = 1e-6;
        kappa = 1e-3;
    end
    
    properties
        gkkf
    end
    
    methods
        function obj = ObservationModelLearner(dataManager, gkkf, features, varargin)
            obj = obj@Learner.Learner();
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.gkkf = gkkf;
            
            obj.linkProperty('lambdaO',[gkkf.name '_lambdaO']);
            obj.linkProperty('kappa',[gkkf.name '_kappa']);
            obj.unlinkProperty([gkkf.name '_lambdaO']);
            obj.unlinkProperty([gkkf.name '_kappa']);
            
            % register data manipulation functions
            obj.addDataManipulationFunction('learnObservationModel', features, {});
        end
        
        function learnObservationModel(obj, data)
            obsRefIdx = obj.gkkf.obsKernelReferenceSet.getReferenceSetIndices();
            winRefIdx = obj.gkkf.winKernelReferenceSet.getReferenceSetIndices();
            
            Ko2 = obj.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data(obsRefIdx,:),data(winRefIdx+1,:));
            Koo = obj.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data(obsRefIdx,:),data(obsRefIdx,:));
            
            obj.gkkf.Ko1 = obj.gkkf.winKernelReferenceSet.kernel.getGramMatrix(data(obsRefIdx,:),data(winRefIdx,:));
            obj.gkkf.Ko2 = Ko2;
            obj.gkkf.Koo = Koo;
            obj.gkkf.dataO = data(obsRefIdx,:);
            
            obj.gkkf.outputTransMatrix = cell(length(obj.gkkf.outputData),1);
            for i = 1:length(obj.gkkf.outputData)
                obj.gkkf.outputTransMatrix{i} = obj.gkkf.outputData{i}' * ((Koo + obj.lambdaO * eye(size(Koo))) \ Ko2);
            end
            
            O = (Koo + obj.lambdaO * eye(size(Koo))) \ Ko2;
            G = obj.gkkf.obsKernelReferenceSet.getKernelMatrix();
            obj.gkkf.setObservationModelWeightsBiasAndCov(O,zeros(size(O,1),1),obj.kappa * eye(size(O,1)));
            obj.gkkf.G = G;
        end
        
        function obj = updateModel(obj, data)
            obj.callDataFunction('learnObservationModel', data);
        end
    end
    
    % methods from HyperParameterObject
    methods
        function [numParams] = getNumHyperParameters(obj)
            numParams = 2;
        end
        
        function [] = setHyperParameters(obj, params)
            obj.lambdaO = params(1);
            obj.kappa = params(2);
        end
        
        function [params] = getHyperParameters(obj)
            params = [obj.lambdaO obj.kappa];
        end
    end
end

