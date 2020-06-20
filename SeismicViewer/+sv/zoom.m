function zoom(h, xr, yr)
% sv.zoom(h, xratio, yratio)
% sv.zoom(h, 0.1, 0.1) % 10% zoom in

xlim = get(h.axe_seismic, 'xlim');
ylim = get(h.axe_seismic, 'ylim');
xlim = diff(xlim) * (1 - xr) .* [-.5 .5] + mean(xlim); % lock the x axis to the middle
% ylim = diff(ylim) * (1 - yr) .* [-.5 .5] + mean(ylim); 
ylim = diff(ylim) * (1 - yr) .* [0 1] + ylim(1); % lock the y axis to the top

xlim = min(h.var.xbounds(2), max(h.var.xbounds(1), xlim));
ylim = min(h.var.ybounds(2), max(h.var.ybounds(1), ylim));
set(h.axe_seismic, 'xlim', xlim, 'ylim', ylim)
