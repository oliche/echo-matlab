%% Main function to generate tests
function tests = test_header
tests = functiontests(localfunctions);
end

%% Test Functions
function test_create(self)
ns = 2000;
ntr = 500;
si = 0.002;
offset = [0 : ntr - 1] * 10;

H = Header.create(500, 'offset', [0 : ntr - 1] * 10, 'si', 0.002);

assert(all(H(20, :) == offset))
H = H.set('offset', -offset);

assert(all(H(20, :) == -offset));

assert(all(H.offset(:) == H(20, :)))
assert(all(H.offset(1:10) == H(20, 1:10)))
assert(all(H.offset == H(20, :)))

end