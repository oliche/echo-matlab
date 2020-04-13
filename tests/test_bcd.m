classdef test_bcd < matlab.unittest.TestCase
    
    
    methods(Test)
        
        function test_scalars(self)
            % uint4 / uint8
            self.assertEqual(io.bcd2dec(22), 16)
            % uint16
            self.assertEqual(io.bcd2dec(22 + 256), 116)
            % uint32
            self.assertEqual(io.bcd2dec(22 + 256^2), 10016)
        end
        
        function test_arrays(self)
            in = [22, 23, 24];
            out = [16, 17, 18];
            % test multiple shapes multiple types
            test_shapes(in, out)
            test_shapes(uint8(in), out)
            test_shapes(uint16(in) + 256, out + 100)
            test_shapes(uint32(in) + 256^2, out + 10000)
            
            function test_shapes(in, out)
                self.assertEqual(io.bcd2dec(in), out)
                self.assertEqual(io.bcd2dec(in'), out')
                self.assertEqual(io.bcd2dec(repmat(in, 5, 2)), repmat(out, 5, 2))
            end
            
        end
    end
end
