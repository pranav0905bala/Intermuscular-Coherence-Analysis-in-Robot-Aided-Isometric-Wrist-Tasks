 clc
close all
clear

cd(fileparts(mfilename('fullpath')))
figFolder = fullfile('..','figures','thesis');

%%% can be used for a single rep for any condition

%% extracting Robot data
Robot_Data_al = readmatrix("C:\Users\prana\OneDrive - University of Cincinnati\Erwin, Andrew (erwinae)'s files - Coherence Isometric Wrist Tasks\Data\Trimmed\P2\P2_ROBOT\Main_study_p2_C4_R1_i.csv");
Robot_Torque1_ = Robot_Data_al(2:end,2); % FE torque column
Robot_Torque2_ = Robot_Data_al(2:end,3); % RU torque column
Robot_time_al  = Robot_Data_al(2:end,7); % time column

%% Extract EMG Data
EMG_al = extractTrignoEMG("E:\thesis\p2_c4.csv");
EMG = readmatrix("E:\thesis\p2_c4.csv");
time_EMG_al = EMG(8:end,1);

EMG_data_FDS     = EMG_al.FDS;
EMG_data_Biceps  = EMG_al.BICEPS;
EMG_data_ECRL    = EMG_al.ECRL;
EMG_data_ECU     = EMG_al.ECU;
EMG_data_EDC     = EMG_al.EDC;
EMG_data_FCU     = EMG_al.FCU;
EMG_data_FCR     = EMG_al.FCR;
EMG_data_Triceps = EMG_al.TRICEPS;

% Storing in cell array
emg_signals = {EMG_data_FCR, EMG_data_ECU, EMG_data_FCU, EMG_data_ECRL, ...
               EMG_data_FDS, EMG_data_EDC, EMG_data_Triceps, EMG_data_Biceps};

nMuscles= length(emg_signals);
%% Identifying Force periods
Trial_End = Robot_Data_al(2:end,6);

Isometric_end_timestamp = [5516 49283 90160 130149 172782 213367 255550 294873 333946 373952 414600 454776] ; %find(diff(Trial_End)==1) + 1 p2 [5516 49283 90160 130149 172782 213367 255550 294873 333946 373952 414600 454776]
Trial_end_timestamp = Isometric_end_timestamp - 1000;
Trial_start_timestamp = Trial_end_timestamp - 3000;
Isometric_start_timestamp = Isometric_end_timestamp - 5000;

% time stamps
Isometric_Start_Times = Robot_time_al(Isometric_start_timestamp);
Isometric_End_Times   = Robot_time_al(Isometric_end_timestamp);
Start_Times           = Robot_time_al(Trial_start_timestamp);
End_Times             = Robot_time_al(Trial_end_timestamp);

%% Binning EMG data into trials
Trials = length(End_Times);
binned_EMG = cell(Trials, length(emg_signals));
trial_times = cell(Trials,1);

for i = 1:Trials
    trial_time = time_EMG_al >= Start_Times(i) & time_EMG_al <= End_Times(i);
    trial_times{i} = time_EMG_al(trial_time);

    for m = 1:length(emg_signals)
        binned_EMG{i,m} = emg_signals{m}(trial_time);
    end
end

%% EMG processing
filtered_signals   = cell(Trials, length(emg_signals));
rectified_signals  = cell(Trials, length(emg_signals));
normalized_signals = cell(Trials, length(emg_signals));

% high pass butterworth filter design
fc = 250;
fs = 2148.1481;
[b,a] = butter(4, fc/(fs/2), 'high');

for i = 1:Trials
    for m = 1:length(emg_signals)

        x = binned_EMG{i,m};
        x = x(isfinite(x));

        % ---------------- ADDED: de-mean ----------------
        %x = x - mean(x);

        % High pass filtering
        filtered_signals{i,m} = filtfilt(b, a, x);

        % rectification
        rectified_signals{i,m} = abs(filtered_signals{i,m});

        % normalization
        %normalized_signals{i,m} = (rectified_signals{i,m} - mean(rectified_signals{i,m})) ./ std(rectified_signals{i,m});
    end
end

%% Full-length processed signals for plotting
filtered_signals_   = cell(1,length(emg_signals));
rectified_signals_  = cell(1,length(emg_signals));
normalized_signals_ = cell(1,length(emg_signals));
smoothed_signals_   = cell(1,length(emg_signals));

for m = 1:length(emg_signals)

    x = emg_signals{m};
    % x = x(isfinite(x));
    % 
    % % ---------------- ADDED: de-mean ----------------
    % x = x - mean(x);

    % High pass filtering
    filtered_signals_{m} = filtfilt(b, a, x);

    % rectification
    rectified_signals_{m} = abs(filtered_signals_{m});

    % smoothing
    smoothed_signals_{m} = sqrt(movmean(emg_signals{m}.^2, 500));

    % normalization
    
    normalized_signals_{m} = (smoothed_signals_{m} - mean(smoothed_signals_{m})) ./ std(smoothed_signals_{m});
end

%% Coherence Analysis
muscles = length(emg_signals);
msc = cell(Trials,1);
Fz = cell(Trials,1);
Z_scores = cell(Trials,1);
Standard_z_scores = cell(Trials,1);
Ccrit_vals = cell(Trials,1);   % ---------------- ADDED ----------------
freqs = [];

segment_length = 256;
window = hamming(segment_length);
noverlap = 128;
nfft = 512;
alpha = 0.05;
freq_band = [15 30];

for t = 1:Trials
    for m1 = 1:muscles
        for m2 = m1+1:muscles

            x = rectified_signals{t,m1};
            y = rectified_signals{t,m2};

            min_len = min(length(x), length(y));
            x = x(1:min_len);
            y = y(1:min_len);

            % magnitude squared coherence (raw coherence)
            [cxy,f] = mscohere(x, y, window, noverlap, nfft, fs);
            msc{t}{m1,m2} = cxy;

            % ---------------- number of segments ----------------
            N = length(x);
            M = segment_length;
            O = noverlap;
            L = floor((N - O) / (M - O));

            % ---------------- coherence confidence threshold ----------------
            Ccrit = 1 - alpha^(1/(L-1));
            Ccrit_vals{t}{m1,m2} = Ccrit;

            % ---------------- coherence thresholding ----------------
            cxy_masked = cxy;
            cxy_masked(cxy <= Ccrit) = 0;

            % Fisher z transform
            Fz_val = atanh(sqrt(cxy_masked));
            Fz{t}{m1,m2} = Fz_val;

            % ---------------- Z scores ----------------
            Z_val = Fz_val / sqrt(1/(2*L));
            Z_scores{t}{m1,m2} = Z_val;

            % ---------------- bias removal ----------------
            bias_range = (f >= 100 & f <= 250);
            bias_val = mean(Z_val(bias_range), 'omitnan');
            z_corr = Z_val - bias_val;
            z_corr(z_corr < 0) = 0;

            Standard_z_scores{t}{m1,m2} = z_corr;
        end
    end
end

freqs = f;

%% plotting signals
f0 = figure('Name','robot data','Color','w','Position',[100 100 1800 800]);

subplot(2,1,1)
plot(Robot_time_al, Robot_Torque1_, 'LineWidth', 0.9)
hold on

yl = ylim;
text(Start_Times(1)+2, yl(2)*0.85, 'IMC Data', ...
    'FontSize',10, ...
    'FontWeight','normal', ...
    'Color',[0.2 0.2 0.2], ...
    'HorizontalAlignment','left', ...
    'VerticalAlignment','middle')

for t = 1:Trials
    xregion(Start_Times(t), End_Times(t), ...
        'FaceColor',[0.75 1 0.75], 'FaceAlpha',1);

    if t == 1
        xline(Isometric_Start_Times(t), '--k', 'Trial Start', ...
            'LabelOrientation','horizontal', ...
            'LabelHorizontalAlignment','left', ...
            'FontSize',9, ...
            'FontWeight','normal', ...
            'LineWidth',0.8);

        xline(Isometric_End_Times(t), '--r', 'Trial End', ...
            'LabelOrientation','horizontal', ...
            'LabelHorizontalAlignment','right', ...
            'FontSize',9, ...
            'FontWeight','normal', ...
            'LineWidth',0.8);
    else
        xline(Isometric_Start_Times(t), '--k', 'LineWidth',0.8);
        xline(Isometric_End_Times(t), '--r', 'LineWidth',0.8);
    end
end

title('Robot Torque FE', 'FontSize',12, 'FontWeight','normal')
xlabel('Time (s)', 'FontSize',10, 'FontWeight','normal')
ylabel('Amplitude', 'FontSize',10, 'FontWeight','normal')
set(gca, 'FontSize',10, 'FontWeight','normal', 'LineWidth',0.8, 'Box','off')

subplot(2,1,2)
plot(Robot_time_al, Robot_Torque2_, 'LineWidth', 0.9)
hold on

for t = 1:Trials
    xregion(Start_Times(t), End_Times(t), ...
        'FaceColor',[0.7 1 0.7], 'FaceAlpha',0.08);

    xline(Isometric_Start_Times(t), '--k', 'LineWidth',0.8);
    xline(Isometric_End_Times(t), '--r', 'LineWidth',0.8);
end

title('Robot Torque RU', 'FontSize',12, 'FontWeight','normal')
xlabel('Time (s)', 'FontSize',10, 'FontWeight','normal')
ylabel('Amplitude', 'FontSize',10, 'FontWeight','normal')
set(gca, 'FontSize',10, 'FontWeight','normal', 'LineWidth',0.8, 'Box','off')

muscle_names = {'FCR','ECU','FCU','ECRL','FDS','EDC','Biceps','Triceps'};

save_figure_all_formats(gcf, 'robot_data', figFolder);

%% filtered emgs
f4 = figure('Name','filtered','Color','w','Position',[100 100 1800 800]);
for m = 1:length(emg_signals)
    subplot(length(emg_signals),1,m)
    plot(time_EMG_al, filtered_signals_{m}, 'LineWidth', 0.8, 'Color',[0 0.45 0.74])
    hold on

    for t = 1:Trials
        xregion(Start_Times(t), End_Times(t), ...
            'FaceColor',[0.7 1 0.7], 'FaceAlpha',1);

        if m == 1 %&& t == 1
            h1 = xline(Isometric_Start_Times(t), '--k', 'Start', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','left', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.8);

            h1.LabelVerticalAlignment = 'bottom';   %  control vertical position


            h2 = xline(Isometric_End_Times(t), '--r', 'End', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','right', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.9);

            h2.LabelVerticalAlignment = 'bottom';  %  control vertical position
        else
            xline(Isometric_Start_Times(t), '--k', 'LineWidth',0.8);
            xline(Isometric_End_Times(t), '--r', 'LineWidth',0.8);
        end
    end


    if m == 1
        yl = ylim;
        text(Start_Times(1)+2, yl(2)*0.95, 'IMC Data', ...
            'FontSize',10, ...
            'FontWeight','normal', ...
            'Color',[0.2 0.2 0.2], ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle');
    end

    title(muscle_names{m}, 'FontSize',12, 'FontWeight','normal')
    ylabel('Amplitude', 'FontSize',10, 'FontWeight','normal')
    set(gca, 'FontSize',10, 'FontWeight','normal', 'LineWidth',0.8, 'Box','off')

    if m == length(emg_signals)
        xlabel('Time (s)', 'FontSize',10, 'FontWeight','normal')
    else
        set(gca, 'XTickLabel', [])
    end
end
save_figure_all_formats(gcf, 'filtered_emgs', figFolder);


%% rectified emgs
f4 = figure('Name','rectified emgs','Color','w','Position',[100 100 1800 800]);
for m = 1:length(emg_signals)
    subplot(length(emg_signals),1,m)
    plot(time_EMG_al, rectified_signals_{m}, 'LineWidth', 0.8, 'Color',[0 0.45 0.74])
    hold on

    for t = 1:Trials
        xregion(Start_Times(t), End_Times(t), ...
            'FaceColor',[0.7 1 0.7], 'FaceAlpha',1);

        if m == 1 %&& t == 1
            h1 = xline(Isometric_Start_Times(t), '--k', 'Start', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','left', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.8);

            h1.LabelVerticalAlignment = 'bottom';   %  control vertical position


            h2 = xline(Isometric_End_Times(t), '--r', 'End', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','right', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.9);

            h2.LabelVerticalAlignment = 'bottom';  %  control vertical position
        else
            xline(Isometric_Start_Times(t), '--k', 'LineWidth',0.8);
            xline(Isometric_End_Times(t), '--r', 'LineWidth',0.8);
        end
    end


     if m == 1
        yl = ylim;
        text(Start_Times(1)+2, yl(2)*0.95, 'IMC Data', ...
            'FontSize',10, ...
            'FontWeight','normal', ...
            'Color',[0.2 0.2 0.2], ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle');
    end

    title(muscle_names{m}, 'FontSize',12, 'FontWeight','normal')
    ylabel('Amplitude', 'FontSize',10, 'FontWeight','normal')
    set(gca, 'FontSize',10, 'FontWeight','normal', 'LineWidth',0.8, 'Box','off')

    if m == length(emg_signals)
        xlabel('Time (s)', 'FontSize',10, 'FontWeight','normal')
    else
        set(gca, 'XTickLabel', [])
    end
end

save_figure_all_formats(gcf, 'rectified_emgs', figFolder);

%% normalized emgs
f4 = figure('Name','normalized','Color','w','Position',[100 100 1800 800]);
for m = 1:length(emg_signals)
    subplot(length(emg_signals),1,m)
    plot(time_EMG_al, normalized_signals_{m}, 'LineWidth', 0.8, 'Color',[0 0.45 0.74])
    hold on

    for t = 1:Trials
        xregion(Start_Times(t), End_Times(t), ...
            'FaceColor',[0.7 1 0.7], 'FaceAlpha',1);

        if m == 1 %&& t == 1
            h1 = xline(Isometric_Start_Times(t), '--k', 'Start', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','left', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.8);

            h1.LabelVerticalAlignment = 'bottom';   %  control vertical position


            h2 = xline(Isometric_End_Times(t), '--r', 'End', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','right', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.9);

            h2.LabelVerticalAlignment = 'bottom';  %  control vertical position
        else
            xline(Isometric_Start_Times(t), '--k', 'LineWidth',0.8);
            xline(Isometric_End_Times(t), '--r', 'LineWidth',0.8);
        end
    end


     if m == 1
        yl = ylim;
        text(Start_Times(1)+2, yl(2)*0.95, 'IMC Data', ...
            'FontSize',10, ...
            'FontWeight','normal', ...
            'Color',[0.2 0.2 0.2], ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle');
    end

    title(muscle_names{m}, 'FontSize',12, 'FontWeight','normal')
    ylabel('Amplitude', 'FontSize',10, 'FontWeight','normal')
    set(gca, 'FontSize',10, 'FontWeight','normal', 'LineWidth',0.8, 'Box','off')

    if m == length(emg_signals)
        xlabel('Time (s)', 'FontSize',10, 'FontWeight','normal')
    else
        set(gca, 'XTickLabel', [])
    end
end
save_figure_all_formats(gcf, 'normalized_emgs', figFolder);

%% raw emg's
f5 = figure('Name','emgs with trials','Color','w','Position',[100 100 1800 800]);
for m = 1:length(emg_signals)
    subplot(length(emg_signals),1,m)
    plot(time_EMG_al, emg_signals{m}, 'LineWidth', 0.8, 'Color',[0 0.45 0.74])
    hold on

    for t = 1:Trials
        xregion(Start_Times(t), End_Times(t), ...
            'FaceColor',[0.7 1 0.7], 'FaceAlpha',1);

        if m == 1 %&& t == 1
            h1 = xline(Isometric_Start_Times(t), '--k', 'Start', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','left', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.8);

            h1.LabelVerticalAlignment = 'bottom';   %  control vertical position


            h2 = xline(Isometric_End_Times(t), '--r', 'End', ...
                'LabelOrientation','horizontal', ...
                'LabelHorizontalAlignment','right', ...
                'FontSize',12, ...
                'FontWeight','bold', ...
                'LineWidth',0.9);

            h2.LabelVerticalAlignment = 'bottom';  %  control vertical position
        else
            xline(Isometric_Start_Times(t), '--k', 'LineWidth',0.8);
            xline(Isometric_End_Times(t), '--r', 'LineWidth',0.8);
        end
    end

     if m == 1
        yl = ylim;
        text(Start_Times(1)+2, yl(2)*0.95, 'IMC Data', ...
            'FontSize',10, ...
            'FontWeight','normal', ...
            'Color',[0.2 0.2 0.2], ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle');
    end

    title(muscle_names{m}, 'FontSize',12, 'FontWeight','normal')
    ylabel('Amplitude', 'FontSize',10, 'FontWeight','normal')
    set(gca, 'FontSize',10, 'FontWeight','normal', 'LineWidth',0.8, 'Box','off')

    if m == length(emg_signals)
        xlabel('Time (s)', 'FontSize',10, 'FontWeight','normal')
    else
        set(gca, 'XTickLabel', [])
    end
end
save_figure_all_formats(gcf, 'raw_emgs_with_trials', figFolder);

% %% ===================== CONSOLIDATED FLATTENED MATRICES =====================
% 
% % Use the same physical-function grouping everywhere
% flexors   = {'FCR','FCU','FDS','Biceps'};
% extensors = {'ECRL','ECU','EDC','Triceps'};
% 
% % Make sure muscle_names matches emg_signals order
% muscle_names = {'FCR','ECU','FCU','ECRL','FDS','EDC','Triceps','Biceps'};
% 
% num_pairs = nchoosek(nMuscles,2);
% 
% % Storage
% pair_labels = cell(1,num_pairs);
% pair_group  = cell(1,num_pairs);
% 
% coherence_matrix = NaN(Trials, num_pairs);   % thresholded beta-band coherence
% zscore_matrix    = NaN(Trials, num_pairs);   % bias-corrected beta-band Z
% 
% % Build flattened matrices
% for t = 1:Trials
%     pair_idx = 1;
% 
%     for m1 = 1:nMuscles
%         for m2 = m1+1:nMuscles
% 
%             % Pair label
%             mA = muscle_names{m1};
%             mB = muscle_names{m2};
%             pair_labels{pair_idx} = [mA '-' mB];
% 
%             % Pair functional group
%             if ismember(mA,flexors) && ismember(mB,flexors)
%                 pair_group{pair_idx} = 'Flexor-Flexor';
%             elseif ismember(mA,extensors) && ismember(mB,extensors)
%                 pair_group{pair_idx} = 'Extensor-Extensor';
%             else
%                 pair_group{pair_idx} = 'Flexor-Extensor';
%             end
% 
%             % ----- Thresholded coherence matrix -----
%             cxy = msc{t}{m1,m2};
%             if ~isempty(cxy)
%                 Ccrit = Ccrit_vals{t}{m1,m2};
%                 cxy_masked = cxy;
%                 cxy_masked(cxy <= Ccrit) = 0;
% 
%                 band_idx = freqs >= freq_band(1) & freqs <= freq_band(2);
%                 coherence_matrix(t,pair_idx) = mean(cxy_masked(band_idx), 'omitnan');
%             end
% 
%             % ----- Z-score matrix -----
%             zxy = Standard_z_scores{t}{m1,m2};
%             if ~isempty(zxy)
%                 band_idx = freqs >= freq_band(1) & freqs <= freq_band(2);
%                 zscore_matrix(t,pair_idx) = mean(zxy(band_idx), 'omitnan');
%             end
% 
%             pair_idx = pair_idx + 1;
%         end
%     end
% end
% 
% % Sort muscle pairs by physical function
% group_order = {'Flexor-Flexor','Extensor-Extensor','Flexor-Extensor'};
% group_idx = zeros(1,num_pairs);
% 
% for i = 1:num_pairs
%     group_idx(i) = find(strcmp(pair_group{i}, group_order), 1);
% end
% 
% [~, order] = sort(group_idx);
% 
% coherence_matrix = coherence_matrix(:,order);
% zscore_matrix    = zscore_matrix(:,order);
% pair_labels      = pair_labels(order);
% pair_group       = pair_group(order);
% group_idx        = group_idx(order);
% 
% % Separator locations between functional groups
% %sep_idx = find(diff(group_idx) ~= 0) + 0.5;
% 
% %% ===================== THRESHOLDED COHERENCE MATRIX =====================
% figure('Name','Coherence matrix','Color','w', ...
%        'Position',[100 100 1500 700])
% 
% imagesc(coherence_matrix, [0 0.25])
% colormap(sky(256))
% 
% cb = colorbar;
% cb.FontSize = 16;
% cb.FontWeight = 'normal';
% 
% hold on
% 
% % Group separators
% % for s = 1:length(sep_idx)
% %     xline(sep_idx(s), 'k-', 'LineWidth', 1.2);
% % end
% 
% xticks(1:num_pairs)
% xticklabels(pair_labels)
% xtickangle(90)
% 
% yticks(1:Trials)
% yticklabels(1:Trials)
% 
% xlabel('Muscle Pairs', 'FontSize',12, 'FontWeight','normal')
% ylabel('Trial', 'FontSize',12, 'FontWeight','normal')
% title(['Raw Coherence: participant condition 4 '], ...
%     'FontSize',14, 'FontWeight','normal')
% 
% set(gca, 'FontSize',10, 'FontWeight','normal', ...
%     'LineWidth',0.8, 'Box','off')
% 
% axis tight
% 
% % Display values
% for i = 1:Trials
%     for j = 1:num_pairs
%         val = coherence_matrix(i,j);
% 
%         if ~isnan(val)
%             if val > 0.35
%                 txtColor = 'w';
%             else
%                 txtColor = 'k';
%             end
% 
%             text(j, i, sprintf('%.2f', val), ...
%                 'HorizontalAlignment','center', ...
%                 'VerticalAlignment','middle', ...
%                 'FontSize',12, ...
%                 'FontWeight','bold', ...
%                 'Color', txtColor);
%         end
%     end
% end
% 
% save_figure_all_formats(gcf, 'coherence_matrix_P2_Condition4', figFolder);

% %% ===================== Z-SCORE MATRIX =====================
% figure('Name','Z-score Matrix - All Trials','Color','w', ...
%        'Position',[100 100 1500 700])
% 
% imagesc(zscore_matrix, [0 3])   % adjust upper limit if needed
% colormap(sky(256))
% cb = colorbar;
% cb.FontSize = 12;
% cb.FontWeight = 'normal';
% 
% hold on
% 
% % Group separators
% % for s = 1:length(sep_idx)
% %     xline(sep_idx(s), 'k-', 'LineWidth', 1.2);
% % end
% 
% xticks(1:num_pairs)
% xticklabels(pair_labels)
% xtickangle(90)
% 
% yticks(1:Trials)
% yticklabels(1:Trials)
% 
% xlabel('Muscle Pairs', 'FontSize',12, 'FontWeight','normal')
% ylabel('Trial', 'FontSize',12, 'FontWeight','normal')
% title(['Bias-corrected Z-scores (' ...
%     num2str(freq_band(1)) '-' num2str(freq_band(2)) ' Hz)'], ...
%     'FontSize',14, 'FontWeight','normal')
% 
% set(gca, 'FontSize',10, 'FontWeight','normal', ...
%     'LineWidth',0.8, 'Box','off')
% 
% axis tight
% 
% % Display values
% for i = 1:Trials
%     for j = 1:num_pairs
%         val = zscore_matrix(i,j);
% 
%         if ~isnan(val)
%             if val > 1.5
%                 txtColor = 'w';
%             else
%                 txtColor = 'k';
%             end
% 
%             text(j, i, sprintf('%.2f', val), ...
%                 'HorizontalAlignment','center', ...
%                 'VerticalAlignment','middle', ...
%                 'FontSize',7, ...
%                 'FontWeight','normal', ...
%                 'Color', txtColor);
%         end
%     end
% end