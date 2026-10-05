function [A, weights, local_inputs] = fnn_design(model,X)
% mu_rj=exp(-0.5*((x_j-c_rj)/sigma_rj)^2), product t-norm.
% Normalize in log space to avoid all-zero rule firing underflow.
n = size(X,1); R = model.rules; logs = zeros(n,R);
for r = 1:R
    z = bsxfun(@rdivide,bsxfun(@minus,X,model.C(r,:)),exp(model.logS(r,:)));
    logs(:,r) = -0.5*sum(z.^2,2);
end
logs = bsxfun(@minus,logs,max(logs,[],2)); weights = exp(logs);
weights = bsxfun(@rdivide,weights,sum(weights,2));
if model.order == 0, local_inputs = ones(n,1); else, local_inputs = [ones(n,1),X]; end
p = size(local_inputs,2); A = zeros(n,R*p);
for r = 1:R
    A(:,(r-1)*p+(1:p)) = bsxfun(@times,local_inputs,weights(:,r));
end
end
