function [ reward, state, flag] = SLSendController(gains)

state = zeros(1, 7);
reward = zeros(1, 1);

flag = 0;




[state flag] = SLSendTrajectoryMex(2, 2, ...
    0.0, ...
    zeros(1,7),...
    gains,...
    20);

if (flag == 1)
    reward = state(1);
else
    reward = -inf;
end


end

