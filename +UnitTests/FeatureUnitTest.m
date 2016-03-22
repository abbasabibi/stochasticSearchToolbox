classdef FeatureUnitTest < matlab.unittest.TestCase
   
    
    properties
    end
    
    methods (Test)
        function testfeatures(testCase)

            evalc('Tutorials.Features.testFeatures');
                
            testCase.assertTrue(all(~beforeTags));
            testCase.assertTrue(all(all(~beforeValues)));
            testCase.assertTrue(all(afterTags));
            
            states = newData.getDataEntry('states');
            testCase.assertTrue(all(afterValues(:,1) == states)); 
            testCase.assertTrue(all(afterValues(:,2) == states.^2)); 
            
            testCase.assertTrue(all(ShouldBeZero == 0));
        end
    end
    
end


