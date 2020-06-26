function figsv = viewseis(W, H, varargin)
% viewseis(W,H)
% viewseis(W,H, 'name', 'mytitle')


%% parse input arguments
p=inputParser;
p.addParameter('name', 'SeismicViewer', @isstr);
p.parse(varargin{:});
for ff=fields(p.Results)', eval([ff{1} '=p.Results.' ff{1} ';' ]); end


%% multiple figures management: the name of the figure is the key to find a pre-existing window
registered_figures = getappdata(0, 'viewseis');
% clean up the registered figures variables by checking if they exist
registered_figures(arrayfun(@(x) ~isvalid(x), registered_figures)) = [];
% if an instance already exists, get this ones
ind = find(arrayfun(@(x) isvalid(x) && strcmp(get(x, 'name'),name) , registered_figures));
if isempty(ind)
    figsv = SeismicViewer();
    registered_figures = [registered_figures; figsv];
else
    figsv = registered_figures(ind);
end
setappdata(0, 'viewseis', registered_figures)
set(figsv, 'name', name)

%% get figure handles and start updating data
h = guidata(figsv);
[ns, ntr] = size(W(:, :));
si = H(9) / 1e6;

%% set the data structure in the GUI
setappdata(h.fig_main, 'data', struct('W', W, 'H', Header(H), 'ns', ns, 'ntr', ntr, 'si', si));
h.var = struct('ybounds', [0 (ns - 1) .* si], 'xbounds', [1 ntr], 'button_hold_point', 0);
guidata(figsv, h)

%% update the display according to data
sv.draw(figsv)

% set the offset as a default header value
set(h.ed_header, 'String', 'offset')
edcallback = get(h.ed_header, 'Callback');
edcallback(h.ed_header, [])

end
