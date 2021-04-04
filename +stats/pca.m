function Z = pca(X, k)
% stats.pca(X,k)
% simple principal component analysis
% X : feature matrix, X(nsamples, nfeatures)
% k : if k >= 1 number of features to keep 
%     if k < 1: threshold on the sum of singular values to retain

% replace NaN's and Inf by 0s
iok = ~isnan(X) & ~isinf(X);
X(~iok) = 0;
% compute the covariance matrix without the NaN's
Q = bsxfun( @minus, X , sum(X) ./ sum(iok) );
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
Z = X * U_;
