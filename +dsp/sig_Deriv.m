function [Y,rep]=sig_Deriv(X,si,order)
% Filtre Derivatuer
% [Y,rep]=sig_Integ(X,si,order)
% X :      Input Array : filter will be done in dimension 1
% si:      Sampling in seconds
% order:   derivation order (optional)
                 
if ~exist('order','var');order=1;end

dF=1/(size(X,1)*si);
F=dF*[0 1:((size(X,1))/2) -fliplr((1:size(X,1)/2-.25))].';
w=2*pi*F;

Y=fft(X);
Y=bsxfun(@times,Y,(1i*w).^order);
Y=real(ifft(Y));



