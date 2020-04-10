%% test dsp.window()
% full window
exp = [0 0.342020143325669 0.642787609686539 0.866025403784439 0.984807753012208 0.984807753012208 0.866025403784439 0.642787609686539 0.342020143325669 1.22464679914735e-16];
assert(all(abs(dsp.window.sine(10, false) - exp(:)) < 1e-10))
exp = [0 0.38268343236509 0.707106781186547 0.923879532511287 1 0.923879532511287 0.707106781186548 0.38268343236509 1.22464679914735e-16];
assert(all(abs(dsp.window.sine(9, false) - exp(:)) < 1e-10))
% half window
exp = [0 0.195090322016128 0.38268343236509 0.555570233019602 0.707106781186547 0.831469612302545 0.923879532511287 0.98078528040323 1];
assert(all(abs(dsp.window.sine(9) - exp(:)) < 1e10))
% test the extrapolation outside of the bounds
f = dsp.window.sinefunc([8 10]);
y = f(linspace(0, 50));
assert(y(1) == 0), assert(y(end) == 1), assert(max(y) == 1)
