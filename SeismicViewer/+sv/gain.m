function gain(h, dbscale)
factor = 10 .^ (dbscale / 20);
clims = caxis(h.axe_seismic);
clims = [diff(clims) ./ factor] .* [-.5 .5] + mean(clims);
caxis(h.axe_seismic, clims)
