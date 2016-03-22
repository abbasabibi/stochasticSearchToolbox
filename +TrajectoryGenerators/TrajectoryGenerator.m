classdef TrajectoryGenerator < Data.DataManipulator & Data.OptionalParameterInterface
    
    properties(AbortSet, SetObservable)
        
        numJoints = 0;
        
        numTimeSteps = 100;
        dt = 0.01;
        time;                
    end
    
    methods
        
        function obj = TrajectoryGenerator(dataManager, numJoints )
            obj = obj@Data.DataManipulator(dataManager);
            
            obj.numJoints = numJoints;

            obj.linkPropertyNoSuffix('dt');
            obj.linkPropertyNoSuffix('numTimeSteps');
            
            if (~dataManager.isDataAlias('parameters'))
                level = dataManager.getDataManagerDepth('steps') - 1;
                dataManager.addDataAliasForDepth(level, 'parameters', {});
            end
                                    
            obj.dataManager.addDataEntry(obj.getNameWithSuffix('steps.referencePos'), numJoints);
            obj.dataManager.addDataEntry(obj.getNameWithSuffix('steps.referenceVel'), numJoints);
            obj.dataManager.addDataEntry(obj.getNameWithSuffix('steps.referenceAcc'), numJoints);
            
           
            obj.computeTime();         
            obj.registerTrajectoryFunction();
        end
        
        function [additionalParameters] = getParameterNamesForTrajectoryGenerator(obj)
            additionalParameters = obj.additionalParameters;
        end
                        
        
        function [numTimeSteps] = getNumTimeSteps(obj)
            numTimeSteps = obj.numTimeSteps;
        end                        
        
        function computeTime(obj)
            obj.time = (1:obj.numTimeSteps) .* obj.dt;
        end
        
        function [] = registerTrajectoryFunction(obj)
            obj.addDataManipulationFunction('getReferenceTrajectory', obj.additionalParameters, obj.getNameWithSuffix({'referencePos', 'referenceVel', 'referenceAcc'}));
        end        
        
        function [duration] = getTrajectoryDuration(obj)
            duration = obj.numTimeSteps * obj.dt;
        end
       
    end
    
    methods (Abstract)
        [referencePos, referenceVel, referenceAcc] = getReferenceTrajectory(obj);
    end
         
end