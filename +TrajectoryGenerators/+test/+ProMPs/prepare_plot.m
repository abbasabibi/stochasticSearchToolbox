function prepare_plot(fName,savePlot)

title('')
set(gca, 'XTickLabel', num2cell(0:0.25:1))
set(gcf, 'Position', [580 549 643 329]);
xlabel('time(s)', 'FontSize', 20);
ylabel('q(rad)', 'FontSize', 20);
set(gca, 'FontSize', 20);
axis([0 200 -1.2 1.5])

if (savePlot)
%     Plotter.plot2svg([fName,'.svg'], gcf) %Save figure
%     set(gcf,'Renderer','painters')
%     set(gcf, 'PaperPosition', [0 0 8 5]); %Position plot at left hand corner with width 5 and height 5.
%     set(gcf, 'PaperSize', [8 5]); %Set the paper to have width 5 and height 5.
%     saveas(gcf, fName, 'pdf') %Save figure
    matlab2tikz('filename',[fName,'.tex'],'width','0.75\columnwidth',...
             'extraAxisOptions',[...
             'ylabel style = {yshift = -1.5em,font = \large},'...
             'xlabel style = {yshift =  0.3em,font = \large},'...
             'xticklabel style = { font = \large},'...
             'yticklabel style = { font = \large},'
             ])
end

end

