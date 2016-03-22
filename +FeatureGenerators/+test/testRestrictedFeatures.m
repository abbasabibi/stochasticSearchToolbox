classdef testRestrictedFeatures < matlab.unittest.TestCase
    %TESTRESTRICTEDFEATURES Test restricted features
    
    properties
    end
    
    methods(Test)
        function doTestRestrictedFeatures(obj)
            rng(0);
            dataManager = Data.DataManager('episodes');
            minVal = -1;
            maxVal = 1.5;
            dataManager.addDataEntry('parameters', 1, minVal, maxVal);
            %dataManager.dataEntries('parameters').minRange
            %dataManager.getMaxRange('parameters');
            %dataManager.getMinRange('parameters');
            r = FeatureGenerators.RestrictedFeatures(dataManager, 'parameters');
            
            
            
            newData = dataManager.getDataObject(100);
            params = randn(100,1);
            
            newData.setDataEntry('parameters', params);
            
            paramsstored = newData.getDataEntry('parameters');
            paramsrestricted = newData.getDataEntry('parametersRestricted');
            obj.verifyTrue(any(paramsstored>maxVal) ); % to check input data to test is meaningful
            obj.verifyTrue(any(paramsstored<minVal) ); % to check input data to test is meaningful
            obj.verifyFalse(any(paramsrestricted>maxVal) );
            obj.verifyFalse(any(paramsrestricted<minVal) );  
            obj.verifyEqual(max(paramsrestricted), maxVal);
            obj.verifyEqual(min(paramsrestricted), minVal);
        end
    end
    
end

