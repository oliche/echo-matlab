classdef SegyReader1 < io.SeismicReaderInterface
    % sr = SegyReader3(full_path_to_segd_file);
    % seg-y v1 reader
    % Written by Olivier Winter
    %
    properties
       fh_format
       th_format
    end
    methods
        function self = SegyReader1(file_segy, th_format, fh_format)
            %SEGDREADER3 Construct an instance of this class
            %   Detailed explanation goes here
            %   sr = SegyReader(file_segy, th_format, fh_format)
            if nargin <= 1, th_format = {}; end
            if nargin <= 2, fh_format = {}; end
            % constants
            self.fh_format = self.get_fh_format(fh_format);
            self.th_format = self.get_th_format(th_format);
            self.fhsize = 3600;
            self.thsize =  240;
            self.file = file_segy;
            finfo = dir(file_segy);
            self.n_bytes_file = finfo.bytes;
            self.fid = fopen(file_segy, 'r');
            
            %% read in file header and store crucial properties
            fseek(self.fid, 0, 'bof');
            fhbin = fread(self.fid, self.fhsize, '*uint8');
            self.fh = self.interpret_fhbin(fhbin);
            self.si = self.fh.si / 1e6;  % sampling interval in seconds
            self.ns = self.fh.ns;  % number of samples
            self.rl = self.si * self.ns;  % record length (s)
            self.endianess = 'big';
            self.sample_size = 4;
            switch self.fh.data_sample_format % 1:IBM Float32, 2INT32, 3INT16, 4: Exp 5:IEEE float32
                case 1, self.sample_format = 'ibm';
                case 2, self.sample_format = 'int32';
                case 3, self.sample_format = 'int16'; self.sample_size = 2;
            end
            % compute the number of traces from the file size
            self.ntr = (self.n_bytes_file - self.fhsize) / (self.thsize + self.ns * self.sample_size);
            assert(mod(self.ntr, 1) == 0)
        end
    
        function [fh, fh_bin] = interpret_fhbin(self, fhbin)
            % EBCDIC text header
            fh.text_header = char(reshape(io.bcd2ascii(fhbin(1:3200)),80,40)');
            % Binary File Header (400 bytes)
            aaa = fhbin(3201:3600);
            % convert the format cell to a structure
            F = cell2struct(self.fh_format,{'format','start','end','field','default'},2);
            % loop over each field to interpret the trace header
            for m = 1:length(F)
                fh.(F(m).field) = typecast(aaa(F(m).start:F(m).end),F(m).format);
                fh.(F(m).field) = swapbytes(fh.(F(m).field));
                if ~strcmp(F(m).format,'int64'), fh.(F(m).field) = double(fh.(F(m).field)); end
            end
        end
        
        function th = interpret_thbin(self, thbin)
            % interprets a stream of trace header uint8 data into a Matlab structure
            % the foramt is defined by the th_format property
            
            ntr = size(thbin, 2);  % this is the number of traces to interpret, no the number of traces of the ifle
            F = cell2struct(self.th_format,{'format','start','end','field','default'},2);
            % loop over each field to interpret the trace header
            for m = 1:length(F)
                siz = F(m).end-F(m).start+1;
                th.(F(m).field) = typecast(reshape(thbin(F(m).start:F(m).end,:), [siz * ntr 1]), F(m).format);
                th.(F(m).field) = swapbytes(th.(F(m).field));
            end
            % Apply the coordinate scalar
            isca = ~(th.coordinate_scalar >= -1 & th.coordinate_scalar <= 1);
            for field= {'cdp_x', 'cdp_y', 'receiver_x', 'receiver_y', 'offset_x', 'offset_y', 'source_x', 'source_y'}
                if ~isfield(th, field{1}), continue, end
                th.(field{1})(isca) = double(th.(field{1})(isca)) ./ double(abs(th.coordinate_scalar(isca)));
            end
            % Apply the elevation scalar
            isca = ~(th.elevation_scalar >= -1 & th.elevation_scalar <= 1);
            for field= {'cdp_z', 'receiver_z', 'source_z'}
                if ~isfield(th, field{1}), continue, end
                th.(field{1})(isca) = double(th.(field{1})(isca)) ./ double(abs(th.elevation_scalar(isca)));
            end
        end
    end
    
    methods (Static)
        function fh_format = get_fh_format(fh_format, varargin)
            % fh_format = SegyWriter1.get_fh_format(sr, ns)
            % function that will merge custom words with default values for decoding
            if nargin ==0, fh_format = {}; end
            default_fh_format = io.SegyReader1.create_fh_format(varargin{:});
            fh_format  = io.SegyReader1.merge_format_cells(default_fh_format , fh_format);
        end
        
        function th_format= get_th_format(th_format, varargin)
            % fh_format = SegyWriter1.default_fh_format(sr, ns)
            % function that will merge custom words with default values for decoding
            if nargin ==0, th_format = {}; end
            default_th_format = io.SegyReader1.create_th_format(varargin{:});
            th_format  = io.SegyReader1.merge_format_cells(default_th_format , th_format);
        end
        
        function fh_format = create_fh_format(si, ns)
            % fh_format = SegyWriter1.default_fh_format(sr, ns)
            % gets the default format of the file header
            if nargin <= 1, si = 0; end
            if nargin <= 2, ns = 0; end
            
            fh_format = {...
                'int32',   01,  04, 'job', 1;...
                'int32',   05,  08, 'line', 1;...
                'int32',   09,  12, 'reel', 1;...
                'int16',   13,  14, 'data_trace_per_ensemble', 1;...
                'int16',   15,  16, 'auxiliary_trace_per_ensemble', 0;...
                'uint16',  17,  18, 'si', si * 1e6;...
                'uint16',  19,  20, 'si_original', si * 1e6;...
                'uint16',  21,  22, 'ns', ns;...
                'uint16',  23,  24, 'ns_original', ns;...
                'int16',   25,  26, 'data_sample_format', 5;... % 1:IBM Float32, 2INT32, 3INT16, 4: Exp 5:IEEE float32
                'int16',   27,  28, 'ensemble_fold', 1;...
                'int16',   29,  30, 'trace_sorting', 0;... % 0:Unknown, 1:As recorded, 2:CDP
                'int16',   31,  32, 'vertical_sum_code', 1;...
                'int16',   33,  34, 'sweep_frequency_start', 0;...
                'int16',   35,  36, 'sweep_frequency_end', 0;...
                'int16',   37,  38, 'sweep_length', 0;...
                'int16',   39,  40, 'sweep_type', 0;...
                'int16',   41,  42, 'sweep_channel', 0;...
                'int16',   43,  44, 'sweep_taper_length_start', 0;...
                'int16',   45,  46, 'sweep_taper_length_end', 0;...
                'int16',   47,  48, 'taper_type', 0;...
                'int16',   49,  50, 'correlated_data_traces', 0;... % 1:no, 2:yes
                'int16',   51,  52, 'binary_gain', 0;...
                'int16',   53,  54, 'ampitude_recovery_method', 0;...
                'int16',   55,  56, 'measurement_system', 2;... % 1:metric 2:feet
                'int16',   57,  58, 'impulse_signal_polarity', 0;...
                'int16',   59,  60, 'vibrator_polarity_code', 0;...
                'int16',  301, 302, 'segy_format_revision_number', 0;...
                'int16',  303, 304, 'fixed_length_trace_flag', 1;...
                'int16',  305, 306, 'number_of_textual_headers', 0;...
                };
        end
        
        function th_format = create_th_format(si, ns ,ntr)
            % th_format = SegyWriter1.create_th_format(sr, ns, ntr)
            % gets the default format of the trace header
            if nargin <= 0, si = 0; end
            if nargin <= 1, ns = 0; end
            if nargin <= 2, ntr = 1; end
            th_format  = {...
                'int32',    1,   4, 'trace_sequence_line', int32([1:ntr]');...
                'int32',    5,   8, 'trace_sequence_file', int32([1:ntr]');...
                'int32',    9,  12, 'ffid', 0;...
                'int32',   13,  16, 'trace_number', int32([1:ntr]');...
                'int32',   17,  20, 'energy_source_poind', 0;...
                'int32',   21,  24, 'cdp', 0;...
                'int32',   25,  28, 'trace_sequence_cdp', 0;...
                'int16',   29,  30, 'trace_id', 0;...
                'int16',   31,  32, 'vertical_stack', 0;...
                'int16',   33,  34, 'horizontal_stack', 0;...
                'int16',   35,  36, 'data_use', 0;...
                'int32',   37,  40, 'offset', 0;...
                'int32',   41,  44, 'receiver_z', 0;...
                'int32',   45,  48, 'source_z', 0;...
                'int32',   49,  52, 'source_depth', 0;...
                'int32',   53,  56, 'rcv_datum_elevation', 0;...
                'int32',   57,  60, 'source_datum_elevation', 0;...
                'int32',   61,  64, 'shot_water_depth', 0;...
                'int32',   65,  68, 'rcv_water_detph', 0;...
                'int16',   69,  70, 'elevation_scalar', 0;...
                'int16',   71,  72, 'coordinate_scalar', 0;...
                'int32',   73,  76, 'source_x', 0;...
                'int32',   77,  80, 'source_y', 0;...
                'int32',   81,  84, 'receiver_x', 0;...
                'int32',   85,  88, 'receiver_y', 0;...
                'int16',   89,  90, 'coordinate_units', 0;...
                'int16',   91,  92, 'weathering_velocity', 0;...
                'int16',   93,  94, 'subweathering_velocity', 0;...
                'int16',   95,  96, 'source_uphole_time', 0;...
                'int16',   97,  98, 'receiver_uphole_time', 0;...
                'int16',   99, 100, 'shot_static', 0;...
                'int16',  101, 102, 'receiver_static', 0;...
                'int16',  103, 104, 'total_static', 0;...
                'int16',  105, 106, 'lag_time_a', 0;...
                'int16',  107, 108, 'lag_time_b', 0;...
                'int16',  109, 110, 'delay_recording_time', 0;...
                'int16',  111, 112, 'mute_time_start', 0;...
                'int16',  113, 114, 'mute_time_end', 0;...
               'uint16',  115, 116, 'ns', ns;...
               'uint16',  117, 118, 'si', si * 1e6;...
                'int16',  119, 120, 'field_instrument_gain_type_code', 0;...
                'int16',  121, 122, 'instrument_gain_constant', 0;...
                'int16',  123, 124, 'instrument_initial_gain', 0;...
                'int16',  125, 126, 'correlated', 0;...
                'int16',  127, 128, 'sweep_frequency_start', 0;...
                'int16',  129, 130, 'sweep_frequency_end', 0;...
                'int16',  131, 132, 'sweep_length', 0;...
                'int16',  133, 134, 'sweep_type', 0;...
                'int16',  135, 136, 'sweep_taper_length_start', 0;...
                'int16',  137, 138, 'sweep_taper_length_end', 0;...
                'int16',  139, 140, 'taper_type', 0;...
                'int16',  141, 142, 'alias_filter_frequency', 0;...
                'int16',  143, 144, 'alias_filter_slope', 0;...
                'int16',  145, 146, 'notch_filter_frequency', 0;...
                'int16',  147, 148, 'notch_filter_slope', 0;...
                'int16',  149, 150, 'low_cut_frequency', 0;...
                'int16',  151, 152, 'high_cut_frequency', 0;...
                'int16',  153, 154, 'low_cut_slope', 0;...
                'int16',  155, 156, 'high_cut_slope', 0;...
                'int16',  157, 158, 'year', 0;...
                'int16',  159, 160, 'julian_day', 0;...
                'int16',  161, 162, 'hour', 0;...
                'int16',  163, 164, 'minute', 0;...
                'int16',  165, 166, 'second', 0;...
                'int16',  167, 168, 'time_basis', 0;...
                'int16',  169, 170, 'millisecond_of_second', 0;...
                'int16',  171, 172, 'geophone_group_number_roll', 0;...
                'int32',  173, 176, 'offset_x', 0;...
                'int32',  177, 180, 'offset_y', 0;...
                'int32',  181, 184, 'cdp_x', 0;...
                'int32',  185, 188, 'cdp_y', 0;...
                'int32',  189, 192, 'inline', 0;...
                'int32',  193, 196, 'crossline', 0;...
                'int32',  197, 200, 'shot_point', 0;...
                'int16',  201, 202, 'shot_point_scalar', 0;...
                'int16',  203, 204, 'trace_value_measurement_unit', 0;...
                'int32',  205, 208, 'transduction_constant_mantissa', 0;...
                'int16',  209, 210, 'transduction_constant_power', 0;...
                'int16',  211, 212, 'transduction_unit', 0;...
                'int16',  213, 214, 'trace_identifier', 0;...
                'int16',  215, 216, 'scalar_trace_header', 0;...
               'single',  217, 220, 'lw_static', 0;...
                'int32',  221, 224, 'cdp_z', 0;...
                'int32',  225, 228, 'source_measurement_mantissa', 0;...
                'int16',  229, 230, 'source_measurement_exponent', 0;...
                'int16',  231, 232, 'source_measurement_unit', 0;...
                'int32',  233, 236, 'azimuth', 0;...
                'int32',  237, 240, 'unassigned_int', 0;...
                };
        end
        
        function default_format = merge_format_cells(default_format, format)
            % io.SegyReader.merge_format_celles(default_fh_format, fh_format)
            if isempty(format), return, end
            rm = logical(length(default_format) * 0);
            % remove potentially overlapping fields
            ind = cell2mat(format(:,2:3));
            default_ind = cell2mat(default_format(:,2:3));
            for m = 1:size(ind,1)
                rm = rm | ((default_ind(:,1) <= ind(m,1)) & (default_ind(:,2) >= ind(m,1))) |...
                    ((default_ind(:,1) <= ind(m,2)) & (default_ind(:,2) >= ind(m,2)));
            end
            default_format = cat(1, default_format(~rm,:), format);
            % remove duplicate labels - by default we keep the last ones
            [~, iu] = unique(default_format(:, 4), 'last');
            default_format = default_format(iu, :);
            % sort by the first byte to read
            [~, ordre] = sort(cell2mat(default_format(:, 2)));
            default_format = default_format(ordre, :);
        end
    end
end