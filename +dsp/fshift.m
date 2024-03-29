function [w] = fshift(w, shift)
% [w] = fshift(w, shift)
% Applies a time shift in frequency domain, a positive values shifts forward
% w: nd array, the shift is applied to the first dimension
% shift: shift in samples, can be a non-integer value

size_w = size(w);
% dephas embodies a 1 sample shift transform
dephas = zeros(size_w(1), 1);
dephas(2) = 1;
dephas = dsp.freduce(fft(dephas));

% applies the phase shift and go back to time domain
w = real(ifft(dsp.fexpand(dsp.freduce(fft(w(:, :))) .* (exp(1i * angle(dephas) * shift)), size_w(1))));
w = reshape(w, size_w);

end
