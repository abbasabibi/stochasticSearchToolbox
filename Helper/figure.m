function [ output_args ] = figure( figure_no )
%CHANGE_CURRENT_FIGURE Change figure while avoiding foucs
% if figure exist, switch without drawing focus

%check whether we should be plotting at all
if(usejava('jvm') && usejava('desktop') )
    if(nargin>0 &&  ishghandle(figure_no) && nargout  ==0)
        % if figure exist already, switch to it without changing focus
        set(0,'CurrentFigure',figure_no);
    else
        % if figure doesn't exist, make it (will draw focus)
        if(nargin>0)
            tmp = builtin('figure',figure_no);
        else
            tmp = builtin('figure');
        end
        if(nargout >0)
            output_args = tmp;
        end
        pause(0.5)
        arrangeFigures();
    end
end


end


function arrangeFigures()
mp = get(0, 'MonitorPositions');
xStart  = mp(end,1) ;
xEnd    = mp(end,1) + mp(end,3);
offsetGUI = 150;

figHandles = get(0,'Children');
if(length(figHandles) > 1)
    
% tmp = figHandles;
% for i = 2 : length(figHandles)
%     figNumbers(i) = figHandles(i).Number;
% end
% [~, idx] = sort(figNumbers);
% figHandles = [figHandles(1);  tmp(idx)];


try
    currPos = figHandles(2).Position;
catch me
    currPos = get(figHandles(2), 'Position');
end

fig1Pos = get(figHandles(1), 'Position');
        
%     newPos  = currPos - [figHandles(1).Position(3) 0 0 0];
    newPos  = currPos - [fig1Pos(3) 0 0 0];
    if(newPos(1) < xStart)
        newPos(1) = xEnd - newPos(3);
        newPos(2) = newPos(2) - newPos(4) -offsetGUI;
        if(newPos(2) + offsetGUI < 0)
            newPos(2) = mp(end,4) - newPos(4);
        end
    end
    
    set(figHandles(1),'Position',newPos);
    pause(0.2);
end

end

