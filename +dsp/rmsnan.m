function r = rmsnan(X, dim)
% rms = dsp.rmsnan(X)
% computes rms for signals containing NaNs of Infs

if nargin<=1, dim=1; end
nind = isnan(X) | isinf(X);

valid_count = max(1, sum(~nind, dim));

X(isnan(X)) = 0;
r = sqrt(sum(X.^2, dim) ./ valid_count);
