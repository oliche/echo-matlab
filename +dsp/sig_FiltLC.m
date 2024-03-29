function [Y,rep]=sig_FiltLP(X,si,par,phase)
% Filtre Butterworth
% X :      Input Array : filter will be done in dimension 1
% si:      Sampling in seconds
% par:     array of 2 parameters [a b ] a = freq of low cut, b=order order 1 6dB 2:12db 3:18db ... 
% phase:   'lin' or 'min'. If no parameters lin phase 
                 
if ~exist('phase','var');phase='lin';end

dF=1/(size(X,1)*si);
F=dF*[0 1:((size(X,1))/2) -fliplr((1:size(X,1)/2-.25))].';
w=2*pi*F;

rep=ones(size(X,1),1);
Fc=par(1);
wc=2*pi*Fc;
ord=par(2);
rep1=conj(1./(1+1i*(wc./w)));
rep2=conj(1./(1+1i*(wc./w)/.7-(wc./w).^2));

n2=floor(ord/2);
n1=ord-2*n2;
rep=rep1.^n1.*rep2.^n2;


if strcmp(phase,'lin')
    rep=abs(rep);
end

Y=fft(X);
Y=bsxfun(@times,Y,rep);
Y=real(ifft(Y));



