function [Y,rep] = deriv(X, si, order)
% Filtre Derivateur
% [Y,rep] = dsp.deriv(X, si, order)
% X :      Input Array : filter will be done in dimension 1
% si:      Sampling in seconds
% order:   derivation order (optional)
% author: TB, OW

if ~exist('order','var');order=1;end

w = 2 * pi .* dsp.fscale(size(X,1), si);

Y = fft(X);
Y = bsxfun(@times, Y, (1i * w) .^ order);
Y = real(ifft(Y));
