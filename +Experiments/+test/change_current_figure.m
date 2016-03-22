function [ output_args ] = change_current_figure( figure_no )
%CHANGE_CURRENT_FIGURE Summary of this function goes here
%   Detailed explanation goes here
    if(usejava('jvm') && usejava('desktop') )
        if(ishghandle(figure_no))
            set(0,'CurrentFigure',figure_no)
        else
            figure(figure_no)
        end
    end

end

