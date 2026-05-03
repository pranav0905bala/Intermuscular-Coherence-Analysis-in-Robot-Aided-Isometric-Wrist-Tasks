function segment = segment_signal(signal, time, t_start, t_end)
mask = time >= t_start & time <= t_end;
segment = signal(mask);
segment = segment(isfinite(segment));
end
