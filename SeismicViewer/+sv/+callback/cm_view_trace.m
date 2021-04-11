function cm_view_trace(hobj, evt, h)
h = guidata(hobj);
data = getappdata(h.fig_main, 'data');
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2), return, end
w = get(h.im_seismic, 'cdata');
pl = findobj('Type', 'line', 'tag', 'plot_trace');
if isempty(pl)
    f = figure('name', 'trace', 'numbertitle', 'off', 'color', 'w');
    ax = axes(f, 'tag', 'ax_plot_trace');
    pl = plot(ax,[0 : size(w, 1) - 1]' .* data.si,  w(:, round(pos(1))), 'tag', 'plot_trace');
else
    set(pl, 'ydata', w(:, round(pos(1))))
end
set(get(pl, 'parent'), 'xlim', xylims(3:4))
