
ball = Environments.Pong.Ball();
ball.setVel(rand(2,1))
% ball.setVel([2; 1])
ball.setVel( ball.vel / norm(ball.vel) * 1)

figure(1);
clf
hold on
width   = 20;
height  = 20;
field   = Environments.Pong.Walls(width, height);
field.paddleWidth = 10;
field.createPlayingField();
field.plotField();
field.enablePlotting = true;
field.setPaddlePosRot(0, pi/2 + (rand-0.5) * pi/2);



axis([-width/2, width/2, -height/2, height/2])
for i = 1 : 1e3
    
    ball.plot(false, field);

    
    field.checkCollisions(ball);
%     if(field.hasCollision)
%         field.setPaddlePosRot(0, pi/2 + (rand-0.5) * pi/2);
%     end
%     field.setPaddlePosRot(ball.pos(1), field.walls(field.paddleIdx,5) );
    
    ball.updatePos();
        
end

