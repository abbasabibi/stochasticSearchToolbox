classdef REPSBanditOneIterUnitTest < matlab.unittest.TestCase
   
    properties
    end
    
    methods (Test)
        function REPSBanditOneIterUnit(testCase)
            % Disable plots
            set(0,'DefaultFigureVisible','off');
            evalc('Tutorials.REPSLearner.testREPSBanditOneIter'); 
            
            % close invisible plots
            close all;
            
            % Enable plots again
            set(0,'DefaultFigureVisible','on');
            
           end
    end
    
end

