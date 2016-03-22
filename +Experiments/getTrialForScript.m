function [ trial, settingsEval] = getTrialForScript()
current_breakpoints = dbstatus('-completenames');
try
    trial   = 0;
    settingsEval = 0;
    if(evalin('caller','exist(''settingsEval'')') )
        settingsEval = evalin('caller', 'settingsEval');
    else
        settingsEval = Common.Settings();
    end
    
    if(evalin('caller','exist(''trialEval'')') )
        trial = evalin('caller', 'trialEval');
    else
        trial = Experiments.TrialFromScript(settingsEval, 'default', 0, '');
        trial.isStart = true;
        trial.isDebug = true;
        evalin('base', 'clear classes');
    end
   
    %   manager = evalin('base', 'manager');
catch me
    %   manager = 0;
end

pause(0.1)
dbstop(current_breakpoints);
end