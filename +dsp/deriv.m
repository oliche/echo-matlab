function [Y,rep] = deriv(X,si,order)
% Filtre Derivateur
% [Y,rep] = dsp.deriv(X,si,order)
% X :      Input Array : filter will be done in dimension 1
% si:      Sampling in seconds
% order:   derivation order (optional)
% author: T. Bianchi

if ~exist('order','var');order=1;end

dF=1/(size(X,1)*si);
F=dF*[0 1:((size(X,1))/2) -fliplr((1:size(X,1)/2-.25))].';
w=2*pi*F;

Y=fft(X);
Y=bsxfun(@times,Y,(1i*w).^order);
Y=real(ifft(Y));



