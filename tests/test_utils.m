a = [43;11;59;27;43;11;59;27;43;11;59;27;43;11;59;27;43;11;59;27];
assert(all(monotonic_indices(a) == repmat([3, 1, 4, 2]', 5, 1)))
