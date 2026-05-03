function OUT = process_participant1_condition(robot_files,emg_files,NumReps,ext_trial,flex_trial,...
fs,window,noverlap,nfft,alpha,freq_band,segment_length,b,a,muscle_names)

nMuscles = length(muscle_names);

all_ext = cell(NumReps,nMuscles);
all_flex = cell(NumReps,nMuscles);

for r = 1:NumReps

Robot = readmatrix(robot_files{r});
time_robot = Robot(2:end,7);
Trial_End = Robot(2:end,6);

[EMG_al,time_EMG] = load_emg_data(emg_files{r});

signals = {EMG_al.FCR,EMG_al.ECU,EMG_al.FCU,EMG_al.ECRL,...
           EMG_al.FDS,EMG_al.EDC,EMG_al.TRICEPS,EMG_al.BICEPS};

idx_end = find(diff(Trial_End)==1)+1;
idx_end = idx_end - 1000;
idx_start = idx_end - 3000;

Start_Times = time_robot(idx_start);
End_Times = time_robot(idx_end);

for t = 1:length(Start_Times)
    for m = 1:nMuscles
        seg = segment_signal(signals{m},time_EMG,Start_Times(t),End_Times(t));
        xf = highpass_filter(seg,b,a);
        rect{t,m} = abs(xf);
    end
end

for m = 1:nMuscles
    all_ext{r,m} = rect{ext_trial,m};
    all_flex{r,m} = rect{flex_trial,m};
end

end

concat_ext = cellfun(@(x) vertcat(x{:}),num2cell(all_ext,1),'UniformOutput',false);
concat_flex = cellfun(@(x) vertcat(x{:}),num2cell(all_flex,1),'UniformOutput',false);

OUT = compute_pairwise_outputs(concat_ext,concat_flex,fs,window,noverlap,nfft,alpha,freq_band,segment_length,muscle_names);
end
