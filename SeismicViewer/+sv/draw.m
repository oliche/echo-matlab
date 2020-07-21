function  draw(fig)
%DRAW Summary of this function goes here
%   Detailed explanation goes here

h = guidata(fig);
data = getappdata(fig, 'data');
set(h.im_seismic, 'CData', data.W(:,:), 'ydata', [0, data.ns * data.si], 'xdata', [1, data.ntr])
set(h.axe_seismic, 'xlim', [1, data.ntr], 'ylim', [0, data.ns * data.si])
set(h.axe_seismic, 'clim', median(dsp.rmsnan(data.W(:, :))) * 4 .* [-1 1])
end
