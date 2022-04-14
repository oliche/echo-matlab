%% Main function to generate tests
function tests = test_utils
tests = functiontests(localfunctions);
end

function test_monotonic_indices(self)
a = [43;11;59;27;43;11;59;27;43;11;59;27;43;11;59;27;43;11;59;27];
assert(all(monotonic_indices(a) == repmat([3, 1, 4, 2]', 5, 1)))
end
