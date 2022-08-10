function [vrms, twt] = vint2vrms(vint, depths, rep_vel)
% [vrms, twt] = velocities.vint2vrms(vint, depths);
% [vrms, twt] = velocities.vint2vrms(..., rep_vel);
% rep_vel is the average velocity over the [0-first depth range]
% (NB: the depth is usually 1 element larger than the interval velocity)

arguments
    vint (:, 1) double
    depths (:, 1) double
    rep_vel = Inf
end

t0 = depths(1) ./ rep_vel * 2;

% automatically resize the depth if necessary
if length(depths) == length(vint)
    dd = median(diff(depths));
    depths = filter2([.5;.5], [depths(1)-dd;  depths ; depths(end) + dd],'valid');
end

twt = [0 ; cumsum(diff(depths) ./ vint) * 2];
vrms = sqrt(cumsum([vint .^ 2 .* diff(twt)]) ./ twt(2:end));
vrms = [vrms(1) ; vrms];
twt = twt + t0;
