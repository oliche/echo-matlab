

v = [2.2;3.9;4.5; 4.7 ;4.7] *1e3
t = [.1;.5;  1; 2 ;4]
dt = .01
Si = .002;
Lsmooth = 30

ntr = 50;
ns = 2000;
W = zeros(2000, 50, 'single');
offset = [0: ntr - 1] .* 100;
H = Header.create(50);
H(20, :) = offset;


[iangle, vdix]= incident_angle(ns, H, t, v);





%% Get the angles at the reflectors for all offsets
cangle = iangle .* 0;
for n = 1:size(cangle, 1)
    
    % figure, plot(H.offset, iangle(is, :))
    
    % shoot the rays back up from the reflector using snells laws and the incidence angle found
    vel = vdix(n:-1:1);
    start_angle = 10;
    rt = vel.*0;
    rt = iangle(ns, :);
    for m = 1:length(vel)-1
        rt = asind(vdix(m) * sind(rt) / vdix(m + 1));
    end
     cangle(n, :) = rt;
end

ViewData(iangle, H, 'iangle')
ViewData(cangle, H, 'cangle')
