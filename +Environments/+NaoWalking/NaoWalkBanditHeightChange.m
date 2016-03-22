classdef NaoWalkBanditHeightChange < Environments.EpisodicContextualParameterLearningTask
    
    properties(GetAccess = 'public', SetAccess = 'public')
        

        
        indivHist;
        fitHist;
                
        ul;
        ll;
        upperLim;
        lowerLim;
        bestResult;
        
        
        
    end
    
    properties (SetObservable, AbortSet)
        numSamplesForAverage = 3;
    end
    
    methods (Static)
        function [outputConn] = getNaoConnection()
           % disp("")
            persistent connection;
            if (isempty(connection))
                connection = tcpip('127.0.0.1', 5957, 'InputBufferSize', 8000);
                set(connection, 'OutputBufferSize', 8000);
                set(connection, 'Timeout', 120);
                fopen(connection); 
            end
            outputConn = connection;
        end
    end
    
    methods
        
        function obj = NaoWalkBanditHeightChange(sampler)
            
            obj = obj@Environments.EpisodicContextualParameterLearningTask(sampler,1, 10);

            obj.linkProperty('numSamplesForAverage');
            
            obj.dataManager.setRange('parameters', -ones(1, obj.dimParameters) * 5, ones(1, obj.dimParameters) * 5);
            obj.dataManager.setRange('contexts', [0.1], [0.6]);
            %(period stepSize accelerationTime DSP  hight swingHight inclination kx ky amp )
            obj.upperLim=[1.8, 0.4, 0.2, 0.5, 0.22, 0.2, 5, 1, 1, 1];
            obj.lowerLim=[0.01,0.02,  0.000001 ,0.0, 0.16 ,0.02, 0,0,   0,0];%[period dx dsP legextendion swingheight]


            obj.setCallType('sampleReturn', Data.DataFunctionType.SINGLE_SAMPLE);
        end
        
        function returns = sampleReturn(obj, context, parameters)
            
            indiv = 1./(1+exp(-1*parameters));
            indiv = indiv.*(obj.upperLim-obj.lowerLim) + obj.lowerLim;
            
            %upperLimFlag = bsxfun(@gt,parameters',obj.upperLim');
            %lowerLimFlag = bsxfun(@gt,obj.lowerLim',parameters');
            
            %boundFlag = bsxfun(@or,upperLimFlag,lowerLimFlag);
            
%             punishment = -10000 .* boundFlag;
%             returns = sum(punishment);
%             
%             if (returns < 0)
%             
%                 return;
%             else
%             
            indiv=[indiv context];
            returns = obj.matlabAgent(indiv);
            
        end
        
    end
    
    methods (Access=public)
        
        function fitness = matlabAgent(obj,indiv)
            
            con = Environments.NaoWalking.NaoWalkBandit.getNaoConnection();
            fitnessSum=0;
            
            while con.BytesAvailable ~= 0
                tmp = fscanf(con, '%s');
            end
            
            for i=1:obj.numSamplesForAverage
                
                fprintf(con, '%f ', indiv);                
                Return=fscanf(con, '%f');
                fitnessSum =Return +fitnessSum;
                
            end
            
            fitness=fitnessSum/obj.numSamplesForAverage;
            
        end
        
    end
    
    
end