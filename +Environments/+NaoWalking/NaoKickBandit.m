classdef NaoKickBandit < Environments.EpisodicContextualParameterLearningTask
    
    properties(GetAccess = 'public', SetAccess = 'public')
        
        
        
        indivHist;
        fitHist;
        
        ul;
        ll;
        upperLim;
        lowerLim;
        bestResult;
        
      
        
      
        
        dimention
        population
        initial
        
        
    end
    
    properties (SetObservable, AbortSet)
        resampleNum = 3;
        variation = 50 ;
    end
    
    methods (Static)
        function [outputConn] = getNaoConnection()
            % disp("")
            persistent connection;
            
            if (isempty(connection))
                LEARNING_START_PORT = 4100;
                NUM_LEARNING_PORTS = 10;
                 currPort = LEARNING_START_PORT;
                %if(strcmp( get(con,'Status'),'open')~=1)
                conOpened = false;
                while ~conOpened
                    disp(strcat('Trying connection:',num2str(currPort)));
                    connection = tcpip('127.0.0.1', currPort);
                    set(connection, 'OutputBufferSize', 8000);
                    set(connection, 'Timeout', 200);
                    try
                        fopen(connection);
                        conOpened = true;
                    catch
                        currPort = currPort +1;
                        if(currPort == LEARNING_START_PORT+NUM_LEARNING_PORTS)
                            currPort = LEARNING_START_PORT;
                        end
                    end
                    
                end
            end
            outputConn = connection;
        end
    end
    
    methods
        
        function obj = NaoKickBandit(sampler)
            
            obj = obj@Environments.EpisodicContextualParameterLearningTask(sampler,1, 22);
            
%            obj.linkProperty('numSamplesForAverage');    
            
             %obj.upperLim=[1.8, 0.4, 0.2, 0.5, 0.22, 0.2, 5, 1, 1, 1];
            %obj.lowerLim=[0.01,0.02,  0.000001 ,0.0, 0.16 ,0.02, 0,0,   0,0];%[period dx dsP legextendion swingheight]
            obj.establishConnection();
            
            %obj.lowerLim=obj.initial-(obj.variation/100)*obj.initial;
            %obj.upperLim=obj.initial+(obj.initial -obj.lowerLim);
            
            obj.dataManager.setRange('parameters', obj.initial-[0.7 8*ones(1, obj.dimParameters-1)], obj.initial+[0.7 ones(1, obj.dimParameters-1) * 8]);
            obj.dataManager.setRange('contexts', [3], [12.5]);
            %(period stepSize accelerationTime DSP  hight swingHight inclination kx ky amp )
          
            
            obj.setCallType('sampleReturn', Data.DataFunctionType.SINGLE_SAMPLE);
        end
        
        
        function  establishConnection(obj)
            
            con =  Environments.NaoWalking.NaoKickBandit.getNaoConnection();
            
            %end
            disp('clear buf');
            %   clear buffer
            while get(con, 'BytesAvailable') ~= 0
                tmp = fscanf(con, '%s');
            end
            fprintf(con, '%s ', 'start');
            
            disp('Sucessful connection..Reading resampleNum');
            obj.resampleNum=fscanf(con, '%d');
            
            disp('Reading dimention');
            obj.dimention = fscanf(con, '%d');
            
            disp('Reading population');
            obj.population = fscanf(con, '%d');
            
            disp('Reading initial');
            obj.initial =[];
            for i=1:obj.dimention
                %disp(fgets(con));
                obj.initial = [obj.initial fscanf(con, '%f')];
            end
            obj.resampleNum = 3;
            
        end
        
        
        function returns = sampleReturn(obj, context, parameters)
            
            %             indiv = 1./(1+exp(-1*parameters));
            %             indiv = indiv.*(obj.upperLim-obj.lowerLim) + obj.lowerLim;
            %
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
            %indiv=[indiv context];
            indiv=[parameters context];
            returns = obj.matlabAgent(indiv);
            
        end
        
    end
    
    methods (Access=public)
        
        function fitness = matlabAgent(obj,indiv)
            
            con =  Environments.NaoWalking.NaoKickBandit.getNaoConnection();
            fitnessSum=0;
            
            while con.BytesAvailable ~= 0
                tmp = fscanf(con, '%s');
            end
            
            for i=1:obj.resampleNum
                
                fprintf(con, '%f ', indiv);
                Return=fscanf(con, '%f');
                fitnessSum =-1*Return +fitnessSum;
                
            end
            
            fitness=fitnessSum/obj.resampleNum;
            
        end
        
    end
    
    
end