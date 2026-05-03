clc
clear
close all

cd(fileparts(mfilename('fullpath')))

addpath('../src/preprocessing')
addpath('../src/coherence')
addpath('../src/utils')

resultsFolder = '../results';
if ~exist(resultsFolder,'dir'); mkdir(resultsFolder); end

%% GLOBAL SETTINGS
fs = 2148.1481;
fc = 250;
segment_length = 256;
window = hamming(segment_length);
noverlap = 128;
nfft = 512;
alpha = 0.05;
freq_band = [15 30];

muscle_names = {'FCR','ECU','FCU','ECRL','FDS','EDC','Triceps','Biceps'};

%% FILTER
[b,a] = butter(4, fc/(fs/2), 'high');

%% ====== FILE PATHS (EDIT THESE) ======
P1_C1_robot_files = {...};
P1_C1_emg_files   = {...};

%% PROCESS
P1_C1 = process_participant1_condition(...
    P1_C1_robot_files, P1_C1_emg_files, 3, 1, 2, ...
    fs, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);

%% SAVE
save(fullfile(resultsFolder,'P1_data.mat'),'P1_C1')

disp('Pipeline complete')
