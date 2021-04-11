classdef test_dsp < matlab.unittest.TestCase
    
    methods(Test)
        function test_dsp_tf(self)
           %% spectrogram test on a sweep - check that the extracted instantaneous frequency matches
           ns = 2000;
           si = 0.002;
           fbounds = [4, 96];
           f = linspace(fbounds(1), fbounds(2), ns)';
           sweep = sin(2 * pi * cumsum(f * si));
           [tf, tscale, fscale] = dsp.tf(sweep, si);
           figure, imagesc(fscale, tscale, tf), set(gca, 'clim', max(tf(:)) + [- 80, 0])
           [vmax, imax] = max(tf, [], 2);
           assert(all(size(tf) == [length(tscale) length(fscale)]))
           assert( mean(interp1([0: (ns - 1)] * si, f, tscale)' - fscale(imax)) < 0.05)
           assert( abs(mean(vmax)  + 9.9035) < 0.01)
        end
             
        function test_dsp_window(self)
            %test dsp.window()
            % full window
            exp = [0;0.116977778440511;0.413175911166535;0.75;0.969846310392954;0.969846310392954;0.75;0.413175911166535;0.116977778440511;0];
            self.assertTrue(all(abs(dsp.window.cosine(10, false) - exp(:)) < 1e-10))
            self.assertTrue(all(abs(dsp.window.hanning(10, false) - exp(:)) < 1e-10))
            exp = [0;0.146446609406726;0.5;0.853553390593274;1;0.853553390593274;0.5;0.146446609406726;0];
            assert(all(abs(dsp.window.cosine(9, false) - exp(:)) < 1e-10))
            assert(all(abs(dsp.window.hanning(9, false) - exp(:)) < 1e-10))
            % half window
            exp = [0;0.0380602337443566;0.146446609406726;0.308658283817455;0.5;0.691341716182545;0.853553390593274;0.961939766255643;1];
            self.assertTrue(all(abs(dsp.window.cosine(9) - exp(:)) < 1e10))
            % test the extrapolation outside of the bounds
            f = dsp.window.cosinefunc([8 10]);
            y = f(linspace(0, 50));
            assert(y(1) == 0), assert(y(end) == 1), assert(max(y) == 1)
            % test bounds int64
            f = dsp.window.cosinefunc(int64([8 10]));
            y = f(linspace(0, 50));
            assert(y(1) == 0), assert(y(end) == 1), assert(max(y) == 1)
        end
        
        function test_filters(self)
            % seed the random number generator
            rng(42)
            s = rand(2000, 5, 'single') - 0.5;
            % low pass filter, with without padding should look the same in the middle
            lp = dsp.ffilter.lp(s, 0.002, [10, 15]);
            lp2 = dsp.ffilter.lp(s, 0.002, [10, 15], 'padding', 1, 'taper', 0.8);
            self.assertTrue( max(abs(lp2(500:1000) - lp(500:1000))) < 0.001)
            % high pass filter, with without padding should look the same in the middle
            hp = dsp.ffilter.hp(s, 0.002, [50, 60]);
            hp2 = dsp.ffilter.hp(s, 0.002, [50, 60], 'padding', 1, 'taper', 0.8);
            self.assertTrue( max(abs(hp2(500:1000) - hp(500:1000))) < 0.001)
            % bandpass should look like the original minus the 2 others
            bp = dsp.ffilter.bp(s, 0.002, [10, 15, 50, 60], 'padding', 1, 'taper', 0.8);
            self.assertTrue(max(max(abs((s - lp2 - hp2) - bp))) < 1e6)
        end
        
        function test_deriv_integ(self)
            % seed the random number generator
            rng(42)
            nech = 2000;
            s = rand(nech, 5, 'single');
            s = dsp.ffilter.bp(s, 0.002, [4 8 50 80]);
            % test derivation
            sd = dsp.deriv(s, 1);
            sd1 = interp1([1:nech-1] - 0.5, diff(s(:, 1)), [1:nech] - 1, 'spline')';
            self.assertTrue(mean(abs(sd1 - sd(:,1))) < 0.001)
            % test integration
            s_ = dsp.integ(sd, 0.002, [3 , 0]);
            self.assertTrue(max(abs(s(:, 1) - s_(:,1) ./ 0.002)) < 1e-5)
            s_ = dsp.integ(sd, 0.002, [3 , 1], 'padding', 1, 'taper', 0.8);
        end
        
    end
end