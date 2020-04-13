function ts = padding_tapering(ts, si, padding, taper, forward)
% apply / remove taper at the start and end of time serie - first dimension
% to apply tapering + padding:
% ts = padding_tapering(ts, 1, 0.5, True)
% to remove padding:
% ts = padding_tapering(ts, 1, 0.5, True)
npad = round(padding / si);

if forward
    % apply mirror padding at the beginning + tapering
    if padding > 0
        ts = [ts(npad:-1:2, :); ts(:,:); ts(end-1:-1:end-npad+1,:)];
    end
    % apply taper in / taper out
    if taper > 0
        ntap = round(taper / si);
        ts(1:npad, :) = bsxfun(@times, ts(1:npad, :), dsp.window.cosine(npad)); % taper in
        ts(end-npad+1:end, :) = bsxfun(@times, ts(end-npad+1:end, :), 1 - dsp.window.cosine(npad)); % taper in
    end
else	% remove the padding if any
    if padding > 0
        ts = ts(npad:end-(npad-1), :);
    end
end