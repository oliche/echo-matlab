function [iangle, vDix]= incident_angle(W, H, T, V, lsmooth)
%  iangl, vDix = incident_angle(W, H, T, V, Lsmooth)
% V : velocity
% T : Times
% Si: sampling of Dix velocities
% 
% 
% V=[2.2;3.9;4.5; 4.7 ;4.7]*1e3
% T=[.1;.5;  1; 2 ;4]
% dt=.01
% Si=.002;
% Lsmooth=30

si = H(9) / 1e6;
switch true
    case isscalar(W), ntr = W;
    otherwise, ntr = size(W, 1);
end

if nargin <= 4, lsmooth = 30; end
if T(1) ~= 0, V = [V(1); V]; T = [0;T]; end
if T(end) < (si * ntr), V = [V; V(end)]; T = [T; si * size(W, 1)]; end

tscale = [0:ntr - 1]' * si;
v = interp1(T,V,tscale);
if lsmooth ~= 0
    smooth = hanning(lsmooth);
    smooth = smooth/sum(smooth);
    pad = ceil(lsmooth/2);
    v = filter2(smooth,[v(1)*ones(pad,1) ; v ; v(end)*ones(pad,1)]);
    v = v(pad+1:end-pad);
end
vDix = sqrt(diff(v .^ 2 .* tscale) / si);
vDix = real(vDix([1:end end]));

% sin2=x^2Vi^2/(Vr.^2*(Vr^2.t0^2+x^2)
offsets = H(20, :);

% Yilmaz method
iangle = real(asin(sqrt(bsxfun(@times,offsets.^2,vDix.^2) ./ ...
    bsxfun(@times,v.^2,bsxfun(@plus,(tscale.*v).^2,offsets.^2)))) * 180/pi);
% geovecteur
% iangle = atand(vDix ./ (tscale .* v .^ 2 ) * offsets); 
