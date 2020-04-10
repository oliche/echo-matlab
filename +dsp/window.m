classdef window
    % windowing for dsp applications
    
    methods(Static)
        
        function tap = cosine(ns, half)
            % sine function
            if nargin <= 1, half = true; end
            f = dsp.window.cosinefunc([1, ns], half);
            tap = f([1:ns]');
        end
        
        function func = cosinefunc(bounds, half)
        % func = sinefunc(bounds, half)
        % returns a function that applies a sine function for values between bounds
        % values outside of bounds are extrapolated flat
            if nargin <= 1, half = true; end
            if half, fac = 1; else fac = 2; end
            func = @(x) (1 - cos((x - bounds(1)) ./ (bounds(2) - bounds(1)) .* pi .* fac)) / 2;
            func = @(x) extrapolation_function(x, func, bounds);
        end
    end
end

function y = extrapolation_function(x, f, bounds)
    % this extrapolates a flat result outside of the bounds values
    y = f(x);
    y(x < bounds(1)) = f(bounds(1));
    y(x > bounds(2)) = f(bounds(2));
end
