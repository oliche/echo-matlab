classdef test_io_wbin < matlab.unittest.TestCase
    
    properties
        tdir
        wbin_file
        hbin_file
        hpqt_file
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
            testCase.hpqt_file= [testCase.tdir , filesep, 'toto.hpqt'];
            mkdir(testCase.tdir)
            % write the w file
            testCase.data = single(randn(testCase.ns, testCase.ntr));
            testCase.h = Header.create(testCase.ntr, 'si', testCase.si);
        end
    end
    
    
    methods(TestMethodTeardown)
        function delete_dir(testCase)
            rmdir(testCase.tdir, 's');
        end
    end
    
    
    methods(Test)
        function test_read_with_compressed_header(testCase)
            % the main use of this function: read file and separate file header
            io.write_wbin(testCase.wbin_file, testCase.data, testCase.h, 'parquet', true)
            [w, h] = io.read_wbin(testCase.wbin_file);
            assert(all(all(w == testCase.data)))
            assert(all(all(h == testCase.h)))
        end
        
        function test_read_with_header(testCase)
            % the main use of this function: read file and separate file header
            io.write_wbin(testCase.wbin_file, testCase.data, testCase.h)
            [w, h] = io.read_wbin(testCase.wbin_file);
            assert(all(all(w == testCase.data)))
            assert(all(all(h == testCase.h)))
        end
        
        function test_read_no_header(testCase)
            % in this case write only an array without any header
            io.write_wbin(testCase.wbin_file, testCase.data)
            [w, h] = io.read_wbin(testCase.wbin_file, 'ntr', testCase.ntr);
            assert(all(all(w == testCase.data)))
        end
        
        function test_cat(testCase)
            % concatenate files
            io.write_wbin(testCase.wbin_file, testCase.data, testCase.h)
            io.write_wbin(testCase.wbin_file, testCase.data, testCase.h, 'modifier', 'a')
            [w, h] = io.read_wbin(testCase.wbin_file);
            assert(all(all(w == [testCase.data, testCase.data])))
            assert(all(all(h == [testCase.h, testCase.h])))
        end
        
        function test_memmap(testCase)
            % concatenate files
            io.write_wbin(testCase.wbin_file, testCase.data, testCase.h)
            [mmap, h] = io.read_wbin(testCase.wbin_file, 'memmap', true);
            assert(all(all(mmap.Data.w == testCase.data)))
            assert(all(all(h == testCase.h)))
        end
        
    end
end
