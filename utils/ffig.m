function fig = ffig(varargin)
% returns a larger figure with white backgroung and a shortcut to copy
% to clipboard with ctr + shift + c
if nargin == 0
    fig = figure('position', [200 200 900 600], 'color', 'w');
else
    fig = figure(varargin{:});
end
set(fig, 'WindowKeyPressFcn', @key_press)

end



function key_press(fig, evt)
% ctrl + c to copy figure to clipboard
if strcmp(evt.Key,  'c') && ~isempty(evt.Modifier)
    if all(cellfun(@(x) strcmp(x, 'shift') | strcmp(x, 'control'), evt.Modifier))
        print(fig, '-clipboard', '-dbitmap')
        disp('figure copied')
    end
end

end
