function [mstdx, mx] = mstd(x)
% median std
% [mstdx, mx] = mstd(x)
mx = median(x);
mstdx = median(abs(x - mx));
