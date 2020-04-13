function r = bcd2dec(binarray)
% 4bits, 8bits, 12 bits, 16 bits, 24 bits

bcd2dec_ = [0;1;2;3;4;5;6;7;8;9;NaN;NaN;NaN;NaN;NaN;NaN;10;11;12;13;14;15;...
    16;17;18;19;NaN;NaN;NaN;NaN;NaN;NaN;20;21;22;23;24;25;26;27;28;29;...
    NaN;NaN;NaN;NaN;NaN;NaN;30;31;32;33;34;35;36;37;38;39;NaN;NaN;NaN;NaN;NaN;NaN;...
    40;41;42;43;44;45;46;47;48;49;NaN;NaN;NaN;NaN;NaN;NaN;50;51;52;53;54;55;56;57;58;59;...
    NaN;NaN;NaN;NaN;NaN;NaN;60;61;62;63;64;65;66;67;68;69;NaN;NaN;NaN;NaN;NaN;NaN;...
    70;71;72;73;74;75;76;77;78;79;NaN;NaN;NaN;NaN;NaN;NaN;80;81;82;83;84;85;86;87;88;89;...
    NaN;NaN;NaN;NaN;NaN;NaN;90;91;92;93;94;95;96;97;98;99;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;...
    NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;...
    NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;...
    NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;...
    NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;...
    NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN;NaN];

dims = size(binarray);
switch true
    case (isscalar(binarray) && binarray < 256) || isa(binarray, 'uint8') || isa(binarray, 'int8')
        % for a single byte it's a straight lookup
        
        r = bcd2dec_(binarray(:) + 1);
    case (isscalar(binarray) && binarray < 256^2) || isa(binarray, 'uint16') || isa(binarray, 'int16')
        % for uint16, 2 lookups
        r = bcdconv_nbytes(uint16(binarray), 2);
    otherwise
        % otherwise cast to uint32 by default
        r = bcdconv_nbytes(uint32(binarray), 4);
end
r = reshape(r, dims);


    function r = bcdconv_nbytes(binarray, N)
        % typecast to uint8, convert to bcd individual bytes and reconstruct decimal by matrix mult
        r = reshape(typecast(binarray(:), 'uint8'), N, numel(binarray));
        r = (10 .^ [(0 : (N - 1)) * 2]) * bcd2dec_(r + 1);
    end
end
