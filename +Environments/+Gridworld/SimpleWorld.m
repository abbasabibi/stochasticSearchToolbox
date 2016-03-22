classdef SimpleWorld < Environments.Gridworld.GenericGridWorld
    
    properties (Access=protected)       
        
    end
    
    methods
        function obj =  SimpleWorld(sampler)
            map = {'.', '.', '.', '.','.';
                   '.', '#', '.', '#','G'};
            initialState = [2,1];  
                   
            obj = obj@Environments.Gridworld.GenericGridWorld(sampler, map, initialState);           
            
            
        end
    end
    
end

