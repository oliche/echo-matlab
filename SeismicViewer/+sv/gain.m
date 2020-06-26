function gain(h, dbscale)
% set the gain up/down from a dbscale amount

factor = 10 .^ (dbscale / 20);
clims = caxis(h.axe_seismic);
clims = [diff(clims) ./ factor] .* [-.5 .5] + mean(clims);
caxis(h.axe_seismic, clims)
