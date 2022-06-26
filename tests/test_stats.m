%% Main function to generate tests
function tests = test_stats
tests = functiontests(localfunctions);
end

%% Test Functions

function test_conversions(self)
% test PCA on a 2D array
x = [[1:9]', [1:9]' + 7];
[z, fcn_forward, fcn_reverse] = stats.pca(x, 1);
% test forward PCA on a perfect line
assert(all(abs(diff(z)) - sqrt(2) < (10 * eps)))
% test reverse
assert(all(all(abs(fcn_reverse(z) - x) < ( 100 * eps))))
% test with non equal scale
x = [[1:9]', [1:9]'*1.5 + 7];
[z, fcn_forward, fcn_reverse] = stats.pca(x, 1);
assert(all(all(abs(fcn_reverse(z) - x) < ( 100 * eps))))
end
    

function test_rcorr_pairwise(self)
rng(42)
x = rand(1000, 2);
y = x(:, 1);
r2 = corrcoef(x(:, 2), y);
r2 = r2(1, 2);
r1 = 1;

assert(stats.rcoeff(x(:, 1), y) == r1)
assert(abs(stats.rcoeff(x(:, 2), y) - r2) < (1e2 * eps))
assert(all(stats.rcoeff(x, y) - [r1, r2] < (1e2 * eps)))
assert(all(stats.rcoeff(x, fliplr(x)) - r1 < (1e2 * eps)))
end