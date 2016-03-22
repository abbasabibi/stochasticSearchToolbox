function [ state, flag] = SLInitEpisode(initState, maxCommands)

    if (nargin == 1)
        maxCommands = 2;
    end

    [state flag] = SLSendTrajectoryMex(1, maxCommands, ...
                0.0, ...
                zeros(1,7),...
                initState,...
                20);


end

