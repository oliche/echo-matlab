function  draw(fig)
% sv.draw(fig)

h = guidata(fig);
data = getappdata(fig, 'data');
set(h.im_seismic, 'CData', data.W(:,:), 'ydata', [0, data.ns * data.si], 'xdata', [1, data.ntr])
set(h.axe_seismic, 'xlim', [1, data.ntr], 'ylim', [0, data.ns * data.si])

% set gain
mrms = max(eps, median(dsp.rmsnan(data.W(:, :))));
set(h.ed_gain, 'UserData', mrms)
set(h.ed_gain, 'String', num2str(20 .* log10(mrms)))
sv.gain(h)
end
