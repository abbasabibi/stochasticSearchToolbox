classdef SupervisedLearnerUnitTest < matlab.unittest.TestCase
   
    
    properties
    end
    
    methods (Test)
        function testBayesianQuadraticModel(testCase)
            % Does not work
            evalc('Learner.SupervisedLearner.test.testBayesianQuadraticModel');
        end
        
        function testLinearLearners(testCase)
            % evac does not work
            evalc('Tutorials.LinearLearner.testLinearLearners');
            %Tutorials.LinearLearner.testLinearLearners;
            % upper bounds not approved
            testCase.assertLessThan(sum(sum(abs(ParaWBError))),0.1);            
            testCase.assertLessThan(sum(sum(abs(ParaCError))),0.1);
        end
        
        function testLocallyWeighted(testCase)
            % Does not work
            
            % Disable plots
            set(0,'DefaultFigureVisible','off');
            evalc('Learner.SupervisedLearner.test.testLocallyWeighted');
            
            % close invisible plots
            close all;
            
            % Enable plots again
            set(0,'DefaultFigureVisible','on');
        end
    end
    
end

