function cm_view_spectrogram(hobj, evt, h)
h = guidata(hobj);
data = getappdata(h.fig_main, 'data');
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2), return, end
w = get(h.im_seismic, 'cdata');
[tf, tscale, fscale] = dsp.tf(w(:, round(pos(1))), data.si);
im = findobj('Type', 'image', 'tag', 'im_spectrogram');
if isempty(im)
    f = figure('name', 'spectrogram', 'numbertitle', 'off', 'color', 'w');
    ax = axes(f, 'tag', 'ax_spectrogram');
    im = imagesc(ax, fscale, tscale, tf, 'tag', 'im_spectrogram');
    colorbar(ax)
    xlabel(ax, 'Frequency (Hz)')
    ylabel(ax, 'Time (secs)')
else
    set(im, 'cdata', tf)
end
maxi = max(tf(:));
set(get(im, 'Parent'), 'clim', [maxi - 80, maxi], 'ylim', xylims(3:4))
