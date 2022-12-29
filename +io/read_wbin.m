function [w, h] = read_wbin(wbin_file, options)
% [w, h] = read_wbin(wbin_file)
% wbin is a flat binary format containing samples in float 32 in a *.wbin file
% and a CST header with 64 words in a *.hbin file with matching name
% for example the pair of files: stack.wbin, stack.hbin
% -
% -
% Usages:
% [w, h] = read_wbin(..., 'memmap', true)
% -
% [w, h] = read_wbin(wbin_file, 'ntr', ntr, 'si', si)
% if the file doesn't have header, specify ntr / si, other additional
% arguments are inputs to Header.create
arguments
    wbin_file
    options.ntr = []
    options.si = .002
    options.memmap = false
end
[chem, fname, ~] = fileparts(wbin_file);
hbin_file = [chem filesep fname '.hbin'];
hpqt_file = [chem filesep fname '.hpqt'];

switch true
    case exist(hbin_file, 'file') == 2
        a = dir(hbin_file);
        ntr = a.bytes / 8 / 64;
        fid = fopen(hbin_file); h = fread(fid, Inf, 'double'); fclose(fid);
        h = reshape(h, [64, ntr]);
    case exist(hpqt_file, 'file') == 2
        h = Header.read_parquet_header(hpqt_file);
        ntr = size(h, 2);
    otherwise
        ntr = options.ntr;
        assert(nargin >= 1)
        h = Header.create(ntr, 'si', options.si);
end

a = dir(wbin_file);
ns = a.bytes / ntr / 4;
assert(mod(ns, 1) == 0)
if options.memmap
    w =  memmapfile(wbin_file,'Format', {'single', [ns, ntr], 'w'}, 'Writable', false);
else
    fid = fopen(wbin_file); w = fread(fid, Inf, '*single'); fclose(fid);
    w = reshape(w, [ns, ntr]);
end
