function [Y,rep] = integ(X, si, varargin)
% Filtre Integrateur + LowCut
% [Y,rep] = dsp.integ(X,si,par, 'phase', phase)
% X :      Input Array : filter will be done in dimension 1
% si:      Sampling in seconds
% par:     array of 2 parameters [a b ] a = freq of low cut, b=order order 1 6dB 2:12db 3:18db ... 
% phase:   'lin' or 'min'. If no parameters min phase 

% author: TB, OW  

p=inputParser;
p.addOptional('par', [1, 0]);
p.addParameter('phase', 'min');
p.addParameter('padding', 0, @isnumeric);
p.addParameter('taper', 0, @isnumeric);
p.parse(varargin{:});
for ff=fields(p.Results)', eval([ff{1} '=p.Results.' ff{1} ';' ]); end

Y = dsp.padding_tapering(X, si, padding, taper, true); % apply taper / padding before compute
ns = size(Y, 1);
w = 2 * pi .* dsp.fscale(ns, si);

rep = ones(ns,1);
Fc=par(1);
wc=2*pi*Fc;
ord=par(2);
rep1=conj(1./(1+1i*(wc./w)));
rep2=conj(1./(1+1i*(wc./w)/.7-(wc./w).^2));

n2=floor(ord/2);
n1=ord-2*n2;
rep=rep1.^n1.*rep2.^n2;

rep=rep./(1i*w);rep(1)=rep(2);

if strcmp(phase,'lin')
    rep=abs(rep);
end

Y = fft(Y);
Y = bsxfun(@times,Y,rep);
Y = real(ifft(Y));
Y = dsp.padding_tapering(Y, si, padding, taper, false); % removetaper / padding before compute
