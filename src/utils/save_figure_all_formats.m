function save_figure_all_formats(fig,name,folder)

if ~exist(folder,'dir'); mkdir(folder); end

saveas(fig,fullfile(folder,[name '.png']))
saveas(fig,fullfile(folder,[name '.fig']))
end
