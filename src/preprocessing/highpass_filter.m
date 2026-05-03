function xf = highpass_filter(x, b, a)
x = x(isfinite(x));
xf = filtfilt(b, a, x);
end
