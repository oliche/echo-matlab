%% test PCA on a 2D array
x = [[1:9]', [1:9]' + 7];
[z, fcn_forward, fcn_reverse] = stats.pca(x, 1);
% test forward PCA on a perfect line
assert(all(abs(diff(z)) - sqrt(2) < (10 * eps)))
% test reverse
assert(all(all(abs(fcn_reverse(z) - x) < ( 100 * eps))))

%% test with non equal scale
x = [[1:9]', [1:9]'*1.5 + 7];
[z, fcn_forward, fcn_reverse] = stats.pca(x, 1);
assert(all(all(abs(fcn_reverse(z) - x) < ( 100 * eps))))
