function model = train_fuzzy_rvfl(initial,X,y,cfg,seed)
% Teaching variant: [1, X, normalized fuzzy firing, random tanh features].
% Fixed premises; do not claim an exact reproduction of a named paper.
model = initial; model.kind = 'fuzzy_rvfl';
rng(seed,'twister');
model.W = randn(size(X,2),cfg.hidden)/sqrt(size(X,2));
model.b = 2*rand(1,cfg.hidden)-1;
[~,w] = fnn_design(model,X);
H = tanh(bsxfun(@plus,X*model.W,model.b));
model.beta = ridge_solve([ones(size(X,1),1),X,w,H],y,cfg.lambda);
end
