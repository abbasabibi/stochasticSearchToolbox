classdef LargeWorld < Environments.Gridworld.GenericGridWorld
    
    properties (Access=protected)       
        
    end
    
    methods
        function obj =  LargeWorld(sampler)
            map = {'#','#','.', '.', '.', '.', '.','#','#'; 
                   '#','.','.', '#', '#', '#', '.','.','#';
                   '#','#','.', '.', '#', '.', '.','#','#';
                   '#','.','.', '#', '#', '#', '.','.','#';
                   '#','#','.', '.', '#', '.', '.','#','#';
                   '#','.','.', '#', '#', '#', '.','G','#';
                   '#','#','.', '.', '.', '.', '.','#','#'};
            initialState = [2,2];  
                   
            obj = obj@Environments.Gridworld.GenericGridWorld(sampler, map, initialState);           
            
            
        end
    end
    
end

