function gain(h, dbscale)
% sv.gain(h)
% sv.gain(h, dbscale)
% set the gain up/down from a dbscale amount

% get the gain from the edit string
gain = str2double(get(h.ed_gain, 'String'));
if isnan(gain)
    gain = 20 .* log10(get(h.ed_gain, 'UserData'));
end

if nargin <= 1, dbscale = 0; end
gain = gain + dbscale;
set(h.axe_seismic, 'clim', 10 .^ (gain / 20)  * 4 .* [-1 1])
set(h.ed_gain, 'String', num2str(gain))
