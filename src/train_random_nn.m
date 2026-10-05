function model = train_random_nn(X,y,hidden,lambda,seed,direct)
% ELM: random fixed hidden weights. RVFL additionally has input-output links.
rng(seed,'twister');
model.kind = 'random_nn'; model.W = randn(size(X,2),hidden)/sqrt(size(X,2));
model.b = 2*rand(1,hidden)-1; model.direct = direct;
H = tanh(bsxfun(@plus,X*model.W,model.b));
if direct, A = [ones(size(X,1),1),X,H]; else, A = [ones(size(X,1),1),H]; end
model.beta = ridge_solve(A,y,lambda);
end
