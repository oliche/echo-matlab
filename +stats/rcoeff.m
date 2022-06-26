function r = rcoeff(x, y)
%     Computes pairwise Person correlation coefficients for matrices.
%     That is for 2 matrices the same size, computes the row to row coefficients and outputs
%     a vector corresponding to the number of rows of the first matrix
%     If the second array is a vector then computes the correlation coefficient for all rows
%     :param x: np array [nc, ns]
%     :param y: np array [nc, ns] or [ns]
%     :return: r [nc]

    xnorm = x - nanmean(x);
    ynorm = y - nanmean(y);
    r = nansum(xnorm .* ynorm) ./ sqrt(nansum(xnorm .^2) .* nansum(ynorm .^ 2));
end
