function propagate(fig)
% set all SeismicViewer figures to the same size

figures = getappdata(0, 'viewseis');
set(figures, 'Position', get(fig, 'Position'))
h = guidata(fig);

% list in a structure the properties to update. Field names are the handle tag and values properties
props.axe_seismic = {'xlim', 'ylim'};
props.ed_gain = 'String';
fields_update = fields(props);

% loop over figures
for m = 1:length(figures)
    if figures(m) == fig, continue, end
    h_ = guidata(figures(m));
    % for each pair of object/properties defined in props structure, update dependent figures
    % with the template
    for m = 1:length(fields_update)
        object = fields_update{m};
        master_property_values = get(h.(object), props.(object));  
        set(h_.(object), props.(object) , master_property_values)
    end
    drawnow
    % at the end, update the display (gain)
    sv.gain(h_)
end

