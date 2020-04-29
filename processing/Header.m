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
    % List of keywords / indices combinations:
    % H( 2, :) shot_number
    % H( 4, :) crossline
    % H( 9, :) si_us
    % H(18, :) receiver_number
    % H(19, :) inline
    % H(20, :) offset
    % H(36, :) receiver_line
    % H(37, :) shot_line
    % H(43, :) cdp_x
    % H(44, :) cdp_y
    % H(60, :) shot_x
    % H(61, :) shot_y
    % H(62, :) receiver_x
    % H(63, :) receiver_y
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
           switch attribute
               case 'offset', word = 20;
           end
            obj(word, :) = value;
        end
        
    end
    
    methods (Static)
        function header = create(ntr, varargin)
            % Inputs
            p=inputParser;
            fcn_validate = @(x) isscalar(x) || prod(size(x)) == prod(ntr);
            p.addParameter('si', 0.002, fcn_validate);
            p.addParameter('offset', 0.002, fcn_validate);
            p.parse(varargin{:}) ; field = fieldnames(p.Results) ;
            for r = 1 : length(field), eval([field{r} '= p.Results.(field{r}) ; ']) ; end
            H = zeros(64, ntr, 'single');
            H(20, :) = offset;
            H( 9, :) = si .* 1e6;            
            header = Header(H);
        end
    end
end
