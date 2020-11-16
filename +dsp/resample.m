function X = resample(X, si_in, si_ou)
% X = dsp.resample(X, Si_in, Si_ou)
% resample signal using interpolation in frequency domain

[Nech_in, Ntr] = size(X);

switch 1
    
    case mod(si_ou / si_in, 1) == 0
        % downsample data after antialias filter
        ratio = si_ou / si_in;
        lp = 1 ./ si_ou ./ 2 .* [.8 1];
        X = dsp.ffilter.lp(X, si_in, 'lp', 'padding', si_in * 100, 'taper', si_in * 100);
        X = X(1:ratio:end, :);
    case mod(si_in / si_ou, 1) == 0
        errordlg('upsample by integer factor not implemented yet.')
    otherwise % arbitrary resample
        Nech_ou = round(Nech_in * si_in/si_ou);
        X = dsp.freduce(fft(X));
        fscale_in = dsp.fscale(Nech_in, si_in, 'real');
        fscale_ou = dsp.fscale(Nech_ou, si_ou, 'real');
        X = interp1(fscale_in, X, fscale_ou);
        X(isnan(X)) = 0;
        X = real(ifft(dsp.fexpand(X,Nech_ou)));
end
