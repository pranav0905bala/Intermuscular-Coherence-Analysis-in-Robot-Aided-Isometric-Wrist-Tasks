clc
clear
close all

load('../results/P1_data.mat')

pair_labels = P1_C1.pair_labels;

Zavg.ext  = P1_C1.Z_ext_allpairs;
Zavg.flex = P1_C1.Z_flex_allpairs;

save('../results/analysis_results.mat','Zavg','pair_labels')

disp('Analysis complete')
