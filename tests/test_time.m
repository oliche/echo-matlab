%% Main function to generate tests
function tests = test_time
tests = functiontests(localfunctions);
end

%% Test Functions
function test_conversions(self)
epoch = [int64(1251711996000000); int64(1251711996000000)];
gps = [int64(1251711996000000); int64(1251711996000000)];
posix = 1251711996;


assert(all(time.epoch2serial(epoch) == time.posix2serial(posix)))
assert(all(time.epoch2posix(epoch) == posix))

assert(all(all(datevec(time.gps2serial(gps)) == [2019 9 5 9 46 18])))

end
