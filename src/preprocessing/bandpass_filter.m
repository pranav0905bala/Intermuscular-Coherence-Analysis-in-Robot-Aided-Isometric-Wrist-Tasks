function xf = bandpass_filter(x, fs, low, high)
[b,a] = butter(4, [low high]/(fs/2), 'bandpass');
xf = filtfilt(b,a,x);
end
