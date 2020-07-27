classdef time
    % Container of static methods to convert seismic times.
    % epoch: time in us since 01-Jan-1970, minus leap seconds, (uint64 / int64)
    % posix: time in secs since 01=Jan-1970, minus leap seconds, (double)
    % gps: time in us since 06-Jan-1980, minus leap seconds, (uint64 / int64)
    % serial: Matlab time representation (double)
    %
    %
    % serial = time.gps2serial(gps);
    % serial = time.fh2serial(fh);  % from a segd file header with year, julian day, hour, minute, second
    
    
    methods (Static)
        function serial = gps2serial(gps)
            serial = double(gps) ./ 1e6 ./ 86400 + datenum([1980 1 6]);
            serial = serial + time.leap_seconds(serial) / 86400;
        end
        
        function serial = fh2serial(fh)
            % from a segd file header
            if fh.year >= 70, cent = 1900; else cent = 2000; end
            serial = datenum([cent + fh.year 1 1 fh.hour fh.minute fh.second]) + fh.julian_day - 1;
        end
        
        function posix = epoch2posix(epoch)
            posix = double(epoch) ./ 1e6;
        end
        
        function serial = epoch2serial(epoch)
            serial = double(epoch) ./ 1e6 ./ 86400 + datenum([1970 1 1]);
        end
        
        function serial = posix2serial(posix)
            serial = posix ./ 86400 + datenum([1970 1 1]);
        end
        
        function secs = leap_seconds(serial)
            % returns the number of leap seconds at a given time
            leaps = [732678 ; 733774 ; 735051 ; 736146 ; 736696]';
            % leaps = datenum(  [ 2006 1 1 ; 2009 1 1 ; 2012 7 1 ; 2015 7 1 ; 2017 1 1]);
            secs = -13 - sum(bsxfun(@ge, serial, leaps),2);
        end
        
    end
end

