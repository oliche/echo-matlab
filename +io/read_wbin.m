function [w, h] = read_wbin(wbin_file, from, to)
% [w, h] = read_wbin(wbin_file)
% wbin is a flat binary format containing samples in float 32 in a *.wbin file
% and a CST header with 64 words in a *.hbin file with matching name
% for example the pair of files:
% awesome_stack.wbin
% awesome_stack.hbin

[chem, fname, ext] = fileparts(wbin_file);
hbin_file = [chem filesep fname '.hbin'];
a = dir(hbin_file);
ntr = a.bytes / 8 / 64; 

if nargin <= 1, from = 1; end
if nargin <= 2, to = ntr; end


fid = fopen(hbin_file); h = fread(fid, Inf, 'double'); fclose(fid);
fid = fopen(wbin_file); w = fread(fid, Inf, 'single'); fclose(fid);


h = reshape(h, [64, ntr]);
w = reshape(w, [numel(w) / ntr, ntr]);

