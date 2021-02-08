function varargout = SeismicViewer(varargin)
%SEISMICVIEWER MATLAB code file for SeismicViewer.fig
%      SEISMICVIEWER, by itself, creates a new SEISMICVIEWER or raises the existing
%      singleton*.
%
%      H = SEISMICVIEWER returns the handle to a new SEISMICVIEWER or the handle to
%      the existing singleton*.
%
%      SEISMICVIEWER('Property','Value',...) creates a new SEISMICVIEWER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to SeismicViewer_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SEISMICVIEWER('CALLBACK') and SEISMICVIEWER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SEISMICVIEWER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SeismicViewer

% Last Modified by GUIDE v2.5 08-Feb-2021 16:46:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SeismicViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @SeismicViewer_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SeismicViewer is made visible.
function SeismicViewer_OpeningFcn(hobj, evt, h, varargin)
h.output = hobj;
h.var = struct('ybounds', [], 'xbounds', [], 'button_hold_point', 0);
% create empty objects and set defaults: figure
colormap(h.fig_main, 'bone')
set(h.fig_main, 'KeyPressFcn', @fig_key_press)
set(h.fig_main, 'WindowScrollWheelFcn', @fig_scroll_wheel)
set(h.fig_main, 'WindowButtonDownFcn', @fig_button_down)
set(h.fig_main, 'WindowButtonMotionFcn', {@fig_button_motion, ''})
% create empty objects and set defaults: axes
linkaxes([h.axe_header, h.axe_seismic], 'x')
% create empty objects and set defaults: objects
h.im_seismic = imagesc([], 'parent', h.axe_seismic);
h.pl_header = plot(h.axe_header, NaN, [NaN; NaN; NaN; NaN]);
h.axe_header.XAxis.Visible = 'off';
% create context menus
h.cm = uicontextmenu('parent',h.fig_main);
set(h.axe_seismic,'UIContextMenu',h.cm);
set(h.axe_header,'UIContextMenu',h.cm);
h.cms = struct();
h.cms.view_trace = uimenu(h.cm,'Label','view Trace', 'callback', @cm_view_trace_callback);
guidata(hobj, h);


% --- Outputs from this function are returned to the command line.
function varargout = SeismicViewer_OutputFcn(hobj, evt, h)
varargout{1} = h.output;

%% ---- Window Callbacks
function fig_key_press(hobj, evt)
h = guidata(hobj);
switch true
    % ctr+a : display gain + 3dB
    case strcmp(evt.Key, 'z') & strcmp('control', evt.Modifier)
        sv.gain(h, 3)
    % ctr+z : display gain - 3dB
    case strcmp(evt.Key, 'a') & strcmp('control', evt.Modifier)
        sv.gain(h, -3)
    % ctr+p : propagate display
    case strcmp(evt.Key, 'p') & strcmp('control', evt.Modifier)
        sv.propagate(h.fig_main)
    % ctr+c : copy figure to clipboard
    case strcmp(evt.Key, 'c') & strcmp('control', evt.Modifier)
        print(h.fig_main, '-clipboard', '-dbitmap')
    % escape: reset the original display
    case strcmp(evt.Key, 'escape')
        set(h.axe_seismic, 'xlim', h.var.xbounds, 'ylim', h.var.ybounds)
end


function fig_scroll_wheel(hobj, evt, h)
% the mouse scroll wheel acts as a zoom in y and x
h = guidata(hobj);
xr = - 0.1 .* evt.VerticalScrollCount;
yr = - 0.1 .* evt.VerticalScrollCount;
sv.zoom(h, xr, yr)

function fig_button_motion(hobj, evt, mode)
% mouse hovering callback
% if the mouse is whithin the header or seismic axes, look if there is a callback on the trace
% display (plot trace, spectrum or time-frequency)
% if the mouse is whithin the seismic axes, trigger the pan and hold callback.
h = guidata(hobj);
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2), return, end  % the mouse is not whithin the lateral extent of axes
dpos = pos - h.var.button_hold_point;
switch mode
    case 'pan'
        if pos(3) < xylims(3) || pos(3) > xylims(4), return, end % the mouse is not over the seismic axes
        sv.pan(h, -dpos(1), -dpos(3))
    case 'zoom'
        if pos(3) < xylims(3) || pos(3) > xylims(4), return, end % the mouse is not over the seismic axes
        xr = min(1.5, max(-1.5,   dpos(1) / diff(xylims(1:2))));
        yr = min(0.9, max(-.9, - dpos(3) / diff(xylims(3:4))));
        sv.zoom(h, xr, yr);
        h.var.button_hold_point = pos;
    otherwise
        % update the string values
        w = get(h.im_seismic, 'cdata');
        hv = get(h.pl_header, 'ydata');
        data = getappdata(h.fig_main, 'data');
        tr = round(pos(1));
        t = pos(1, 2); s = round(t / data.si);
        if t < h.var.ybounds(1) || t > h.var.ybounds(2),
            amp = NaN;
        else
            amp = w(s, tr);
        end
        hval = [];
        for m = 1:length(hv),
            if ~isnan(hv{m}), hval = [hval, hv{m}(tr)]; end
        end
        hformat = repmat('%4.4f ', 1, length(hval));
        set(h.txt_hover, 'String', sprintf(['amp: %4.4f \ntrace: %0.0f \ntime: %0.4f \nheader: ' hformat], [amp, tr, t, hval]))
        set(h.txt_hover, 'HorizontalAlignment', 'left')
        % update the plot traces
        pl = findobj('Type', 'line', 'tag', 'plot_view_trace');
        if ~isempty(pl)
            set(pl, 'ydata', w(:, tr))
        end
end
guidata(hobj, h)

%% ax callbacks
function fig_button_down(hobj, evt)
% on button down, if the click is on the seismic axes, store the location of the click in h.var
% a right click and hold triggers the zoom hovering callback
% a left click and hold triggers the pan hovering callback
h = guidata(hobj);
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2), return, end
% stores the click location
h.var.button_hold_point = pos;
guidata(hobj, h)
% is the click happened over the seismic axes, triggers hovering callbacks
if pos(3) < xylims(3) || pos(3) > xylims(4), return, end
switch get(hobj, 'SelectionType')
    case 'normal'
        set(hobj,'WindowButtonUpFcn', @fig_button_up,'WindowButtonMotionFcn', {@fig_button_motion, 'pan'})
    case 'alt'
        set(hobj, 'WindowButtonUpFcn', @fig_button_up, 'WindowButtonMotionFcn', {@fig_button_motion, 'zoom'})
    case 'open'
end


function fig_button_up(hobj, evt)
% deactivates the hold and hover pan and zoom callbacks
set(hobj, 'WindowButtonUpFcn', '', 'WindowButtonMotionFcn', {@fig_button_motion, ''})

%% --- Menu Callbacks
function cm_view_trace_callback(hobj, evt, h)
h = guidata(hobj);
data = getappdata(h.fig_main, 'data');
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2), return, end
w = get(h.im_seismic, 'cdata');
pl = findobj('Type', 'line', 'tag', 'plot_view_trace');
if isempty(pl)
    f = figure('name', 'view trace', 'numbertitle', 'off', 'color', 'w');
    ax = axes(f, 'tag', 'ax_view_trace');
    pl = plot(ax,[0 : size(w, 1) - 1]' .* data.si,  w(:, round(pos(1))), 'tag', 'plot_view_trace');
else
    set(pl, 'ydata', w(:, round(pos(1))))
end
set(get(pl, 'parent'), 'xlim', xylims(3:4))

%% --- Objects Callbacks
function hdata = get_header_data_from_edit_string(obj, data)
% possible inputs are a header string such as "offset", a single or several
% (4 max) header indices. Todo write a quick test when extending this to
% multiple header strings
hdata = NaN;
try
    str = get(obj, 'String');
    if ~isempty(str2num(str))
        hdata = double(data.H(str2num(str), :));  % one or several indices
    else 
        hdata = data.H.(lower(str)); % header string
    end
    set(obj, 'BackgroundColor', [1 1 1])
catch
    set(obj, 'BackgroundColor', [.9 .8 .5])
    return
end

function ed_sort_Callback(hobj, evt, h)
h = guidata(hobj);
data = getappdata(h.fig_main, 'data');
hdata = get_header_data_from_edit_string(hobj, data);
if isnan(hdata), return , end
[~, ordre] = sortrows(hdata');
% no need to change anything if the order didn't change
if all(ordre == [1:data.ntr]'), return, end  
% sort all the necessary fields
data.W = data.W(:, ordre);
data.H = data.H(:, ordre);
data.order = data.order(ordre);
data.sel = data.sel(ordre);
setappdata(h.fig_main, 'data', data)
% update the gui display
sv.draw(h.fig_main)


function ed_header_Callback(hobj, evt, h)
h = guidata(hobj);
data = getappdata(h.fig_main, 'data');
hdata = get_header_data_from_edit_string(hobj, data);
if isnan(hdata), return , end
% Make it work for several
for m = 1:length(h.pl_header)
    if size(hdata, 1) < m
        set(h.pl_header(m), 'xdata', NaN, 'ydata', NaN)
    else
        set(h.pl_header(m), 'xdata', 1:data.ntr, 'ydata', hdata(m, :))
    end
end


function ed_gain_Callback(hobj, evt, h)
h = guidata(hobj);
sv.gain(h)




