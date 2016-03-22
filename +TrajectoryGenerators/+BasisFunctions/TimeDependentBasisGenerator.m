classdef TimeDependentBasisGenerator < FeatureGenerators.FeatureGenerator
    properties (SetObservable, AbortSet)
        numTimeDependentBasis = 20;        
    end
    
    methods
        
        function obj = TimeDependentBasisGenerator(dataManager, phaseGenerator)
            
            obj = obj@ FeatureGenerators.FeatureGenerator(dataManager, 'phase', 'Basis');
            obj.linkProperty('numBasisPhase');
            
            obj.numFeatures = obj.numTimeDependentBasis;
            
            if (exist('phaseGenerator', 'var'))
                obj.phaseGenerator = phaseGenerator;
            end
            obj.addDataManipulationFunction('generateTimeDependentBasis', {'phase'}, {'phaseBasis'});
        end
        
        function  [features] = getFeaturesInternal(obj, numElements, phase)            
            features = obj.generateBasis(phase);
        end        
    end
        
    
    methods (Abstract)
        [basis] = generateTimeDependentBasis(obj, phase);               
    end
end
