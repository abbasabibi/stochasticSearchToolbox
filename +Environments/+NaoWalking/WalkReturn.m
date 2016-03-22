classdef WalkReturn < Environments.EpisodicContextualParameterLearningTask
    
    properties(GetAccess = 'public', SetAccess = 'public')
        
        count;
        con;
        indivHist;
        fitHist;
        
        resampleNum;
        ul;
        ll;
        upperLim;
        lowerLim;
        bestResult;
    end
    
    
    methods
        
        function obj = WalkReturn(sampler)
            
            obj = obj@Environments.EpisodicContextualParameterLearningTask(sampler, 0, 8);
            obj.count = 0;
            obj.resampleNum=1;
            
            obj.dataManager.setMinRange('parameters', -ones(1, obj.dimParameters) * 5);
            obj.dataManager.setMaxRange('parameters', ones(1, obj.dimParameters) * 5);
            
            obj.upperLim=[1.5, 0.2, 0.08, 0.22, 0.1, 6, 3, 3];
            obj.lowerLim=[0.05,0.02, 0.001 ,0.17, 0.02, 0.01, 0.01, 0.01];
            
            %if(obj.con)
            obj.con
            obj.con = tcpip('127.0.0.1', 4164, 'InputBufferSize', 8000);
            obj.con
            set(obj.con, 'OutputBufferSize', 8000);
            set(obj.con, 'Timeout', 60);
            fopen(obj.con);
            
        end
        
        function returns = sampleReturn(obj, context, parameters)
            
            indiv=1./(1+exp(-1*parameters));
            indiv=indiv.*(obj.upperLim-obj.lowerLim) + obj.lowerLim;
            returns=obj.matlabAgent(indiv);
            
        end
        
    end
    
    methods (Access=public)
        
        function fitness = matlabAgent(obj,indiv)
            
            obj.count = obj.count + 1;
            fitnessSum=0;
            
            while obj.con.BytesAvailable ~= 0
                
                tmp = fscanf(obj.con, '%s')
                
            end
            
            for i=1:obj.resampleNum
               
                fprintf(obj.con, '%f ', indiv);
                Return=fscanf(obj.con, '%f');
                fitnessSum =Return +fitnessSum;
                
            end
 
            fitness=fitnessSum/obj.resampleNum;
             
        end
        
    end
    
    
    
    
end