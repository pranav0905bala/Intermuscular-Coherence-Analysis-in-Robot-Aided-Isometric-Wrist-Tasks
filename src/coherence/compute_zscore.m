function z_corr = compute_zscore(cxy,conf,L,f)

cxy(cxy <= conf) = 0;

Fz = atanh(sqrt(cxy));
z = Fz / sqrt(1/(2*L));

bias = mean(z(f>=100 & f<=250),'omitnan');
z_corr = z - bias;

z_corr(z_corr < 0) = 0;
end
