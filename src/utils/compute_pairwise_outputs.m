function OUT = compute_pairwise_outputs(ext,flex,fs,window,noverlap,nfft,alpha,freq_band,segment_length,muscle_names)

nMuscles = length(muscle_names);

beta_ext = NaN(nMuscles);
beta_flex = NaN(nMuscles);

Z_ext = [];
Z_flex = [];
labels = {};

idx = 1;

for m1 = 1:nMuscles
for m2 = m1+1:nMuscles

[cxy,f] = compute_coherence(ext{m1},ext{m2},window,noverlap,nfft,fs);
conf = significance_threshold(length(ext{m1}),noverlap,segment_length,alpha);

L = floor((length(ext{m1}) - noverlap)/(segment_length - noverlap));
z = compute_zscore(cxy,conf,L,f);

beta_idx = (f>=freq_band(1) & f<=freq_band(2));

beta_ext(m1,m2) = mean(cxy(beta_idx));
Z_ext(idx) = mean(z(beta_idx));

[cxy,f] = compute_coherence(flex{m1},flex{m2},window,noverlap,nfft,fs);
z = compute_zscore(cxy,conf,L,f);

beta_flex(m1,m2) = mean(cxy(beta_idx));
Z_flex(idx) = mean(z(beta_idx));

labels{idx} = [muscle_names{m1} '-' muscle_names{m2}];
idx = idx + 1;

end
end

OUT.beta_mean_ext = beta_ext;
OUT.beta_mean_flex = beta_flex;
OUT.Z_ext_allpairs = Z_ext';
OUT.Z_flex_allpairs = Z_flex';
OUT.pair_labels = labels;
end
