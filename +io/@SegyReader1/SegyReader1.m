classdef SegyReader1 < io.SeismicReaderInterface
    % sr = SegyReader3(full_path_to_segd_file);
    % seg-y v1 reader
    % Written by Olivier Winter
    %
    methods
        function self = SegyReader1(file_segy, fh_format)
            %SEGDREADER3 Construct an instance of this class
            %   Detailed explanation goes here
            %   sr = SegyReader(file_segd)
            
            %             fhbin  % binary file header
            %             fhsize  % binary file header size in bytes
            %             n_bytes_file  % total file length in bytes
            %             ns  % number of samples per trace
            %             ntr  % number of traces
            %             rl  % record length (s)
            %             si  % sampling interval (s)
            %             thsize  % single binary trace header size in bytes
            
            self.file = file_segy;
            
            %% interpret data size / header size in block 3
            % check consistency by reading file size, and header size, make sure it checks out
            finfo = dir(file_segy);
            self.fid = fopen(file_segy, 'r');
            
            self.n_bytes_file = 0;
            self.fhsize = 0;
            
            
            %% read in file header and store crucial properties
            fseek(self.fid, 0, 'bof');
            fhbin = fread(self.fid, self.fhsize, '*uint8');
            
            % fh.n_bytes_file_header + self.ns * 1
            [self.fh, self.fhbin] = self.interpret_fhbin(fhbin);
            self.rl = self.fh.extended_record_length;
            self.si = self.fh.base_scan_interval;
            self.ns = round(self.rl / self.si);
            self.ntr = double(sum(self.fh.chset.number_of_channels));
            
            % check consistency by making sure the trace header and data sum up to file size
            self.thsize = unique(self.fh.chset.number_of_trace_header_extensions) * 32 + 20;
            assert(length(self.thsize) == 1)
            expected_size = self.trace_offset(self.ntr + 1);
            assert(expected_size == self.fh.n_bytes_file)
        end
    end
    
    methods (Static)
        [fh, fh_bin] = interpret_fhbin(fid, fh_format)
        [th] = interpret_thbin(thbin, th_format)
        
        function fh_format= get_fh_format(fh_format)
           assert(nargin == 0)  % merge fh_format is not implemented yet  TODO
           default_fh_format = create_fh_format(sr, ns);
           fh_format = default_fh_format;
        end
        
        function fh_format = create_fh_format(sr, ns)
            % formatcell = SegyWriter1.default_fh_format(sr, ns)
            if nargin <= 1, sr = 0; end
            if nargin <= 2, ns = 0; end
            
            fh_format = {...
                'int32',  1, 4, 'Job', 1;...
                'int32',  5, 8, 'Line', 1;...
                'int32',  9, 12, 'Reel', 1;...
                'int16',  13, 14, 'DataTracePerEnsemble', 1;...
                'int16',  15, 16, 'AuxiliaryTracePerEnsemble', 0;...
                'uint16',  17, 18, 'Si', sr * 1e6;...
                'uint16',  19, 20, 'SiOrig', sr * 1e6;...
                'uint16',  21, 22, 'Nech', ns;...
                'uint16',  23, 24, 'NechOrig', ns;...
                'int16',  25, 26, 'DataSampleFormat', 5;... % 1:IBM Float32, 2INT32, 3INT16, 4: Exp 5:IEEE float32
                'int16',  27, 28, 'EnsembleFold', 1;...
                'int16',  29, 30, 'TraceSorting', 0;... % 0:Unknown, 1:As recorded, 2:CDP
                'int16',  31, 32, 'VerticalSumCode', 1;...
                'int16',  33, 34, 'SweepFrequencyStart', 0;...
                'int16',  35, 36, 'SweepFrequencyEnd', 0;...
                'int16',  37, 38, 'SweepLength', 0;...
                'int16',  39, 40, 'SweepType', 0;...
                'int16',  41, 42, 'SweepChannel', 0;...
                'int16',  43, 44, 'SweepTaperlengthStart', 0;...
                'int16',  45, 46, 'SweepTaperLengthEnd', 0;...
                'int16',  47, 48, 'TaperType', 0;...
                'int16',  49, 50, 'CorrelatedDataTraces', 0;... % 1:no, 2:yes
                'int16',  51, 52, 'BinaryGain', 0;...
                'int16',  53, 54, 'AmplitudeRecoveryMethod', 0;...
                'int16',  55, 56, 'MeasurementSystem', 2;... % 1:metric 2:feet
                'int16',  57, 58, 'ImpulseSignalPolarity', 0;...
                'int16',  59, 60, 'VibratoryPolarityCode', 0;...
                'int16',  301, 302, 'SegyFormatRevisionNumber', 0;...
                'int16',  303, 304, 'FixedLengthTraceFlag', 1;...
                'int16',  305, 306, 'NumberOfExtTextualHeaders', 0;...
                };
        end
       
    end
end