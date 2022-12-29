classdef test_header < matlab.unittest.TestCase
    
    properties
        tempfile
        results
    end
    
    
    methods(TestMethodTeardown)
        function delete_tfile(self)
            if exist(self.tempfile), delete(self.tempfile); end
        end
    end
    
    
    methods(Test)
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
        
        function test_parquet_read_write(self)
            % creates a header with 654 traces, add two extra words and write to temporary file
            % on read after write, assert headers are the same
            ntr = 654;
            h = Header.create(ntr);
            h(54, :) = randn(1, ntr);
            h(22, :) = 14;
            self.tempfile = [tempname '.hpqt'];
            Header(h).write_parquet_header(self.tempfile )
            h_ = Header.read_parquet_header(self.tempfile );
            self.assertEqual(h, h_)
        end
    end
end
