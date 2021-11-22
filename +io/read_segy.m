function [W, H, fh, th] = read_segy(varargin)
% [W, H, fh, th] = read_segy(file_segy, th_format, fh_format)
% examples:
% 
% Written by Olivier Winter


sr = io.SegyReader1(varargin{:});
[W, th]= sr.read();
fh = sr.fh;

ntr = size(W, 2);
H = Header.create(ntr, 'si', sr.si);


fh2cst_cell = {
    'ffid', 22;...
    'shot_time', 50, ...
    };

th2cst_cell = {
    'itu_channel', 3 ;...
    'receiver_point', 18 ;...
    'receiver_point', 18 ;...
    'sensort_type', 28;...
    'receiver_line', 36;...
    'receiver_z', 52;...
    'source_z', 53;...
    'receiver_x', 60;...
    'receiver_y', 61;...
    'source_x', 62;...
    'source_y', 63;...
};

% generic functions to build cst
for m = 1:length(fh2cst_cell)
    [fname, icst] = fh2cst_cell{m, :};
    if ~isfield(fh, fname), continue, end
    H(icst, :) = fh.(fname);
end

for m = 1:length(th2cst_cell)
    [fname, icst] = th2cst_cell{m, :};
    if ~isfield(th, fname), continue, end
    H(icst, :) = th.(fname);
end

H(20, :) = abs((H(60, :) - H(62, :)) + 1i * (H(61, :) - H(63, :)));
