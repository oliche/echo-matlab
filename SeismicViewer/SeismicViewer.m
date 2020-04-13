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
h.im_seismic = imagesc([], 'parent', h.axe_seismic);
guidata(hobj, h);


% --- Outputs from this function are returned to the command line.
function varargout = SeismicViewer_OutputFcn(hobj, evt, h)
varargout{1} = h.output;
