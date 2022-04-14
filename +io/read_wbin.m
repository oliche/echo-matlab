function [w, h] = read_wbin(wbin_file, ntr, si, varargin)
% [w, h] = read_wbin(wbin_file)
% if the file doesn't have header, specify ntr / si, other additional
% arguments are inputs to Header.create
% [w, h] = read_wbin(wbin_file, ntr, si, [...])
% wbin is a flat binary format containing samples in float 32 in a *.wbin file
% and a CST header with 64 words in a *.hbin file with matching name
% for example the pair of files:
% awesome_stack.wbin
% awesome_stack.hbin

[chem, fname, ~] = fileparts(wbin_file);
hbin_file = [chem filesep fname '.hbin'];

if exist(hbin_file, 'file')
    a = dir(hbin_file);
    ntr = a.bytes / 8 / 64; 
    fid = fopen(hbin_file); h = fread(fid, Inf, 'double'); fclose(fid);
    h = reshape(h, [64, ntr]);
else
    assert(nargin >= 1)
    if nargin <= 2, si = .002; end
    h = Header.create(ntr, 'si', si, varargin{:});
end


fid = fopen(wbin_file); w = fread(fid, Inf, 'single'); fclose(fid);
w = reshape(w, [numel(w) / ntr, ntr]);
