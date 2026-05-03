function [EMG_al, time_EMG] = load_emg_data(file)

EMG_al = extractTrignoEMG(file);
raw = readmatrix(file);

time_EMG = raw(8:end,1);
end
