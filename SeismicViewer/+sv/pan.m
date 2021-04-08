function pan(h, dx, dy)
% pan(h, dx, dy)
% sv.zoom(h, 0.1, 0.1) % 10% zoom in

xlim = get(h.axe_seismic, 'xlim');
ylim = get(h.axe_seismic, 'ylim');
xlim_ = xlim + dx;
ylim_ = ylim + dy;
if xlim_(1) >= h.var.xbounds(1) && xlim_(2) <= h.var.xbounds(2)
    xlim = xlim_;
end
if ylim_(1) >= h.var.ybounds(1) && ylim_(2) <= h.var.ybounds(2)
    ylim = ylim_;
end

set(h.axe_seismic, 'xlim', xlim, 'ylim', ylim)
