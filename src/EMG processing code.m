clc
close all
clear

cd(fileparts(mfilename('fullpath')))
figFolder = fullfile('..','figures','thesis');


%% ===================== GLOBAL DISPLAY SETTINGS =====================
set(0,'DefaultAxesFontSize',16)
set(0,'DefaultTextFontSize',16)
set(0,'DefaultAxesTitleFontSizeMultiplier',1.3)
set(0,'DefaultAxesLabelFontSizeMultiplier',1.2)
set(0,'DefaultAxesFontWeight','bold')
set(0,'DefaultTextFontWeight','bold')
set(0,'DefaultLineLineWidth',1.5)

%% ===================== GLOBAL SETTINGS =====================
fs = 2148.1481;
fc = 250;
segment_length = 256;
window = hamming(segment_length);
noverlap = 128;
nfft = 512;
alpha = 0.05;
freq_band = [15 30];

muscle_names = {'FCR','ECU','FCU','ECRL','FDS','EDC','Triceps','Biceps'};
nMuscles = length(muscle_names);

flexors   = {'FCR','FCU','FDS','Biceps'};
extensors = {'ECRL','ECU','EDC','Triceps'};

% Participant 1: separate rep files
P1_extension_trials = 1;
P1_flexion_trials   = 2;
P1_NumReps = 3;

% Participant 2: one file contains all reps
P2_extension_trials = [1 3 5];
P2_flexion_trials   = [2 4 6];

coh_clim = [0 0.2];
z_clim = [0 1];        % for Z-score plots
delta_clim = [-1 1];   % for contrast plots  

cbMapDelta = [linspace(0,0.9000,128)'      linspace(0,0.9447,128)' linspace(0.5430,0.9741,128)';
              linspace(0.9000,0.5430,128)' linspace(0.9447,0,128)' linspace(0.9741,0,128)'];

%% ===================== FILTER =====================
[b,a] = butter(4, fc/(fs/2), 'high');

%% ===================== FILE PATHS =====================
% =====================================================================
% PARTICIPANT 1  (SEPARATE FILES FOR EACH REP)
% =====================================================================

% ---------- P1 C1 ----------
P1_C1_robot_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C1\Main_study_p1_C1_R1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C1\Main_study_p1_C1_R2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C1\Main_study_p1_C1_R3.csv" ...
    };

P1_C1_emg_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C1\p1_C1_EMG__1\p1_C1_EMG__1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\p1_C1\p1_C1_EMG__2\p1_C1_EMG__2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\p1_C1\p1_C1_EMG__3\p1_C1_EMG__3.csv" ...
    };

% ---------- P1 C2 Flexed ----------
P1_C2F_robot_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C2_F\Main_study_p1_C2_F_R1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C2_F\Main_study_p1_C2_F_R2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C2_F\Main_study_p1_C2_F_R3.csv" ...
    };

P1_C2F_emg_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C2_F\p1_C2_EMG__1\p1_C2_EMG__1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C2_F\p1_C2_EMG__2\p1_C2_EMG__2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C2_F\p1_C2_EMG__3\p1_C2_EMG__3.csv" ...
    };

% ---------- P1 C2 Extended ----------
P1_C2E_robot_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\P1_C2_E\Main_study_p1_C2_E_R1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\P1_C2_E\Main_study_p1_C2_E_R2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\P1_C2_E\Main_study_p1_C2_E_R3.csv" ...
    };

P1_C2E_emg_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C2_E\p1_C2_E_EMG__1\p1_C2_E_EMG_E_R1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C2_E\p1_C2_E_EMG__2\p1_C2_E_EMG_E_R2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C2_E\p1_C2_E_EMG__3\p1_C2_E_EMG_E_R3.csv" ...
    };

% ---------- P1 C3 ----------
P1_C3_robot_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C3\Main_study_p1_C3_R1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C3\Main_study_p1_C3_R2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\Robot data\p1_C3\Main_study_p1_C3_R3.csv" ...
    };

P1_C3_emg_files = { ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C3\p1_C3_EMG__1\p1_C3_EMG__1.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C3\p1_C3_EMG__2\p1_C3_EMG__2.csv", ...
    "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P1\EMG Data\P1_C3\p1_C3_EMG__3\p1_C3_EMG__3.csv" ...
    };

% =====================================================================
% PARTICIPANT 2  (ONE FILE CONTAINING ALL REPS)
% =====================================================================

% ---------- P2 C1 ----------
P2_C1_robot_file = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\P2_ROBOT\Main_study_p2_C1_R1.csv";
P2_C1_emg_file   = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\p2_EMG\2026-03-16\p2_C1_EMG_1\p2_C1_EMG_1.csv";

% ---------- P2 C2 Flexed ----------
P2_C2F_robot_file = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\P2_ROBOT\Main_study_p2_C2_F_R1.csv";
P2_C2F_emg_file   = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\p2_EMG\2026-03-16\p2_C2_F_EMG_1\p2_C2_F_EMG_1.csv";

% ---------- P2 C2 Extended ----------
P2_C2E_robot_file = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\P2_ROBOT\Main_study_p2_C2_E_R1.csv";
P2_C2E_emg_file   = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\p2_EMG\2026-03-16\p2_C2_E_EMG_1\p2_C2_E_EMG_1.csv";

% ---------- P2 C3 ----------
P2_C3_robot_file = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\P2_ROBOT\Main_study_p2_C3_R1.csv";
P2_C3_emg_file   = "C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\p2_EMG\2026-03-16\p2_C3_EMG_1\p2_C3_EMG_1.csv";

%% ===================== PROCESS PARTICIPANT 1 =====================
P1_C1  = process_participant1_condition(P1_C1_robot_files,  P1_C1_emg_files,  P1_NumReps, P1_extension_trials, P1_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);
P1_C2F = process_participant1_condition(P1_C2F_robot_files, P1_C2F_emg_files, P1_NumReps, P1_extension_trials, P1_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);
P1_C2E = process_participant1_condition(P1_C2E_robot_files, P1_C2E_emg_files, P1_NumReps, P1_extension_trials, P1_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);
P1_C3  = process_participant1_condition(P1_C3_robot_files,  P1_C3_emg_files,  P1_NumReps, P1_extension_trials, P1_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);

%% ===================== PROCESS PARTICIPANT 2 =====================
P2_C1  = process_participant2_condition(P2_C1_robot_file,  P2_C1_emg_file,  P2_extension_trials, P2_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);
P2_C2F = process_participant2_condition(P2_C2F_robot_file, P2_C2F_emg_file, P2_extension_trials, P2_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);
P2_C2E = process_participant2_condition(P2_C2E_robot_file, P2_C2E_emg_file, P2_extension_trials, P2_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);
P2_C3  = process_participant2_condition(P2_C3_robot_file,  P2_C3_emg_file,  P2_extension_trials, P2_flexion_trials, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names);

%% ===================== OUTPUT ALL EXISTING MATRICES =====================
% Participant 1
plot_existing_outputs(P1_C1,  muscle_names, flexors, extensors, coh_clim, 'P1 Condition 1', figFolder);
plot_existing_outputs(P1_C2F, muscle_names, flexors, extensors, coh_clim, 'P1 Condition 2 Flexion posture', figFolder);
plot_existing_outputs(P1_C2E, muscle_names, flexors, extensors, coh_clim, 'P1 Condition 2 Extention posture', figFolder);
plot_existing_outputs(P1_C3,  muscle_names, flexors, extensors, coh_clim, 'P1 Condition 3', figFolder);
% 
% % Participant 2
plot_existing_outputs(P2_C1,  muscle_names, flexors, extensors, coh_clim, 'P2 Condition 1', figFolder);
plot_existing_outputs(P2_C2F, muscle_names, flexors, extensors, coh_clim, 'P2 Condition 2 Flexion posture', figFolder);
plot_existing_outputs(P2_C2E, muscle_names, flexors, extensors, coh_clim, 'P2 Condition 2 Extension posture', figFolder);
plot_existing_outputs(P2_C3,  muscle_names, flexors, extensors, coh_clim, 'P2 Condition 3', figFolder);

%% ===================== AVERAGE Z-SCORES ACROSS PARTICIPANTS =====================
% pair_labels = P1_C1.pair_labels;
% 
% Zavg_C1_ext   = mean([P1_C1.Z_ext_allpairs,  P2_C1.Z_ext_allpairs],  2);
% Zavg_C1_flex  = mean([P1_C1.Z_flex_allpairs, P2_C1.Z_flex_allpairs], 2);
% 
% Zavg_C2F_ext  = mean([P1_C2F.Z_ext_allpairs,  P2_C2F.Z_ext_allpairs],  2);
% Zavg_C2F_flex = mean([P1_C2F.Z_flex_allpairs, P2_C2F.Z_flex_allpairs], 2);
% 
% Zavg_C2E_ext  = mean([P1_C2E.Z_ext_allpairs,  P2_C2E.Z_ext_allpairs],  2);
% Zavg_C2E_flex = mean([P1_C2E.Z_flex_allpairs, P2_C2E.Z_flex_allpairs], 2);
% 
% Zavg_C3_ext   = mean([P1_C3.Z_ext_allpairs,  P2_C3.Z_ext_allpairs],  2);
% Zavg_C3_flex  = mean([P1_C3.Z_flex_allpairs, P2_C3.Z_flex_allpairs], 2);


%% ===================== NEW CONTRAST MATRICES (DIFFERENCES) =====================
% Delta_C2_ext  = [Zavg_C2F_ext - Zavg_C1_ext,  Zavg_C2E_ext - Zavg_C1_ext];
% Delta_C2_flex = [Zavg_C2F_flex - Zavg_C1_flex, Zavg_C2E_flex - Zavg_C1_flex];
% 
% Delta_C3_ext  = Zavg_C3_ext  - Zavg_C1_ext;
% Delta_C3_flex = Zavg_C3_flex - Zavg_C1_flex;
% 
% plot_matrix_with_text(Delta_C2_ext, delta_clim, ...
%     {'Flexed posture - Neutral posture','Extended posture - Neutral posture'}, pair_labels, ...
%     'Contrast: C2 - C1 (Extension torque)', cbMapDelta, 'Effect Size',figFolder, 'Delta_C2_ext');
% 
% plot_matrix_with_text(Delta_C2_flex, delta_clim, ...
%     {'Flexed posture - Neutral posture','Extended posture - Neutral posture'}, pair_labels, ...
%     'Contrast: C2 - C1 (Flexion torque)', cbMapDelta,'Effect Size', figFolder, 'Delta_C2_flex');
% 
% plot_matrix_with_text(Delta_C3_ext, delta_clim, ...
%     {'C3 - C1'}, pair_labels, ...
%     'Contrast: C3 - C1 (Extension torque)', cbMapDelta,'Effect Size', figFolder, 'Delta_C3_ext');
% 
% plot_matrix_with_text(Delta_C3_flex, delta_clim, ...
%     {'C3 - C1'}, pair_labels, ...
%     'Contrast: C3 - C1 (Flexion torque)', cbMapDelta,'Effect Size', figFolder, 'Delta_C3_flex');

%% ===================== AVERAGE Z MATRICES =====================
% plot_matrix_with_text([Zavg_C1_ext, Zavg_C1_flex], z_clim, ...
%     {'Extension torque','Flexion torque'}, pair_labels, ...
%     'Average Z-Scores - Condition 1', sky(256),'Z-score', figFolder, 'Zavg_C1');
% 
% plot_matrix_with_text([Zavg_C2F_ext, Zavg_C2F_flex], z_clim, ...
%     {'Extension torque','Flexion torque'}, pair_labels, ...
%     'Average Z-Scores - Condition 2 Flexion Posture', sky(256),'Z-score', figFolder, 'Zavg_C2F');
% 
% plot_matrix_with_text([Zavg_C2E_ext, Zavg_C2E_flex], z_clim, ...
%     {'Extension torque','Flexion torque'}, pair_labels, ...
%     'Average Z-Scores - Condition 2 Extension Posture', sky(256),'Z-score', figFolder, 'Zavg_C2E');
% 
% plot_matrix_with_text([Zavg_C3_ext, Zavg_C3_flex], z_clim, ...
%     {'Extension torque','Flexion torque'}, pair_labels, ...
%     'Average Z-Scores - Condition 3', sky(256), 'Z-score',figFolder, 'Zavg_C3');

%% ===================== OPTIONAL: DISPLAY PAIR LABELS =====================
disp('Muscle pair order used for Z-score averaging and contrast matrices:')
disp(pair_labels(:))

%% ===================== LOCAL FUNCTIONS =====================
function OUT = process_participant1_condition(robot_files, emg_files, NumReps, extension_trial, flexion_trial, ...
    fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names)

    nMuscles = length(muscle_names);

    all_extension_trials = cell(NumReps, nMuscles);
    all_flexion_trials   = cell(NumReps, nMuscles);

    for r = 1:NumReps

        Robot_Data_al = readmatrix(robot_files{r});
        Robot_time_al = Robot_Data_al(2:end,7);
        Trial_End     = Robot_Data_al(2:end,6);

        EMG_al  = extractTrignoEMG(emg_files{r});
        EMG_raw = readmatrix(emg_files{r});
        time_EMG_al = EMG_raw(8:end,1);

        emg_signals = { ...
            EMG_al.FCR, EMG_al.ECU, EMG_al.FCU, EMG_al.ECRL, ...
            EMG_al.FDS, EMG_al.EDC, EMG_al.TRICEPS, EMG_al.BICEPS};

        Isometric_end_timestamp   = find(diff(Trial_End) == 1) + 1;
        Trial_end_timestamp       = Isometric_end_timestamp - 1000;
        Trial_start_timestamp     = Trial_end_timestamp - 3000;
        Start_Times               = Robot_time_al(Trial_start_timestamp);
        End_Times                 = Robot_time_al(Trial_end_timestamp);

        Trials = length(Start_Times);
        rectified_signals = cell(Trials, nMuscles);

        for t = 1:Trials
            trial_mask = time_EMG_al >= Start_Times(t) & time_EMG_al <= End_Times(t);

            for m = 1:nMuscles
                x = emg_signals{m}(trial_mask);
                x = x(isfinite(x));
                xf = filtfilt(b, a, x);

                rectified_signals{t,m} = abs(xf(:));
            end
        end

        for m = 1:nMuscles
            all_extension_trials{r,m} = rectified_signals{extension_trial, m}(:);
            all_flexion_trials{r,m}   = rectified_signals{flexion_trial, m}(:);
        end
    end

    concat_extension = cell(1,nMuscles);
    concat_flexion   = cell(1,nMuscles);

    for m = 1:nMuscles
        concat_extension{m} = [];
        concat_flexion{m}   = [];

        for r = 1:NumReps
            concat_extension{m} = [concat_extension{m}; all_extension_trials{r,m}];
            concat_flexion{m}   = [concat_flexion{m}; all_flexion_trials{r,m}];
        end
    end

    OUT = compute_pairwise_outputs(concat_extension, concat_flexion, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, muscle_names);
end

function OUT = process_participant2_condition(robot_file, emg_file, extension_trials, flexion_trials, ...
    fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, b, a, muscle_names)

    nMuscles = length(muscle_names);

    Robot_Data_al = readmatrix(robot_file);
    Robot_time_al = Robot_Data_al(2:end,7);
    Trial_End     = Robot_Data_al(2:end,6);

    EMG_al  = extractTrignoEMG(emg_file);
    EMG_raw = readmatrix(emg_file);
    time_EMG_al = EMG_raw(8:end,1);

    emg_signals = { ...
        EMG_al.FCR, EMG_al.ECU, EMG_al.FCU, EMG_al.ECRL, ...
        EMG_al.FDS, EMG_al.EDC, EMG_al.TRICEPS, EMG_al.BICEPS};

    Isometric_end_timestamp   = find(diff(Trial_End) == 1) + 1;
    Trial_end_timestamp       = Isometric_end_timestamp - 1000;
    Trial_start_timestamp     = Trial_end_timestamp - 3000;
    Start_Times               = Robot_time_al(Trial_start_timestamp);
    End_Times                 = Robot_time_al(Trial_end_timestamp);

    Trials = length(Start_Times);

    for t = 1:Trials
        trial_mask = time_EMG_al >= Start_Times(t) & time_EMG_al <= End_Times(t);

        for m = 1:nMuscles
            x = emg_signals{m}(trial_mask);
            x = x(isfinite(x));

            xf = filtfilt(b, a, x);
            rectified_signals1{t,m} = abs(xf);
        end
    end 

    concat_extension = cell(1,nMuscles);
    concat_flexion   = cell(1,nMuscles);

    for m = 1:nMuscles
        concat_extension{m} = [];
        concat_flexion{m}   = [];

        for idx = 1:length(extension_trials)
            t = extension_trials(idx);
            if t <= Trials
                concat_extension{m} = [concat_extension{m}; rectified_signals1{t,m}(:)];
            end
        end

        for idx = 1:length(flexion_trials)
            t = flexion_trials(idx);
            if t <= Trials
                concat_flexion{m} = [concat_flexion{m}; rectified_signals1{t,m}(:)];
            end
        end
    end

    OUT = compute_pairwise_outputs(concat_extension, concat_flexion, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, muscle_names);
end

function OUT = compute_pairwise_outputs(concat_extension, concat_flexion, fs, fc, window, noverlap, nfft, alpha, freq_band, segment_length, muscle_names)

    nMuscles = length(muscle_names);

    beta_mean_ext  = NaN(nMuscles,nMuscles);
    beta_mean_flex = NaN(nMuscles,nMuscles);
    conf_ext       = NaN(nMuscles,nMuscles);
    conf_flex      = NaN(nMuscles,nMuscles);
    msc_ext        = cell(nMuscles,nMuscles);
    msc_flex       = cell(nMuscles,nMuscles);
    z_ext          = cell(nMuscles,nMuscles);
    z_flex         = cell(nMuscles,nMuscles);
    freqs          = [];

    for m1 = 1:nMuscles
        for m2 = m1+1:nMuscles

            % -------- Extension --------
            x = concat_extension{m1};
            y = concat_extension{m2};

            min_len = min(length(x), length(y));
            x = x(1:min_len);
            y = y(1:min_len);

            [cxy,f] = mscohere(x, y, window, noverlap, nfft, fs);
            freqs = f;
            msc_ext{m1,m2} = cxy;

            L = floor((length(x) - noverlap) / (segment_length - noverlap));
            conf_ext(m1,m2) = 1 - alpha^(1/(L-1));

            beta_idx = (f >= freq_band(1) & f <= freq_band(2));
            beta_mean_ext(m1,m2) = mean(cxy(beta_idx), 'omitnan');
            
            cxy_masked = cxy;
            cxy_masked(cxy <= conf_ext(m1,m2)) = 0;

            Fz = atanh(sqrt(cxy_masked));
            z_val = Fz / sqrt(1/(2*L));
            bias_range = (f >= 100 & f <= 250);
            bias = mean(z_val(bias_range), 'omitnan');
            z_corr = z_val - bias;

            z_corr(z_corr < 0) = 0;

            z_ext{m1,m2} = z_corr;

            % -------- Flexion --------
            x = concat_flexion{m1};
            y = concat_flexion{m2};

            min_len = min(length(x), length(y));
            x = x(1:min_len);
            y = y(1:min_len);

            [cxy,f] = mscohere(x, y, window, noverlap, nfft, fs);
            freqs = f;
            msc_flex{m1,m2} = cxy;

            L = floor((length(x) - noverlap) / (segment_length - noverlap));
            conf_flex(m1,m2) = 1 - alpha^(1/(L-1));
            beta_idx = (f >= freq_band(1) & f <= freq_band(2));
            beta_mean_flex(m1,m2) = mean(cxy(beta_idx), 'omitnan');
            
            cxy_masked = cxy;
            cxy_masked(cxy <= conf_flex(m1,m2)) = 0;

            Fz = atanh(sqrt(cxy_masked));
            z_val = Fz / sqrt(1/(2*L));
            bias_range = (f >= 100 & f <= 250);
            bias = mean(z_val(bias_range), 'omitnan');
            z_corr = z_val - bias;
            
            z_corr(z_corr < 0) = 0;

            z_flex{m1,m2} = z_corr;
        end
    end

    num_pairs = nchoosek(nMuscles,2);
    Z_ext_allpairs  = NaN(num_pairs,1);
    Z_flex_allpairs = NaN(num_pairs,1);
    pair_labels     = cell(num_pairs,1);

    idx = 1;
    for m1 = 1:nMuscles
        for m2 = m1+1:nMuscles
            pair_labels{idx} = [muscle_names{m1} '-' muscle_names{m2}];
            beta_idx = (freqs >= freq_band(1) & freqs <= freq_band(2));
            Z_ext_allpairs(idx)  = mean(z_ext{m1,m2}(beta_idx), 'omitnan');
            Z_flex_allpairs(idx) = mean(z_flex{m1,m2}(beta_idx), 'omitnan');
            idx = idx + 1;
        end
    end

    OUT.beta_mean_ext   = beta_mean_ext;
    OUT.beta_mean_flex  = beta_mean_flex;
    OUT.conf_ext        = conf_ext;
    OUT.conf_flex       = conf_flex;
    OUT.msc_ext         = msc_ext;
    OUT.msc_flex        = msc_flex;
    OUT.z_ext           = z_ext;
    OUT.z_flex          = z_flex;
    OUT.Z_ext_allpairs  = Z_ext_allpairs;
    OUT.Z_flex_allpairs = Z_flex_allpairs;
    OUT.freqs           = freqs;
    OUT.pair_labels     = pair_labels;
end

%% ===================== PLOTTING FUNCTIONS =====================

function plot_existing_outputs(COND, muscle_names, flexors, extensors, coh_clim, prefix, figFolder)

    safePrefix = regexprep(prefix, '[^a-zA-Z0-9]', '_');

    plot_flattened_all_pairs(COND, muscle_names, flexors, extensors, coh_clim, ...
        [prefix ' - All Muscle Pairs'], figFolder, [safePrefix '_all_pairs']);

    % plot_flattened_significant_pairs(COND, muscle_names, flexors, extensors, coh_clim, ...
    %     [prefix ' - Significant Pairs'], figFolder, [safePrefix '_significant_pairs']);

    % plot_unflattened_matrix(COND.beta_mean_ext, muscle_names, coh_clim, ...
    %     [prefix ' - Extension torque'], figFolder, [safePrefix '_extension']);
    % 
    % plot_unflattened_matrix(COND.beta_mean_flex, muscle_names, coh_clim, ...
    %     [prefix ' - Flexion torque'], figFolder, [safePrefix '_flexion']);
end

%function plot_flattened_all_pairs(COND, muscle_names, flexors, extensors, clim_, fig_title_str)
function plot_flattened_all_pairs(COND, muscle_names, flexors, extensors, clim_, fig_title_str, figFolder, fileName)
    nMuscles = length(muscle_names);
    pair_vals = zeros(nchoosek(nMuscles,2), 2);
    pair_labels = cell(1,nchoosek(nMuscles,2));
    pair_group = cell(1,nchoosek(nMuscles,2));

    idx = 1;
    for m1 = 1:nMuscles
        for m2 = m1+1:nMuscles
            pair_vals(idx,1) = COND.beta_mean_ext(m1,m2);
            pair_vals(idx,2) = COND.beta_mean_flex(m1,m2);

            mA = muscle_names{m1};
            mB = muscle_names{m2};
            pair_labels{idx} = [mA '-' mB];

            if ismember(mA,flexors) && ismember(mB,flexors)
                pair_group{idx} = 'Flexor-Flexor';
            elseif ismember(mA,extensors) && ismember(mB,extensors)
                pair_group{idx} = 'Extensor-Extensor';
            elseif (ismember(mA,flexors) && ismember(mB,extensors)) || ...
                   (ismember(mA,extensors) && ismember(mB,flexors))
                pair_group{idx} = 'Flexor-Extensor';
            else
                pair_group{idx} = 'Other';
            end

            idx = idx + 1;
        end
    end

    group_order = {'Flexor-Flexor','Extensor-Extensor','Flexor-Extensor','Other'};
    group_idx = zeros(1,length(pair_group));
    for i = 1:length(pair_group)
        group_idx(i) = find(strcmp(pair_group{i}, group_order), 1);
    end

    [~, order] = sort(group_idx);
    pair_vals = pair_vals(order,:);
    pair_labels = pair_labels(order);

    figure('Name',fig_title_str,'Position',[100 100 800 1400],'Color','w');
    imagesc(pair_vals, clim_)

    colormap(sky(256))
    cb = colorbar;
    cb.Label.String = 'Coherence';
    cb.Label.FontSize = 14;
    cb.FontWeight = 'bold';
    cb.FontSize = 14;
    cb.Ticks = 0:0.04:0.2;
    caxis(clim_)

    axis tight
    box on
    set(gca,'FontSize',14,'FontWeight','bold','LineWidth',1.2)

    title(fig_title_str,'FontSize',18,'FontWeight','bold')
    xlabel('Torque','FontSize',16,'FontWeight','bold')
    ylabel('Muscle Pairs','FontSize',16,'FontWeight','bold')
    xticks(1:2)
    xticklabels({'Extension','Flexion'})
    yticks(1:size(pair_vals,1))
    yticklabels(pair_labels)

    hold on
    for i = 1:size(pair_vals,1)
        for j = 1:size(pair_vals,2)
            val = pair_vals(i,j);
            if val >= 0.2
                txtColor = 'w';
            else
                txtColor = 'k';
            end
            text(j,i,sprintf('%.2f',val), ...
                'HorizontalAlignment','center', ...
                'FontSize',18, ...
                'FontWeight','bold', ...
                'Color',txtColor);
        end
    end

    save_figure_all_formats(gcf, fileName, figFolder);
end

%function plot_flattened_significant_pairs(COND, muscle_names, flexors, extensors, clim_, fig_title_str)
% function plot_flattened_significant_pairs(COND, muscle_names, flexors, extensors, clim_, fig_title_str, figFolder, fileName)
%     nMuscles = length(muscle_names);
%     sig_ext  = COND.beta_mean_ext  > COND.conf_ext;
%     sig_flex = COND.beta_mean_flex > COND.conf_flex;
%     sig_any  = sig_ext | sig_flex;
% 
%     pair_vals = [];
%     pair_labels = {};
%     pair_group = {};
% 
%     for m1 = 1:nMuscles
%         for m2 = m1+1:nMuscles
%             if sig_any(m1,m2)
%                 pair_vals(end+1,1) = COND.beta_mean_ext(m1,m2); 
%                 pair_vals(end,2)   = COND.beta_mean_flex(m1,m2);
% 
%                 mA = muscle_names{m1};
%                 mB = muscle_names{m2};
%                 pair_labels{end+1} = [mA '-' mB]; 
% 
%                 if ismember(mA,flexors) && ismember(mB,flexors)
%                     pair_group{end+1} = 'Flexor-Flexor'; 
%                 elseif ismember(mA,extensors) && ismember(mB,extensors)
%                     pair_group{end+1} = 'Extensor-Extensor'; 
%                 elseif (ismember(mA,flexors) && ismember(mB,extensors)) || ...
%                        (ismember(mA,extensors) && ismember(mB,flexors))
%                     pair_group{end+1} = 'Flexor-Extensor'; 
%                 else
%                     pair_group{end+1} = 'Other'; 
%                 end
%             end
%         end
%     end
% 
%     group_order = {'Flexor-Flexor','Extensor-Extensor','Flexor-Extensor','Other'};
%     group_idx = zeros(1,length(pair_group));
%     for i = 1:length(pair_group)
%         group_idx(i) = find(strcmp(pair_group{i}, group_order), 1);
%     end
% 
%     [~, order] = sort(group_idx);
%     pair_vals = pair_vals(order,:);
%     pair_labels = pair_labels(order);
% 
%     figure('Name',fig_title_str,'Position',[100 100 800 1200],'Color','w');
%     imagesc(pair_vals, clim_)
% 
%     colormap(sky(256))
%     cb = colorbar;
%     cb.Label.String = 'Coherence';
%     cb.Label.FontSize = 14;
%     cb.FontWeight = 'bold';
%     cb.FontSize = 14;
%     cb.Ticks = 0:0.04:0.2;
%     caxis(clim_)
% 
%     axis tight
%     box on
%     set(gca,'FontSize',14,'FontWeight','bold','LineWidth',1.2)
% 
%     title(fig_title_str,'FontSize',18,'FontWeight','bold')
%     xlabel('Torque','FontSize',16,'FontWeight','bold')
%     ylabel('Muscle Pairs','FontSize',16,'FontWeight','bold')
%     xticks(1:2)
%     xticklabels({'Extension','Flexion'})
%     yticks(1:size(pair_vals,1))
%     yticklabels(pair_labels)
% 
%     hold on
%     for i = 1:size(pair_vals,1)
%         for j = 1:size(pair_vals,2)
%             val = pair_vals(i,j);
%             if val >= 0.15
%                 txtColor = 'w';
%             else
%                 txtColor = 'k';
%             end
%             text(j,i,sprintf('%.2f',val), ...
%                 'HorizontalAlignment','center', ...
%                 'FontSize',18, ...
%                 'FontWeight','bold', ...
%                 'Color',txtColor);
%         end
%     end
% 
%     save_figure_all_formats(gcf, fileName, figFolder);
% end

%function plot_unflattened_matrix(beta_mat, muscle_names, clim_, fig_title_str)
% function plot_unflattened_matrix(beta_mat, muscle_names, clim_, fig_title_str, figFolder, fileName)
%     nMuscles = length(muscle_names);
%     Cmat = NaN(nMuscles,nMuscles);
% 
%     for m1 = 1:nMuscles
%         for m2 = m1+1:nMuscles
%             Cmat(m2,m1) = beta_mat(m1,m2);
%         end
%     end
% 
%     Cmat(triu(true(size(Cmat)))) = NaN;
% 
%     figure('Name',fig_title_str,'Position',[100, 100, 800, 800],'Color','w');
%     h = imagesc(Cmat, clim_);
%     set(gca,'Color','w')
%     set(h,'AlphaData',~isnan(Cmat))
% 
%     colormap(sky(256))
%     cb = colorbar;
%     cb.Label.String = 'Coherence';
%     cb.Label.FontSize = 14;
%     cb.FontWeight = 'bold';
%     cb.FontSize = 14;
%     cb.Ticks = 0:0.04:0.2;
%     caxis(clim_)
% 
%     axis square
%     box on
%     set(gca,'FontSize',14,'FontWeight','bold','LineWidth',1.2)
% 
%     title(fig_title_str,'FontSize',18,'FontWeight','bold')
%     xticks(1:nMuscles)
%     yticks(1:nMuscles)
%     xticklabels(muscle_names)
%     yticklabels(muscle_names)
%     xtickangle(45)
% 
%     hold on
%     for i = 1:nMuscles
%         for j = 1:nMuscles
%             val = Cmat(i,j);
%             if ~isnan(val)
%                 if val >= 0.15
%                     txtColor = 'k';
%                 else
%                     txtColor = 'w';
%                 end
%                 text(j,i,sprintf('%.2f',val), ...
%                     'HorizontalAlignment','center', ...
%                     'FontSize',16, ...
%                     'FontWeight','bold', ...
%                     'Color','k');
%             end
%         end
%     end
% 
%     save_figure_all_formats(gcf, fileName, figFolder);
% end
% 
% %function plot_matrix_with_text(mat, clim_, xlabels_, ylabels_, fig_title_str, cmap_)
% function plot_matrix_with_text(mat, clim_, xlabels_, ylabels_, fig_title_str, cmap_, cbarLabel, figFolder, fileName)
%     figure('Name',fig_title_str,'Position',[100 100 800 1200],'Color','w');
%     imagesc(mat, clim_)
%     colormap(cmap_)
% 
%     cb = colorbar;
%     cb.FontSize = 14;
%     cb.FontWeight = 'bold';
%     cb.Label.String = cbarLabel;
%     cb.Label.FontSize = 14;
%     cb.Ticks = linspace(clim_(1), clim_(2), 5);
%     caxis(clim_)
%     axis tight
%     box on
%     set(gca,'FontSize',14,'FontWeight','bold','LineWidth',1.2)
% 
%     title(fig_title_str,'FontSize',18,'FontWeight','bold')
%     xlabel('Comparison','FontSize',16,'FontWeight','bold')
%     ylabel('Muscle Pairs','FontSize',16,'FontWeight','bold')
%     xticks(1:size(mat,2))
%     xticklabels(xlabels_)
%     yticks(1:size(mat,1))
%     yticklabels(ylabels_)
% 
%     hold on
% 
%     for i = 1:size(mat,1)
%     for j = 1:size(mat,2)
%         val = mat(i,j);
%         text(j,i,sprintf('%.2f',val), ...
%             'HorizontalAlignment','center', ...
%             'FontSize',18, ...
%             'FontWeight','bold', ...
%             'Color','w');
%     end
% end
% 
%     save_figure_all_formats(gcf, fileName, figFolder);
% end


% %% ===================== INDIVIDUAL PARTICIPANT Z-SCORES =====================
% 
% % % ---------- PARTICIPANT 1 ----------
% 
% plot_matrix_with_text([P1_C1.Z_ext_allpairs, P1_C1.Z_flex_allpairs], z_clim, ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P1 - C1 Z-Scores', cbMapDelta, figFolder, 'P1_C1_Zscores');
% 
% plot_matrix_with_text([P1_C2F.Z_ext_allpairs, P1_C2F.Z_flex_allpairs], z_clim, ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P1 - C2 Flexion Posture Z-Scores', cbMapDelta, figFolder, 'P1_C2F_Zscores');
% 
% plot_matrix_with_text([P1_C2E.Z_ext_allpairs, P1_C2E.Z_flex_allpairs], z_clim, ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P1 - C2 Extension Posture Z-Scores', cbMapDelta, figFolder, 'P1_C2E_Zscores');
% 
% plot_matrix_with_text([P1_C3.Z_ext_allpairs, P1_C3.Z_flex_allpairs], z_clim, ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P1 - C3 Z-Scores', cbMapDelta, figFolder, 'P1_C3_Zscores');
% 
% % P2
% plot_matrix_with_text([P2_C1.Z_ext_allpairs, P2_C1.Z_flex_allpairs], z_clim, ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P2 - C1 Z-Scores', cbMapDelta, figFolder, 'P2_C1_Zscores');
% 
% plot_matrix_with_text([P2_C2F.Z_ext_allpairs, P2_C2F.Z_flex_allpairs], z_clim, ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P2 - C2 Flexion Posture Z-Scores', cbMapDelta, figFolder, 'P2_C2F_Zscores');
% 
% plot_matrix_with_text([P2_C2E.Z_ext_allpairs, P2_C2E.Z_flex_allpairs], z_clim, ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P2 - C2 Extension Posture Z-Scores', cbMapDelta, figFolder, 'P2_C2E_Zscores');
% 
% plot_matrix_with_text([P2_C3.Z_ext_allpairs, P2_C3.Z_flex_allpairs], z_clim  , ...
%     {'Extension','Flexion'}, pair_labels, ...
%     'P2 - C3 Z-Scores', cbMapDelta, figFolder, 'P2_C3_Zscores');
