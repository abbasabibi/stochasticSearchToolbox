classdef ImportanceSamplingActionExpectationObservedSamples < DataPreprocessors.DataPreprocessor
    
    properties
        currentPolicy;
        minRange
        maxRange
    end
    
    % Class methods
    methods
        function obj = ImportanceSamplingActionExpectationObservedSamples(dataManager, currentPolicy)
            obj = obj@DataPreprocessors.DataPreprocessor();
            
            obj.currentPolicy = currentPolicy;
            
            depth = dataManager.getDataEntryDepth(currentPolicy.outputVariable);
            subManager = dataManager.getDataManagerForDepth(depth);
            
            subManager.addDataEntry('importanceWeights', 1);
            
            obj.minRange = dataManager.getMinRange(currentPolicy.outputVariable);
            obj.maxRange = dataManager.getMaxRange(currentPolicy.outputVariable);
        end
        
        function data = preprocessData(obj, data)
            
            dataProbabilityLog = obj.currentPolicy.callDataFunctionOutput('getDataProbabilities', data);
            
            p = exp(dataProbabilityLog);
            
            states = data.getDataEntry('states');
            Ustates = unique(states,'rows');
            actions = data.getDataEntry('actions');
            
            
            [~,sidx] = ismember(states,Ustates,'rows');
            
            % joint state action count
            Csa = zeros(size(Ustates,1),obj.maxRange-obj.minRange+1);
            
            for i=1:numel(sidx)
                Csa(sidx(i),actions(i)) = Csa(sidx(i),actions(i))+1;  
                
                %laplace
                %Cs = sum(sidx==sidx(i));
                %p(i) = ((p(i)*Cs)+1)/(Cs+obj.maxRange-obj.minRange+1);
            end
                       
            % compute q(a|s)
            Csa = bsxfun(@rdivide,Csa,sum(Csa,2));
            
            q = zeros(size(p));
            for i=1:numel(sidx)
                q(i) = Csa(sidx(i),actions(i));
            end
            
            importanceWeights = p ./ q;
            
            importanceWeights = importanceWeights  / sum(importanceWeights);
            
            data.setDataEntry('importanceWeights', importanceWeights);
            
            fprintf('Number of Effective Samples: %f\n', sum(importanceWeights) / max(importanceWeights));
        end
        
    end
end
