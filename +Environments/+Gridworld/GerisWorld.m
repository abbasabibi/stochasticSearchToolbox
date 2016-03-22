classdef GerisWorld < Environments.Gridworld.GenericGridWorld
    
    properties (Access=protected)       
        
    end
    
    methods
        function obj =  GerisWorld(sampler)
            map = {'.', '.', '.', '.', 'G'; 
                   '.', '#', '#', '#', 'X';
                   '.', '#', '#', '#', 'X';
                   '.', '.', '.', '.', '.'};
            initialState = [4,5];  
            %map = {'.', '.', '.', '.', '.'; 
            %       '.', '#', '.', '#', 'G'};
            %initialState = [2,1]; 
                   
            obj = obj@Environments.Gridworld.GenericGridWorld(sampler, map, initialState);           
            
            
        end
    end
    
end

