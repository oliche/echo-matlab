classdef ffilter
    % Fourier domain filters
    % dsp.ffilter.lp(X, 0.002, [20 30], 'padding', 0.5, 'taper', 0.2)
    % dsp.ffilter.hp(X, 0.002, [2 4], 'padding', 0.5, 'taper', 0.2)
    % dsp.ffilter.bp(X, 0.002, [2 4 80 100], 'padding', 0.5, 'taper', 0.2)
    
    methods(Static)
        %% low pass filter - 2 frequency values
        function ts_ = lp(ts, si, b, varargin)
            % dsp.ffilter.lp(X, 0.002, [20 30], 'padding', 0.5, 'taper', 0.2)
            ts_ = generic_filter(ts, si, b, 'lp', varargin{:});
        end
        
        %% high pass filter - 2 frequency values
        function ts_ = hp(ts, si, b, varargin)
            % dsp.ffilter.hp(X, 0.002, [2 4], 'padding', 0.5, 'taper', 0.2)
            ts_ = generic_filter(ts, si, b, 'hp', varargin{:});
        end
        
        %% band pass filter - 4 frequency values
        function ts_ = bp(ts, si, b, varargin)
            % dsp.ffilter.bp(X, 0.002, [2 4 80 100], 'padding', 0.5, 'taper', 0.2)
            ts_ = generic_filter(ts, si, b, 'bp', varargin{:});
        end
    end
end


function ts_ = generic_filter(ts_, si,b, type,  varargin)
% Inputs
p=inputParser;
p.addParameter('padding', 0, @isnumeric);
p.addParameter('taper', 0, @isnumeric);
p.parse(varargin{:});
for ff=fields(p.Results)', eval([ff{1} '=p.Results.' ff{1} ';' ]); end
size_orig = size(ts_);
ts_ = dsp.padding_tapering(ts_, si, padding, taper, true);

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
ts_ = dsp.padding_tapering(ts_, si, padding, taper, false);
ts_ = reshape(ts_, size_orig);
end
