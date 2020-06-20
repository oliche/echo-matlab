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

% Last Modified by GUIDE v2.5 18-Feb-2020 10:03:48

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
% create empty objects and set defaults
colormap(h.fig_main, 'bone')
set(h.fig_main, 'KeyPressFcn', @fig_key_press)
set(h.fig_main, 'WindowScrollWheelFcn', @fig_scroll_wheel)
set(h.fig_main, 'WindowButtonDownFcn', @fig_button_down)
set(h.fig_main, 'WindowButtonMotionFcn', @fig_button_motion)
h.im_seismic = imagesc([], 'parent', h.axe_seismic);
guidata(hobj, h);


% --- Outputs from this function are returned to the command line.
function varargout = SeismicViewer_OutputFcn(hobj, evt, h)
varargout{1} = h.output;

% ---- Custom Callbacks
function fig_key_press(hobj, evt)
h = guidata(hobj);
switch true
    % ctr+a : display gain + 3dB
    case strcmp(evt.Key, 'a') & strcmp('control', evt.Modifier)
        sv.gain(h, 3)
    % ctr+z : display gain - 3dB
    case strcmp(evt.Key, 'z') & strcmp('control', evt.Modifier)
        sv.gain(h, -3)
    case strcmp(evt.Key, 'escape')
        set(h.axe_seismic, 'xlim', h.var.xbounds, 'ylim', h.var.ybounds)
end


function fig_scroll_wheel(hobj, evt, h)
h = guidata(hobj);
xr = - 0.1 .* evt.VerticalScrollCount;
yr = - 0.1 .* evt.VerticalScrollCount;
sv.zoom(h, xr, yr)

function fig_button_motion(hobj, evt, mode)
if nargin <= 2, return, end
h = guidata(hobj);
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2) || pos(3) < xylims(3) || pos(3) > xylims(4), return, end
dpos = pos - h.var.button_hold_point;
switch mode
    case 'pan'
        sv.pan(h, -dpos(1), -dpos(3))
    case 'zoom'
        xr = min(0.9, max(-.9,   dpos(1) / diff(xylims(1:2))));
        yr = min(0.9, max(-.9, - dpos(3) / diff(xylims(3:4))));
        sv.zoom(h, xr, yr);
        h.var.button_hold_point = pos;
end
guidata(hobj, h)

%% ax callbacks
function fig_button_down(hobj, evt)
h = guidata(hobj);
pos = get(h.axe_seismic, 'CurrentPoint');
xylims = axis(h.axe_seismic);
if pos(1) < xylims(1) || pos(1) > xylims(2) || pos(3) < xylims(3) || pos(3) > xylims(4), return, end
switch get(hobj, 'SelectionType')
    case 'normal'
        set(hobj,'WindowButtonUpFcn', @fig_button_up,'WindowButtonMotionFcn', {@fig_button_motion, 'pan'})
    case 'alt'
        set(hobj, 'WindowButtonUpFcn', @fig_button_up, 'WindowButtonMotionFcn', {@fig_button_motion, 'zoom'})
    case 'open'
end
h.var.button_hold_point = pos;
guidata(hobj, h)

function fig_button_up(hobj, evt)
set(hobj, 'WindowButtonUpFcn', '', 'WindowButtonMotionFcn', @fig_button_motion)




