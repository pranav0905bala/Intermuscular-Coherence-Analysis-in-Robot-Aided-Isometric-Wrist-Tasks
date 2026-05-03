function plot_matrix(ext,flex,labels,title_str,clim,folder,name)

data = [ext,flex];

figure('Color','w')
imagesc(data,clim)
colormap(sky(256))
colorbar

xticks(1:2)
xticklabels({'Extension','Flexion'})

yticks(1:length(labels))
yticklabels(labels)

title(title_str)
xlabel('Torque')
ylabel('Muscle Pairs')

save_figure_all_formats(gcf,name,folder)
end
