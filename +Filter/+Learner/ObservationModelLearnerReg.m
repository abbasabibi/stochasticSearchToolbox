classdef ObservationModelLearnerReg < Filter.Learner.ObservationModelLearner
    %OBSERVATIONMODELLEARNERREG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        reducedKernelReferenceSet
    end
    
    methods
        function obj = ObservationModelLearnerReg(dataManager, gkkf, features, reducedKernelReferenceSet)
            obj = obj@Filter.Learner.ObservationModelLearner(dataManager, gkkf, features);
            
            obj.reducedKernelReferenceSet = reducedKernelReferenceSet;
        end
        
        function learnObservationModel(obj, data)
            obsRefIdx = obj.gkkf.obsKernelReferenceSet.getReferenceSetIndices();
            
            if islogical(obsRefIdx)
                obsRefIdx = find(obsRefIdx);
            end
            
            Kro   = obj.reducedKernelReferenceSet.getKernelVectors(data(obsRefIdx,:));
            
            m_red = obj.reducedKernelReferenceSet.getReferenceSetSize();
            m_win = obj.gkkf.winKernelReferenceSet.getReferenceSetSize();
            m_obs = obj.gkkf.obsKernelReferenceSet.getReferenceSetSize();
            
            G = obj.gkkf.obsKernelReferenceSet.getKernelMatrix();
            Lrr = eye(m_red) / (Kro * Kro' + obj.lambdaO * eye(m_red));
            GL = Kro * G * Kro' / (Kro * Kro' + obj.lambdaO * eye(m_red));
            
            obj.gkkf.outputTransMatrix = cell(length(obj.gkkf.outputData),1);
            for i = 1:length(obj.gkkf.outputData)
                obj.gkkf.outputTransMatrix{i} = obj.gkkf.outputData{i}' * Kro' / (Kro * Kro' + obj.lambdaO * eye(m_red));
            end
            
            obj.gkkf.G = G;
            obj.gkkf.GL = GL;
            obj.gkkf.R = obj.kappa * eye(m_red);
%             obj.gkkf.observationModel.setInputVariables(m_win);
%             obj.gkkf.observationModel.setOutputVariables(m_obs);
%             obj.gkkf.observationModel.setWeightsAndBias(GL,zeros(m_obs));
%             obj.gkkf.observationModel.setCovariance(obj.kappa * eye(m_win));
            obj.gkkf.Lrr = Lrr;
            obj.gkkf.Kro = Kro;
        end
    end
    
end

