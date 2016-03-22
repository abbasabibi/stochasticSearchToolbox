classdef NaoWalkBandit < Environments.EpisodicContextualParameterLearningTask
    
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
        numSamplesForAverage = 1;
    end
    
    methods (Static)
        function [outputConn] = getNaoConnection()
           % disp("")
            persistent connection;
            if (isempty(connection))
                connection = tcpip('127.0.0.1', 5953, 'InputBufferSize', 8000);
                set(connection, 'OutputBufferSize', 8000);
                set(connection, 'Timeout', 20);
                fopen(connection); 
            end
            outputConn = connection;
        end
    end
    
    methods
        
        function obj = NaoWalkBandit(sampler)
            
            obj = obj@Environments.EpisodicContextualParameterLearningTask(sampler,1, 8);

            obj.linkProperty('numSamplesForAverage');
            
            obj.dataManager.setRange('parameters', -ones(1, obj.dimParameters) * 5, ones(1, obj.dimParameters) * 5);
           obj.dataManager.setRange('contexts', ones(1,1) * 0.1, ones(1,1) * 0.8);
            
            obj.upperLim=[1.5, 0.2, 0.08, 0.22, 0.12, 6, 1, 1];
            obj.lowerLim=[0.05,0.02, 0.001 ,0.17, 0.02, 0.0,0.00,0.00];%[period dx increasing legextendion swingheight inclinationoffset kpx kpy]

            
            obj.setUseParallelFunctionCalls('sampleReturn', false);
        end
        
        function returns = sampleReturn(obj, context, parameters)
            
            indiv = 1./(1+exp(-1*parameters));
            indiv = indiv.*(obj.upperLim-obj.lowerLim) + obj.lowerLim;
            indiv=[indiv context];
            returns = obj.matlabAgent(indiv);
            
        end
        
    end
    
    methods (Access=public)
        
        function fitness = matlabAgent(obj,indiv)
            
            con =  NaoWalking.NaoWalkBandit.getNaoConnection();
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