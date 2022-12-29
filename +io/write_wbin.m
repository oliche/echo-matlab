function write_wbin(filename, w, h, options)
%  write_wbin(filename, w, h)
%  write_wbin(filename, w, h, 'modifier', 'w+', 'parquet', false)
% writes a wbin seismic file. The format is a flat binary file in float32 little endian. 
% the header is a flat binary file, 64 words by number of traces (see Header)  
% options:
%     'modifier': opening file flag, possible to use 'a' to append to an existing file - defaults to 'w+'
%    'parquet': writes header in parquet format - defaults to false (incompatible with append flag)

arguments
    filename  % output filename, usually with extension wbin
    w  % seismic array
    h = [] % header
    options.modifier = 'w+';  % file open modifier 'w+', 'a'
    options.parquet = false;
end

fid = fopen(filename, options.modifier);
fwrite(fid, w(:, :), 'single');
fclose(fid);

[chem, fn, ~] = fileparts(filename);
switch true
    case ~isempty(h) && options.parquet == false
        % write hbin header
        fid = fopen([chem, filesep, fn, '.hbin'], options.modifier);
        fwrite(fid, double(h(:, :)), 'double');
        fclose(fid);
    case ~isempty(h) && options.parquet == true
        % write parquet header, in this case the append flag is not supported
        assert(options.modifier(1) == 'w')
        Header(h).write_parquet_header([chem, filesep, fn, '.hpqt'])
end
end
