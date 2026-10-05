function beta = ridge_solve(A, y, lambda)
% Augmented least squares (QR), no explicit inverse or toolbox.
% All coefficients are penalized, including bias, consistently across models.
assert(lambda > 0, 'Use positive ridge regularization.');
p = size(A,2); n = size(A,1);
beta = [A; sqrt(n*lambda)*eye(p)] \ [y; zeros(p,size(y,2))];
end
