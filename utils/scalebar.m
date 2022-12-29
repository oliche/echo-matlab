function  scalebar(ax, options)
% scalebar(ax)
% scalebar(ax, scale=1000) 
% adds a scale bar to an existing axes. The ax must have an aspect ration of all ones
assert(all(get(ax, 'DataAspectRatio') == 1))
lims = axis(ax);

dx = diff(lims(1:2));
scale = 10 .^ (floor(log10(dx)) - 1);

q = quiver(ax, lims(1) + dx / 10, lims(3) + dx / 10, scale, 0, 1,...
    'ShowArrowHead', 'off',...
    'color', 'k',...
    'linewidth', 2)

t = text(lims(1) + dx / 10, lims(3) + dx * .075,'1 km','Color','k','FontWeight','bold');

end
