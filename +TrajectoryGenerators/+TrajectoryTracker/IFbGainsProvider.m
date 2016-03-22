classdef IFbGainsProvider < Common.IASObject

    methods(Abstract) 
        %[Kp, Kd, kff, SigmaCtl] = getFeedbackGains(varargin)
        [ K, kff, SigmaCtl ] = getFeedbackGainsForT(obj,timesteps);
    end
    
end