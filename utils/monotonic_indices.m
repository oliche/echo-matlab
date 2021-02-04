function ia = monotonic_indices(a)
% ia = monotonic_indices(a)
% for a vector a, returns corresponding indices of the unique set of values
% monotonic_indices([.1, .2, .1, .3]) returns [1, 2, 1, 3]

[~, ia] = ismember(a, unique(a));
