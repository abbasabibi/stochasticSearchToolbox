classdef PongPlotter < Evaluator.Evaluator
   
    properties
        pongEnv
    end
    
  
    methods
        function [obj] = PongPlotter (pongEnv)
            obj = obj@Evaluator.Evaluator('plot', {'endLoop'}, Experiments.StoringType.ACCUMULATE);    
            
            obj.pongEnv = pongEnv;
        end                        
        
        function [evaluation] = getEvaluation(obj, data, newData, trial)
            if(usejava('jvm') && usejava('desktop') )
                figure(19)
                clf
                numRollouts =  newData.dataStructure.numElements;
                numRows     = ceil(sqrt(numRollouts));
                numCols     = ceil(numRollouts / numRows);
                subplot(numRows,numCols,1)
                
                paddleYPos  = obj.pongEnv.field.walls(obj.pongEnv.field.paddleIdx,2);
                
                for i =1 :  newData.dataStructure.numElements
                    subplot(numRows,numCols,i);
                    hold on
                    tmp = newData.getDataEntry('states', i, :);
                    plot(tmp(:,1),tmp(:,2),'b.'); %traj
                    
                    contexts = newData.getDataEntry('contexts', i, :);
                    for k = 1 : size(contexts,1)
                        plot([contexts(k,6)-obj.pongEnv.opponentWidth/2; contexts(k,6)+obj.pongEnv.opponentWidth/2], ...
                            [obj.pongEnv.field.height/2; obj.pongEnv.field.height/2], 'g', 'LineWidth', 2);
                    end
                    
                    
                    a = newData.getDataEntry('parameters', i, :);
                    for k = 1 : size(a,1)
                        paddlePos(1,:) = [a(k,1)-obj.pongEnv.field.paddleWidth/2, paddleYPos - obj.pongEnv.field.paddleWidth/2 * sin(a(k,2))];
                        paddlePos(2,:) = [a(k,1)+obj.pongEnv.field.paddleWidth/2, paddleYPos + obj.pongEnv.field.paddleWidth/2 * sin(a(k,2))];
                        plot(paddlePos(:,1),paddlePos(:,2),'r', 'LineWidth',2);
                    end
                    r = newData.getDataEntry('returns', i);
                    title(['R=',num2str(mean(r)), ' NumActiveBricks = ',num2str(sum(sum(tmp(:,6:end))))]);
                    axis([-obj.pongEnv.field.width/2, obj.pongEnv.field.width/2, -obj.pongEnv.field.height/2, obj.pongEnv.field.height/2]); %[XMIN XMAX YMIN YMAX]
                end
                
               
   
                
                
                
                pause(0.7);
                
            end
            evaluation = 0;
        end
                
    end   
    
end