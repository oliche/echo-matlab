function [tf, tscale, fscale] = tf(w, si, nswin, nsoverlap, nsfft)
% [tf, tscale, fscale] = dsp.tf(w, si, nswin, nsoverlap, nsfft)
% Computes a spectrogram suited for seismic analysis

% those defaults are well suited for 2ms seismic data with 5-10 secs long
% traces
if nargin <= 3, nswin = 200; end
if nargin <= 4, nsoverlap = round(nswin / 40); end
if nargin <= 5, nsfft = 512; end
ns = size(w, 1);
nspad = nswin;
w = dsp.padding_tapering(w, si, nspad * si, nspad * si, true);
assert(nsfft > nswin)

% construct the time domain TF by constructing an array of shifted indices
first_ech = 1 : nsoverlap : (ns + nsoverlap);
sel = (first_ech >= nswin / 2) & ( (first_ech + nswin) <= ns);
first_ech = first_ech(sel);
nwin = length(first_ech);
tmp = repmat([0 : (nswin - 1)]', 1, nwin) + first_ech; % here tmp contains indices

% create time and frequency scales
fscale = dsp.fscale(nsfft, si, 'real');
tscale = (first_ech + nswin ./ 2 - nspad ) * si;
% direct indexation using tmp indices - store the windowed trace into the
% tmp array to save memory
tmp = w(tmp) .* dsp.window.cosine(nswin, false);

tf = abs(dsp.freduce(fft([tmp; zeros(nsfft - size(tmp, 1), size(tmp, 2))])));
% the 1.6 is for the cosine window and the rest is normalization of Matlab fft
tf = 20 .* log10(transpose(tf) .* sqrt(2 * si / nswin) .* 1.6);
%figure, imagesc(fscale, tscale, tf)

end

