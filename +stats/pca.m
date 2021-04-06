function [Z, fcn_forward, fcn_inverse] = pca(X, k)
% [Z, U_] = stats.pca(X,k)
% dimensionality reduction using principal component analysis
% X : feature matrix, X(nsamples, nfeatures)
% k : if k >= 1 number of features to keep 
%     if k < 1: threshold on the sum of singular values to retain

% replace NaN's and Inf by 0s
iok = ~isnan(X) & ~isinf(X);
X(~iok) = 0;
% compute the covariance matrix without the NaN's
xmean = sum(X) ./ sum(iok);
Q = bsxfun( @minus, X , xmean);
Q(~iok) = 0;
covX = (Q' * Q)./  ( double(iok') * double(iok) -1);
% singular value decomposition
[U, S, V]  = svd(covX);

if nargin == 1, k = 0.8; end % threshold at 80% defaults

if k < 1 % threshold technique of the diagonal of S (singular values)
    thresh = 0.8;
    ev = cumsum(diag(S) ./ sum(diag(S)));
    k = find(ev > thresh ,1,'first');
end

U_ = U(:,1:k);

fcn_inverse = @(z) z * pinv(U_) + xmean;
fcn_forward = @(x) (x - xmean) * U_;

Z = fcn_forward(X);
