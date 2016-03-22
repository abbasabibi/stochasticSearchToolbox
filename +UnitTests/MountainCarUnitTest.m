classdef MountainCarUnitTest < matlab.unittest.TestCase
   
    
    properties
    end
    
    methods (Test)
        function testMountainCar(testCase)
            % Disable plots
            set(0,'DefaultFigureVisible','off');
            evalc('Tutorials.MountainCar.tests.testMountainCar'); 
            
            % close invisible plots
            close all;
            
            % Enable plots again
            set(0,'DefaultFigureVisible','on');
            
            % Check if MC succeed at least one time (softError)
            % also fails if all cars succeed at the same time (very
            % unlikely)
            testCase.verifyLessThan(-sum(data.getDataEntry('returns')),max(data.getDataEntry('timeSteps'))*size(data.getDataEntry('returns'),1));
        end
    end
    
end

