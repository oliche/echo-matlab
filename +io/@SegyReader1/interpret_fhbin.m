function [fh, fh_bin] = interpret_fhbin(fid, fh_format)

% EBCDIC text header
if nargin <= 2, fh_format = {}; end

temp = fread(fid, 3200, '*uint8');
fh.text_header = char(reshape(io.bcd2ascii(temp),80,40)');


%% Binary File Header (400 bytes)
aaa = fread(fid,400,'*uint8');

fh_format = SegyWriter1.get_fh_format(fh_format);

% convert the format cell to a structure
F = cell2struct(fh_format,{'format','start','end','field','default'},2);

% loop over each field to interpret the trace header
for m = 1:length(F)
    siz = F(m).end-F(m).start+1;
    fh.(F(m).field) = typecast(aaa(F(m).start:F(m).end),F(m).format);
    % keep precision for int64 time fields
    switch endian
        case 'b'
            fh.(F(m).field) = swapbytes(fh.(F(m).field));
        case 'l'
            fh.(F(m).field) = fh.(F(m).field);
    end
    if ~strcmp(F(m).format,'int64'), fh.(F(m).field) = double(fh.(F(m).field)); end
end

% output the binary header if requested
if nargout == 2,
    fseek(fid,0,'bof');
    fhbin = fread(fid,SegyReader1.fhsize,'*uint8');
end

end
