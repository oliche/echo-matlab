function write_wbin(filename, w, h, options)
%  write_wbin(filename, w, h)
%  write_wbin(filename, w, h, 'modifier', 'w+')

arguments
    filename  % output filename, usually with extension wbin
    w  % seismic array
    h = [] % header
    options.modifier = 'w+';  % file open modifier 'w+', 'a'
end

fid = fopen(filename, options.modifier);
fwrite(fid, w(:, :), 'single');
fclose(fid);

if ~isempty(h)
    [chem, fn, ~] = fileparts(filename);
    fid = fopen([chem, filesep, fn, '.hbin'], options.modifier);
    fwrite(fid, double(h(:, :)), 'double');
    fclose(fid);
end
end
