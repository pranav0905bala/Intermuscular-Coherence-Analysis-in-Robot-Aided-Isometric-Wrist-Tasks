clc
clear
close all

addpath('../src/utils')

load('../results/analysis_results.mat')

figFolder = '../results/figures';
if ~exist(figFolder,'dir'); mkdir(figFolder); end

plot_matrix(Zavg.ext, Zavg.flex, pair_labels, ...
    'Z-Scores', [0 1], figFolder, 'Zscores');

disp('Figures generated')
