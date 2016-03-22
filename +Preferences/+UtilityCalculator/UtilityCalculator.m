classdef UtilityCalculator < Learner.Learner
    
    properties (Access=protected)
        utilityFunction
    end
    
    methods
        function obj =  UtilityCalculator(dataManager,utilityFunction,varargin)
            obj = obj@Learner.Learner(varargin{:});
            
            obj.utilityFunction = utilityFunction;
        end
        
        function [] = updateModel(obj, data)
            obj.utilityFunction.updateModel(data);
            tags = data.getDataEntry([obj.utilityFunction.outputName,'Tag']);
            tags = zeros(size(tags));
            data.setDataEntry([obj.utilityFunction.outputName,'Tag'],tags);
        end
        
        function [] = initObject(obj)
            obj.utilityFunction.initObject();
        end
       
    end
    
end

