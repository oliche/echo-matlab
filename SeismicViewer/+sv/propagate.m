function propagate(fig)
% set all SeismicViewer figures to the same size

figures = getappdata(0, 'viewseis');



set(figures, 'Position', get(fig, 'Position'))

%%
h = guidata(fig);
axe_seismic_props = {'xlim', 'ylim'};
props = get(h.axe_seismic, axe_seismic_props );
for m = 1:length(figures)
    if figures(m) == fig, continue, end
    h_ = guidata(figures(m));
    set(h_.axe_seismic, axe_seismic_props , props)
end