classdef SamplerUnitTest < matlab.unittest.TestCase
    
    properties
    end
    
    methods (Test)
        function testEpisodicSampler(testCase)
            evalc('Sampler.test.testEpisodicSampler');
        end
        
        function testSequentialSampler(testCase)
            evalc('Sampler.test.testSequentialSampler');
        end
        
        function testDecisionStageSampler(testCase)
            % Does not work
            evalc('Sampler.test.testDecisionStageSampler');
        end
        
        function testGridStepSampler(testCase)
            % Does not work
            evalc('Sampler.test.testGridStepSampler');
        end
        
        function testSequentialResetSampler(testCase)
            evalc('Sampler.test.testSequentialResetSampler');
        end
        
        function testSequentialSamplerOptions(testCase)
            % Does not work
            evalc('Sampler.test.testSequentialSamplerOptions');
        end
    end
    
end

