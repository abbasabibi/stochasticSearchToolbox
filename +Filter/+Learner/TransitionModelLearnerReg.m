classdef TransitionModelLearnerReg < Filter.Learner.TransitionModelLearner
    %TRANSITIONMODELLEARNERREG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        reducedKernelReferenceSet
    end
    
    methods
        function obj = TransitionModelLearnerReg(dataManager, gkkf, features, reducedKernelReferenceSet)
            obj = obj@Filter.Learner.TransitionModelLearner(dataManager, gkkf, features);
            
            obj.reducedKernelReferenceSet = reducedKernelReferenceSet;
        end
        
        function learnTransitionModel(obj, data)
            if islogical(obj.gkkf.winKernelReferenceSet.getReferenceSetIndices())
                idx = find(obj.gkkf.winKernelReferenceSet.getReferenceSetIndices());
            else
                idx = obj.gkkf.winKernelReferenceSet.getReferenceSetIndices();
            end
            data1 = data(idx,:);
            data2 = data(idx+1,:);
            
            Kr2 = obj.reducedKernelReferenceSet.getKernelVectors(data2);
            Kr1 = obj.reducedKernelReferenceSet.getKernelVectors(data1);
            
            m_red = obj.reducedKernelReferenceSet.getReferenceSetSize();
            m = obj.gkkf.winKernelReferenceSet.getReferenceSetSize();
            
            T = Kr2 * Kr1' / (Kr1 * Kr1' + obj.lambdaT * eye(m_red));

            if obj.learnTcov
                T_cov = obj.alpha * eye(m_red);
            else
                A = T * Kr1 - Kr2;
                T_cov = A * A' / m;
            end

            obj.gkkf.Kr1 = Kr1;
            obj.gkkf.Kr2 = Kr2;
            obj.gkkf.setTransitionModelWeightsBiasAndCov(T,zeros(size(T,1),1),T_cov);
            
            obj.gkkf.redKernelReferenceSet = obj.reducedKernelReferenceSet;
        end
        
        function obj = learnInitialValues(obj, numElements, initialData)
            C = obj.reducedKernelReferenceSet.getKernelVectors(initialData);
            obj.gkkf.initialMean = C * ones(numElements,1) / numElements;
            obj.gkkf.initialCov = cov(C');
        end
    end
    
end

