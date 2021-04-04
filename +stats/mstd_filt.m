function [y, ix] = mstd_filt(x, n)
% rejects samples above n median standard deviation
% [y, ix] = stats.mstd_filt(x, n)

[mstd, med] = stats.mstd(x);
ix = between(x, med + n * mstd * [-1, 1]);
y = x(ix);
