classdef ParallelNaoWalkBanditHeightChange < Environments.EpisodicContextualParameterLearningTask
    
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
        
        function fitness = matlabAgent(context, parameters,upperLim,lowerLim,numSamplesForAverage)
                
                t = getCurrentTask(); 
                
                MyWorkerID = t.ID;
            
                optPort= 6000+100*MyWorkerID+randperm(99,1);
                
               % optPort = optPortPool(1);
                
                serverPortAgent = 3000+100*MyWorkerID+randperm(99,1);
                serverPortMonitor = 9000+100*MyWorkerID+randperm(99,1);
                
                agentHost = 'localhost';
                serverHost = 'localhost';
                
                indiv = 1./(1+exp(-1*parameters));
                indiv = indiv.*(upperLim-lowerLim) + lowerLim;
                indiv=[indiv context];
                
                runServer = sprintf('tmux split-window -d "rcssserver3d --agent-port %i --server-port %i"',serverPortAgent,serverPortMonitor);
                while(system(runServer))
                end
                
                pause(1);
                    
                runAgent = sprintf('tmux split-window -d "sh fcpagentRun.sh %i %s %i"',serverPortAgent,serverHost,optPort);
                system(runAgent);
                
                
                pause(0.5);

                %fileID = fopen('parralel.txt','w');
                %fprintf(fileID,'%s %s %s %s',a,b,c,d);
                %fclose(fileID);
                
                conOpened = false;
                con = tcpip('127.0.0.1', optPort, 'InputBufferSize', 8000);
                set(con, 'OutputBufferSize', 8000);
                set(con, 'Timeout', 120);
                
                while ~conOpened
                try
                fopen(con); 
                conOpened = true;
                catch
                    conOpened = false;
                    pause(0.5);
                end
                end
            fitnessSum=0;
            
            while con.BytesAvailable ~= 0
                tmp = fscanf(con, '%s');
            end
            
            for i=1:numSamplesForAverage
                
                fprintf(con, '%f', indiv);                
                Return=fscanf(con, '%f');
                fitnessSum =Return +fitnessSum;
                
            end
            
            fitness=fitnessSum/numSamplesForAverage;

            
            %end
             while con.BytesAvailable ~= 0
                tmp = fscanf(con, '%s');
             end
            
            fprintf(con, '%s ', 'kill'); 
            fclose(con);
            delete(con);
            clear con
            
            killServer = sprintf('tmux split-window -d "sh killServer.sh %i"',serverPortMonitor);
            system(killServer);
            
            pause(0.5);
                        
            pause(0.5);
        end
        
    end
    
    
    methods
        
        function obj = ParallelNaoWalkBanditHeightChange(sampler)
            
            obj = obj@Environments.EpisodicContextualParameterLearningTask(sampler,1, 10);

            obj.linkProperty('numSamplesForAverage');
            
            obj.dataManager.setRange('parameters', -ones(1, obj.dimParameters) * 5, ones(1, obj.dimParameters) * 5);
            obj.dataManager.setRange('contexts', [0.1], [0.6]);
            %(period stepSize accelerationTime DSP  hight swingHight inclination kx ky amp )
            obj.upperLim=[1.8, 0.4, 0.2, 0.5, 0.22, 0.2, 5, 1, 1, 1];
            obj.lowerLim=[0.01,0.02,  0.000001 ,0.0, 0.16 ,0.02, 0,0,   0,0];%[period dx dsP legextendion swingheight]


            obj.setCallType('sampleReturn', Data.DataFunctionType.ALL_AT_ONCE);
        end
        
        function returns = sampleReturn(obj, context, parameters)
            
            
            returns= zeros(size(parameters,1),1);
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
            UppLim = obj.upperLim;
            lowLim = obj.lowerLim;
            numAverage = obj.numSamplesForAverage;
            
           
            p = gcp('nocreate'); % If no pool, do not create new one.
            if isempty(p)
                poolsize = 0;
            else
                poolsize = p.NumWorkers;
            end
            
            if(poolsize == 0)

                parpool(10);

            end
            
            %indiv=[indiv context];
            parfor i=1:size(parameters,1)
                
                returns(i,:) = Environments.NaoWalking.ParallelNaoWalkBanditHeightChange.matlabAgent(context(i,:), parameters(i,:),UppLim,lowLim,numAverage);
            
            end
            
        end
        
    end
    
   
    
    
end