classdef SeismicReaderInterface < handle
    % Interface to define seismic readers
    % Based on the common structure: FileHeader, (Trace Header - Trace Data) * Ntraces
    
    properties (Constant)
       SAMPLE_SIZE = 4 
    end
    
    properties
        fid  % file identifier object
        file  % full-file path
        fh  % file header structure
        fhbin  % binary file header
        fhsize  % binary file header size in bytes
        n_bytes_file  % total file length in bytes
        ns  % number of samples per trace
        ntr  % number of traces
        rl  % record length (s)
        si  % sampling interval (s)
        thsize  % single binary trace header size in bytes
    end
    
    methods (Abstract)
        [fh, fh_bin] = interpret_fhbin(fid)
        % this methods returns a file header structure and a fh_bin array from a file identifier
        [th] = interpret_thbin(thbin)
        % this methods returns a trace header structure from a 2D thbin uint8 array
    end
    
    methods 
        function delete(self)
            % on object deletion close the file identifier instance
            fclose(self.fid);
        end
        
        function offset = trace_offset(self, trace_index)
            % self.trace_offset(trace_index)
            % computes the offset in bytes for a given trace index
           offset = (trace_index - 1) * (self.ns * self.SAMPLE_SIZE + self.thsize) + self.fhsize; 
        end
        
        function [data, th, thbin] = read(self, varargin)
            % [data, th, thbin] = read(self, first, last)
            
            % parse input arguments
            p = inputParser;
            addOptional(p, 'first', 1);
            addOptional(p, 'last', self.ntr);
            parse(p, varargin{:});
            first = p.Results.first;
            last = p.Results.last;

            % read the traces
            fseek(self.fid, self.trace_offset(first), 'bof');
            ntr_ = last - first + 1;
            data = fread(self.fid, [self.ns * self.SAMPLE_SIZE + self.thsize, ntr_], '*uint8');
            thbin = data(1:self.thsize, :);
            data = data(self.thsize + [1:self.ns * self.SAMPLE_SIZE], :);
            data = reshape(typecast(data(:), 'single'), [self.ns, ntr_]);
            if self.fh.format_code == 8058,
                data = swapbytes(data); % could use a speed up in mex if necessary, but all new data is segd v3 
                % and little endian so left it fo now
            else
                assert(self.fh.format_code == 9058)  % reads IEEE float little endian
            end
            
            % interpret the trace header
            [th] = self.interpret_thbin(thbin);
        end
        
       
        function [check, expected_size, file_size] = checksize(self)
            % [check, computed_size] = self.checksize(self)
            % check that the filesize matches the header and data sizes
            % returns true when it matches, false
            finfo = dir(self.file);
            expected_size = self.ntr * (self.ns * self.SAMPLE_SIZE + self.thsize) + self.fhsize;
            file_size = finfo.bytes; 
            check = file_size == expected_size;
        end
    end
    
end
