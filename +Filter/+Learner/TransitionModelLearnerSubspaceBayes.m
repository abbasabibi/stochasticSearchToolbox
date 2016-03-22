classdef TransitionModelLearnerSubspaceBayes < Filter.Learner.TransitionModelLearner
    %TRANSITIONMODELLEARNERREG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        reducedKernelReferenceSet
    end
    
    methods
        function obj = TransitionModelLearnerSubspaceBayes(dataManager, gkkf, features, reducedKernelReferenceSet)
            obj = obj@Filter.Learner.TransitionModelLearner(dataManager, gkkf, features);
            
            obj.reducedKernelReferenceSet = reducedKernelReferenceSet;
        end
        
        function learnTransitionModel(obj, data)
            idx = obj.gkkf.winKernelReferenceSet.getReferenceSetIndices();
            data1 = data(idx,:);
            data2 = data(idx+1,:);
            
            Kr2 = obj.reducedKernelReferenceSet.getKernelVectors(data2);
            Kr1 = obj.reducedKernelReferenceSet.getKernelVectors(data1);
            
            m_red = obj.reducedKernelReferenceSet.getReferenceSetSize();
            m = obj.gkkf.winKernelReferenceSet.getReferenceSetSize();
            
            T = Kr1' / (Kr1 * Kr1' + obj.lambdaT * eye(m_red)) * Kr2;

%             if obj.learnTcov
%                 T_cov = obj.alpha * eye(m_red);
%             else
%                 A = T * Kr1 - Kr2;
%                 T_cov = A * A' / m;
%             end
            T_cov = zeros(size(T));

            obj.gkkf.Kr1 = Kr1;
            obj.gkkf.Kr2 = Kr2;
            obj.gkkf.setTransitionModelWeightsBiasAndCov(T,zeros(size(T,1),1),T_cov);
            
            obj.gkkf.redKernelReferenceSet = obj.reducedKernelReferenceSet;
        end
        
        function obj = learnInitialValues(obj, numElements, initialData)
            m_red = obj.reducedKernelReferenceSet.getReferenceSetSize();
            C = obj.reducedKernelReferenceSet.getKernelVectors(initialData);
            C = obj.gkkf.Kr2' / (obj.gkkf.Kr2 * obj.gkkf.Kr2' + obj.lambdaT * eye(m_red)) * C;
            obj.gkkf.initialMean = C * ones(numElements,1) / numElements;
            obj.gkkf.initialCov = cov(C');
        end
    end
    
end

