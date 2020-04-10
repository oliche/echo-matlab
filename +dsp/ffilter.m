classdef ffilter
    % Fourier domain filters
    
    methods(Static)
        %% low pass filter - 2 frequency values
        function ts_ = lp(ts, si, b, varargin)
            ts_ = generic_filter(ts, si, b, 'lp', varargin{:});
        end
        
        %% high pass filter - 2 frequency values
        function ts_ = hp(ts, si, b, varargin)
            ts_ = generic_filter(ts, si, b, 'hp', varargin{:});
        end
        
        %% band pass filter - 4 frequency values
        function ts_ = bp(ts, si, b, varargin)
            ts_ = generic_filter(ts, si, b, 'bp', varargin{:});
        end
    end
end


function ts_ = generic_filter(ts, si,b, type,  varargin)
% Inputs
p=inputParser;
p.addParameter('padding', 0, @isnumeric);
p.addParameter('taper', 0, @isnumeric);
p.parse(varargin{:});
for ff=fields(p.Results)', eval([ff{1} '=p.Results.' ff{1} ';' ]); end
ts_ = ts;
% apply mirror padding at the beginning + tapering
if padding > 0
    npad = round(padding / si);
    size_orig = size(ts);
    ts_ = [ts(npad:-1:2, :); ts(:,:); ts(end-1:-1:end-npad+1,:)];
end
% apply taper in / taper out
if taper > 0 
   ntap = round(taper / si);
    ts_(1:npad, :) = bsxfun(@times, ts_(1:npad, :), dsp.window.cosine(npad)); % taper in
    ts_(end-npad+1:end, :) = bsxfun(@times, ts_(end-npad+1:end, :), 1 - dsp.window.cosine(npad)); % taper in
end
% compute the filter and apply in frequency domain
[ns, ntr] = size(ts_);
f = dsp.freduce(dsp.fscale(ns, si));
switch type
    case 'hp'
        filc = arrayfun(dsp.window.cosinefunc(b), f);
    case 'lp'
        filc = 1 - arrayfun(dsp.window.cosinefunc(b), f);
    case 'bp'
        filc = arrayfun(dsp.window.cosinefunc(b(1:2)), f);
        filc = filc .* (1 - arrayfun(dsp.window.cosinefunc(b(3:4)), f));
end
ts_ = real(ifft(bsxfun(@times, fft(ts_), dsp.fexpand(filc, ns))));
% remove the padding if any
if padding > 0
    ts_ = ts_(npad:end-(npad-1), :);    
end
ts_ = reshape(ts_, size_orig);
end