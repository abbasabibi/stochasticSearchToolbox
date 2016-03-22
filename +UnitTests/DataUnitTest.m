classdef DataUnitTest < matlab.unittest.TestCase
   
    
    properties
    end
    
    methods (Test)
        
        function testDataManager(testCase)
            evalc('Data.tests.testDataManager');
            testCase.assertEqual(0, sum(checkVar));
        end
        
        function testDataManagerAliases(testCase)
            evalc('Data.tests.testDataManagerAliases');
            % isequal form the orignal testfile
            testCase.assertEqual(parameters, myData.getDataEntry('parameters'));
            testCase.assertEqual( weights, myData.getDataEntry('weights') );
            testCase.assertEqual(goals, myData.getDataEntry('goals') );
            testCase.assertEqual(goalVels, myData.getDataEntry('goalVels') );
            testCase.assertEqual( weights(:, subIndex), myData.getDataEntry('subWeights'));
        end
        
        function testDataManipulator(testCase)
            evalc('Data.tests.testDataManipulator');
        end
        
        function testDataManipulatorAlias(testCase)
            evalc('Data.tests.testDataManipulatorAlias');
        end
    end
    
end

