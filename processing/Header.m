classdef Header < double
    % H = Header.create(200);
    % H = header(..., 'si', 0.002, 'offset', linspace(0, 500, 50))
    %
    % Provides array like and structure like array functionalities
    % H will behave like a double array and can be concatenated an sliced as such
    %
    % Getting data:
    % offset = H(20, 2:5);
    % is equivalent to
    % offset = H.offset(2:5);
    %
    % Setting data:
    % H(20, :) = offset;
    % is equivalent to
    % H = H.set('offset', offset);
    %
    
    methods
        function obj = Header(data)
            obj = obj@double(data);
        end
        
        function off = offset(obj, varargin)
            if isempty(varargin), varargin = {':'}; end
            off = obj(20, varargin{:});
        end
        
        function obj = set(obj, attribute, value)
            keys = Header.keywords;
            ff = fields(keys);
            ind = find(cellfun(@(x) strcmpi(x, attribute), ff));
            if isempty(ind), return, end
            obj(keys.(ff{ind}).index, :) = value;
        end
        
        function write_parquet_header(obj, file_parquet)
            % obj.write_parquet(file_parquet) 
            % writes non-zeros rows to parquet with a generic header
            ih = find(all(obj' ~= 0));
            t = array2table(double(obj(ih, :)).', 'VariableNames', arrayfun(@(x) num2str(x, 'h%02.0f'), ih, 'UniformOutput', false));
            parquetwrite(file_parquet, t)
        end
    end
    
    methods (Static)
        function header = create(ntr, varargin)
            % header = create(ntr, 'si', 0.002, 'offset', offset_vector)
            p=inputParser;
            fcn_validate = @(x) isscalar(x) || numel(x) == prod(ntr);
            p.addParameter('si', 0.002, fcn_validate);
            p.addParameter('offset', 0, fcn_validate);
            p.parse(varargin{:}) ; field = fieldnames(p.Results) ;
            for r = 1 : length(field), eval([field{r} '= p.Results.(field{r}) ; ']) ; end
            H = zeros(64, ntr, 'single');
            H(20, :) = offset;
            H( 9, :) = si .* 1e6;
            header = Header(H);
        end
        
        function key = keywords
            % default keywords
            key.shot_number = struct('index', 2, 'help_string', '');
            key.crossline = struct('index', 4, 'help_string', '');
            key.si_us = struct('index', 9, 'help_string', 'Sampling rate in microseconds');
            key.receiver_number = struct('index', 18, 'help_string', '');
            key.inline = struct('index', 19, 'help_string', '');
            key.offset = struct('index', 20, 'help_string', '');
            key.sensor_type = struct('index', 28, 'help_string', '1: hydrophone, 2/3/4: z,x,y geophones, 6/7/8: z, x,y accelerometers');
            key.receiver_line = struct('index', 36, 'help_string', '');
            key.shot_line = struct('index', 37, 'help_string', '');
            key.cdp_x = struct('index', 43, 'help_string', '');
            key.cdp_y = struct('index', 44, 'help_string', '');
            key.receiver_z = struct('index', 52, 'help_string', '');
            key.source_z = struct('index', 53, 'help_string', '');
            key.receiver_x = struct('index', 60, 'help_string', '');
            key.receiver_y = struct('index', 61, 'help_string', '');
            key.shot_x = struct('index', 62, 'help_string', '');
            key.shot_y = struct('index', 63, 'help_string', '');
        end
        
        function s = help
            % List of keywords / indices combinations:
            keys = Header.keywords;
            ff = fields(keys);
            for n = 1:length(ff)
                disp([num2str(keys.(ff{n}).index, '%02.0f') ' ' ff{n} ' ' keys.(ff{n}).help_string])
            end
            disp('')
        end
        
        function h = read_parquet_header(parquet_file)
            % Header.read_parquet_header(parquet_file)
            % reads in a parquet table as header. Each parquet name has a hXX format, where XX is the header row
            % empty header row are not represented. See Header.write_parquet_header method
            t = parquetread(parquet_file);
            ntr = size(t, 1);
            h = Header(zeros(64, ntr));
            ih = cellfun(@(x) str2num(x(2:end)), t.Properties.VariableNames);
            h(ih, :) = table2array(t).';            
        end
    end
end
