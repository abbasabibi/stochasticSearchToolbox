classdef PendulumPolicy < Functions.Mapping
    %GAUSSIANMIXTUREMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetObservable,AbortSet)
        
    end
    
    properties (SetAccess=protected)
    end
    
    
    methods
        
        %%
        function obj = PendulumPolicy(dataManager, outputVariables, inputVariables)
            superargs = {};
            if (nargin >= 1)
                superargs = {dataManager, outputVariables, inputVariables};
            end
            
            obj = obj@Functions.Mapping(superargs{:});
            
               
%             obj.addMappingFunction('sampleFromDistributionOption');
            obj.addMappingFunction('sampleAction');
            
       
            
        end
        
        
      
        %%
        function initObject(obj)
            obj.initObject@Functions.Mapping();
            
        end
        
    
        
        %%
        function [value] = sampleAction(obj, numElements, varargin)
            
            %The policy defines an attractor `band' with 
            %parameters dX and ddX which define the slant of the band.
            %Outside of this band the actions are chosen by bang bang
            %control

            statesAll = varargin{1};

            %%
            
%             dX      = 1;
%             ddX     = -15;
%             t       = [dX , ddX];
%             t       = t / norm(t);
%             margin  = 2.5;
%             pGain   = 100;
%             dGain   = 10;
            
            dX      = 1;
            ddX     = -5;
            t       = [dX , ddX];
            t       = t / norm(t);
            margin  = 2.5;
            pGain   = 100;
            dGain   = 100/abs(ddX);
            
            
            
            
            distToBand  = zeros(size(statesAll,1),1);
            direction   = zeros(size(statesAll,1),2); 
            value       = zeros(size(statesAll,1),1);
            for i = 1 : size(statesAll,1)
                state = statesAll(i,:);
                direction(i,:)    = -state - ((-state)*t')*t;
                distToBand(i)   = norm(direction(i,:));                
            end
            
            
            idxInside   = distToBand < margin;
            idxMinus    = ~idxInside & direction(:,1) > 0;            
            idxPlus     = ~idxInside & direction(:,1) < 0;
            
            
            value(idxInside)    = ( pGain * (-statesAll(idxInside,1)) + dGain * (-statesAll(idxInside,2) ));
            value(idxMinus)     = -100;
            value(idxPlus)      = 100;
%             value               = min(max(value,-40),40);
            

%             figure
%             hold on
%             plot(statesAll(idxInside,1), statesAll(idxInside,2) , 'm*' )
%             plot(statesAll(idxMinus,1), statesAll(idxMinus,2) , 'b*' )            
%             plot(statesAll(idxPlus,1), statesAll(idxPlus,2) , 'r*' )
      
            
        end


        
        
    end
    
end



