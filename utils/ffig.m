function fig = ffig
% returns a larger figure with white backgroung and a shortcut to copy
% to clipboard with ctr + shift + c


fig = figure('position', [200 200 900 600], 'color', 'w')

set(fig, 'WindowKeyPressFcn', @key_press)

end



function key_press(fig, evt)

if strcmp(evt.Key,  'c') && ~isempty(evt.Modifier)
    if all(cellfun(@(x) strcmp(x, 'shift') | strcmp(x, 'control'), evt.Modifier))
        print(fig, '-clipboard', '-dbitmap')
    end
    disp('figure copied')
end
end


