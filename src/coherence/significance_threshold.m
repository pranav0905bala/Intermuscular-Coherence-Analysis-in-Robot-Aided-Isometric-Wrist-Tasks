function conf = significance_threshold(signal_length,noverlap,segment_length,alpha)

L = floor((signal_length - noverlap) / (segment_length - noverlap));
conf = 1 - alpha^(1/(L-1));
end
