function [Y,rep]=sig_FiltBW(X,si,par,phase)
% Filtre Butterworth
% X :      Input Array : filter will be done in dimension 1
% si:      Sampling in seconds
% par:     array of 4 parameters [a b c d] a = freq of low cut b slope in db/oct of low cut c freq high cut d slope high cut
%          if freq or slope = 0 no filter in  order to do only lc or hc
% phase:   'lin' or 'min'. If no parameters lin phase 
                 

if ~exist('phase','var');phase='lin';end

if any(par(1:2)==0)
    LC=[];
else
    LC=par(1:2);
end
if any(par(3:4)==0)
    HC=[];
else
    HC=par(3:4);
end

dF=1/(size(X,1)*si);
F=dF*[0 1:((size(X,1))/2) -fliplr((1:size(X,1)/2-.25))].';
w=2*pi*F;

rep=ones(size(X,1),1);
if ~isempty(LC)
    Fc=LC(1);
    wc=2*pi*Fc;
    ord=round(LC(2)/6);
    rep=rep.*(1./(sqrt(1+(wc./w).^(2*ord))));
end
if ~isempty(HC)
    Fc=HC(1);
    wc=2*pi*Fc;
    ord=round(HC(2)/6);
    rep=rep.*(1./(sqrt(1+(w/wc).^(2*ord))));
end

if strcmp(phase,'min')
    tmp=rep;
    tmp(1)=tmp(2);
    Rot90=1i*sign(F);Rot90(1)=1;
    Pha=real(ifft(fft(log(tmp)-mean(log(tmp))).*Rot90));
    rep=rep.*exp(1i*Pha);
end

Y=fft(X);
Y=bsxfun(@times,Y,rep);
Y=real(ifft(Y));



