classdef Trial < dynamicprops & Common.IASObject
    
    properties
        trialDir;
        index;
        
        rngState = 1;
        
        storePerTrial = {};
        storePerIteration = {};
        
        
        preConfigure = true;
        isFinished = false;
        
        addToSettings
    end
    
    
    methods
        function obj = Trial(evalDir,  index)
            %Set new global settings to be filled by the configurators
            settingsTrial = Common.Settings('new');
            Common.SettingsManager.setRootSettings(settingsTrial);
            
            obj = obj@dynamicprops();
            
            if((nargin > 0))
                if (exist(evalDir,'dir'))
                    obj.trialDir = fullfile(evalDir,sprintf('trial%03d',index));
                    mkdir(obj.trialDir);
                    if(isunix)
                        system(sprintf('chmod 775 %s',obj.trialDir));
                    end
                    fclose(fopen(fullfile(obj.trialDir,'trial.log'),'a'));
                    if(isunix)
                        system(sprintf('chmod 664 %s',fullfile(obj.trialDir,'trial.log')));
                    end
                else
                    %                    fprintf('Trial %s Directory Not Found, Log disabled\n', obj.trialDir);
                end
                
                
                obj.index = index;
                rng('default');
                rng(index);
                obj.rngState = rng();
                
            end
        end
        
        function [] = addInitializerToSettings(obj, initializerName, initFunction)
            obj.setprop(initializerName, initFunction);
        end
        
        function setprop(obj, name, value, addToSettings)
            if (~exist('addToSettings', 'var'))
                addToSettings = true;
            end
            if(~isprop(obj,name))
                
                obj.addprop(name);
                if (obj.preConfigure && addToSettings)
                    obj.linkProperty(name);
                end
                obj.addToSettings.(name) = addToSettings;
            else
                obj.addToSettings.(name) = addToSettings;
            end
            
            if(nargin > 2)
                obj.(name) = value;
                if (obj.preConfigure && obj.addToSettings.(name))
                    obj.settings.setProperty(name, value);
                end
            end
        end
        
        function isProp = isProperty(obj, name)
            isProp = isprop(obj,name);
        end
        
        function [] = configure(obj, settings)
            obj.settings.copyProperties(settings);
            obj.preConfigure = false;
        end
        
        
        function store(obj,name,value,mode)
            if(~exist('mode','var') || isempty(mode))
                mode = Experiments.StoringType.STORE;
            end
            
            
            switch mode
                case Experiments.StoringType.STORE_PER_ITERATION
                    obj.setprop(name,value);
                    obj.storePerIteration = union(obj.storePerIteration,name);
                case Experiments.StoringType.ACCUMULATE_PER_ITERATION
                    if(isa(value,'Common.IASObject'))
                        value = value.clone();
                    end
                    if(isprop(obj,name))
                        obj.(name) = vertcat(obj.(name), value);
                    else
                        obj.setprop(name,value);
                    end
                    obj.storePerIteration = union(obj.storePerIteration,name);
                case Experiments.StoringType.ACCUMULATE
                    if(isa(value,'Common.IASObject'))
                        value = value.clone();
                    end
                    if(isprop(obj,name))
                        obj.(name) = vertcat(obj.(name), value);
                    else
                        obj.setprop(name,value);
                    end
                    
                    obj.storePerTrial = union(obj.storePerTrial,name);
                    
                case Experiments.StoringType.STORE
                    obj.setprop(name,value);
                    obj.storePerTrial = union(obj.storePerTrial,name);
                otherwise
                    error('Trial:store','Unknown mode: %s',mode.char);
            end
            
        end
        
        function stored = storeTrial(obj, varargin)
            stored = obj.storeTrialInFile('trial.mat', varargin{:});
        end
        
        function stored = storeTrialInFile(obj,fileName, overwrite)
            if (~exist('overwrite', 'var'))
                overwrite = true;
            end
            
            data = struct();
            trial = obj;
            for name = trial.storePerTrial
                data.(name{1}) = trial.(name{1});
            end
            filename = fullfile(trial.trialDir,'data.mat');
            save(filename,'data');
            if(isunix)
                system(sprintf('chmod 775 %s',filename));
            end
            
            if (overwrite || ~exist(fullfile(obj.trialDir,fileName), 'file'))
                trial = obj;
                save(fullfile(obj.trialDir,'tempTrial'),'trial', '-v7.3');
                if(isunix)
                    system(sprintf('chmod 664 %s',fullfile(obj.trialDir,'tempTrial.mat')));
                end
                movefile(fullfile(obj.trialDir,'tempTrial.mat'),fullfile(obj.trialDir,fileName));
                stored = true;
            else
                stored = false;
            end
        end
        
        function start(obj, withCatch, withProfiling)
            
            if (obj.isFinished)
                fprintf('Trial %s already finished! Not repeating trial!\n', obj.trialDir);
                return;
            end
            
            if(~exist('withCatch','var'))
                withCatch = false;
            end
            
            if(~exist('withProfiling','var'))
                withProfiling = false;
            end
            
            oldDiary = get(0,'DiaryFile');
            diary(fullfile(obj.trialDir,'trial.log'));
            
            
            if(withProfiling)
                profile off;
                profile on -timer real -history;
            end
            
            % set the settings
            Common.SettingsManager.setRootSettings(obj.settings);
            
            fprintf('STARTING SCENARIO!!\n');
            
            if(withCatch)
                try
                    obj.startInternal();
                    
                catch err
                    fprintf('Error %s\n',err.identifier);
                    fprintf('\t%s\n',err.message);
                    tmp = struct2cell(err.stack);
                    fprintf('\t%s\n\t%s : %d\n',tmp{:});
                    
                    diary; diary;
                end
            else
                obj.startInternal();
                
            end
            if(withProfiling)
                profileInfo = profile('info');
                save(fullfile(obj.trialDir,'profileInfo'),'profileInfo');
                clear profileInfo;
                profile off;
            end
            
            if(exist(oldDiary,'file'))
                diary(oldDiary);
            end
            obj.isFinished = true;
            obj.storeTrial();
        end
    end
    
    methods (Abstract)
        [] = startInternal(obj);
        
    end
end

