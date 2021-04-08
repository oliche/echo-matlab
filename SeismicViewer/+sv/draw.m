function  draw(fig, set_gain)
% sv.draw(fig)
if nargin <= 1, set_gain = true; end


h = guidata(fig);
data = getappdata(fig, 'data');

isnewfig = isempty(h.var.xbounds) || isempty(h.var.ybounds);
h.var.xbounds = [1 data.ntr];
h.var.ybounds = [0 (data.ns - 1) .* data.si];
guidata(fig, h);


set(h.im_seismic, 'CData', data.W(:,:), 'ydata', [0, data.ns * data.si], 'xdata', [1, data.ntr])

% update the header
cbk_ed_header = get(h.ed_header, 'Callback');
cbk_ed_header(h.ed_header, [])

% on figure creation set axes limit and gain
if isnewfig
    set(h.axe_seismic, 'xlim', [1 data.ntr], 'ylim', [0 (data.ns - 1) .* data.si])
    % set gain
    if set_gain
        mrms = max(eps, median(dsp.rmsnan(data.W(:, :))));
        set(h.ed_gain, 'UserData', mrms)
        set(h.ed_gain, 'String', num2str(20 .* log10(mrms)))
        sv.gain(h)
    end
end