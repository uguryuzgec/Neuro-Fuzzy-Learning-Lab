function [model,search] = train_meta_fnn(initial,X,y,Xval,yval,cfg,seed,optimizer)
% Add a new heuristic by passing @optimizer_xx with the same function contract.
[lo,hi] = fnn_bounds(initial,X);
objective = @(theta) fnn_objective(theta,initial,X,y,Xval,yval,cfg.lambda);
opts.population = cfg.population; opts.max_evals = cfg.max_evals; opts.seed = seed;
search = optimizer(objective,lo,hi,fnn_pack(initial),opts);
assert(search.evals==cfg.max_evals, 'Optimizer must honor the exact budget.');
assert(all(search.best_position>=lo & search.best_position<=hi));
model = fnn_unpack(search.best_position,initial);
% Reconstruct winning model; this is a training solve, not another fitness call.
model.beta = ridge_solve(fnn_design(model,X),y,cfg.lambda);
end
