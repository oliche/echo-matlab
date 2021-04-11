function cm_view_spectrum(hobj, evt, h)
% context menu
h = guidata(hobj);
data = getappdata(h.fig_main, 'data');
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2), return, end
w = get(h.im_seismic, 'cdata');
[~, amp, ~, freq] = dsp.spectrum(w(:, round(pos(1))), data.si, 'Display', false);
pl = findobj('Type', 'line', 'tag', 'plot_spectrum');
if isempty(pl)
    f = figure('name', 'trace', 'numbertitle', 'off', 'color', 'w');
    ax = axes(f, 'tag', 'ax_spectrum');
    pl = plot(ax, freq,  amp, 'tag', 'plot_spectrum');
    xlabel(ax, 'Frequency (Hz)')
    ylabel(ax, 'psd (dB)')
else
    set(pl, 'ydata', amp)
end
