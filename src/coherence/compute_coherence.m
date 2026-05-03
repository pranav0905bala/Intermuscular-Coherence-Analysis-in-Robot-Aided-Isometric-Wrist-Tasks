function [cxy,f] = compute_coherence(x,y,window,noverlap,nfft,fs)

min_len = min(length(x),length(y));
x = x(1:min_len);
y = y(1:min_len);

[cxy,f] = mscohere(x,y,window,noverlap,nfft,fs);
end
