classdef TrialFromScript < Experiments.Trial
    
    properties
       scriptName
       
       isConfigure = true;
       isStart = false;
       isDebug = false;
       
       workspace
    end
      
    
    methods
        function obj = TrialFromScript(settingsEval, evalDir, trialIdx, scriptName)
            obj = obj@Experiments.Trial(evalDir,  trialIdx);

            obj.scriptName = scriptName;
            trialEval = obj;
            if (~isempty(scriptName))
                eval(obj.scriptName);
                assert(obj.preConfigure == false, 'trial must be configured!');                    
                obj.saveWorkspace();
            end
        end
        
        function [] = saveWorkspace(obj)
            variables = evalin('caller', 'whos');
            
            for i = 1:length(variables)    
                if (~strcmp(variables(i).name, 'trial') && ~strcmp(variables(i).name, 'obj'))
                    obj.workspace.(variables(i).name) =  evalin('caller', variables(i).name);
                end
            end
        end
        
        
        function [] = storeTrial(obj, varargin)
            obj.saveWorkspace();

            obj.storeTrial@Experiments.Trial(varargin{:});        
        end
        
        function [] = loadWorkspace(obj)
            fieldNames = fieldnames(obj.workspace);
                        
            for i = 1:length(fieldNames)   
                assignin('caller', fieldNames{i}, obj.workspace.(fieldNames{i}))
            end
        end                                
        
        function [] = startInternal(obj)
            
            obj.isConfigure = false;
            obj.isStart = true;
            
            obj.loadWorkspace();
            trialEval = obj; 
            rng(trialEval.rngState);
                       
            eval(obj.scriptName);
            
            obj.saveWorkspace();
        end
    end
    
end

