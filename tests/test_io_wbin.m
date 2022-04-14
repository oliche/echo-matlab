classdef test_io_wbin < matlab.unittest.TestCase
    
    properties
        tdir
        wbin_file
        hbin_file
        ntr = 500
        ns = 2000
        data
        h
        si = .002
    end
    
    
    methods(TestMethodSetup)
        function create_dir_structures(testCase)
            testCase.tdir = [tempdir 'iotest' filesep];
            testCase.wbin_file = [testCase.tdir , filesep, 'toto.wbin'];
            testCase.hbin_file= [testCase.tdir , filesep, 'toto.hbin'];
            mkdir(testCase.tdir)
            % write the w file
            testCase.data = single(randn(testCase.ns, testCase.ntr));
            testCase.h = Header.create(testCase.ntr, 'si', testCase.si);
            fid = fopen(testCase.wbin_file, 'w+'); fwrite(fid, testCase.data, 'single'); fclose(fid);
        end
    end
    
    
    methods(TestMethodTeardown)
        function delete_dir(testCase)
            rmdir(testCase.tdir, 's');
        end
    end
    
    
    methods(Test)
        function test_read_with_header(testCase)
            fid = fopen(testCase.hbin_file, 'w+'); fwrite(fid, double(testCase.h(:)), 'double'); fclose(fid);
            [w, h] = io.read_wbin(testCase.wbin_file);
            
            assert(all(all(w == testCase.data)))
            assert(all(all(h == testCase.h)))
        end
        
        function test_read_no_header(testCase)
            [w, h] = io.read_wbin(testCase.wbin_file, testCase.ntr);
            assert(all(all(w == testCase.data)))
        end
    end
end
