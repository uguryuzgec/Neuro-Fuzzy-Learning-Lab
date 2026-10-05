function [model,history] = train_fnn(initial,X,y,Xval,yval,cfg)
% Hybrid learning: ridge consequent solve + Adam premise gradient.
model = initial; [lo,hi] = fnn_bounds(model,X); state = [];
best = Inf; stale = 0; history = zeros(cfg.epochs+1,2);
for epoch = 0:cfg.epochs
    model.beta = ridge_solve(fnn_design(model,X),y,cfg.lambda);
    pt = predict_model(model,X); pv = predict_model(model,Xval);
    history(epoch+1,:) = [rmse_all(pt,y),rmse_all(pv,yval)];
    if history(epoch+1,2) < best
        best = history(epoch+1,2); best_model = model; stale = 0;
        best_model.best_epoch = epoch;
    else
        stale = stale+1;
    end
    if stale >= cfg.patience || epoch == cfg.epochs, break; end
    [~,grad] = fnn_gradient(model,X,y,cfg.lambda);
    [theta,state] = adam_update(fnn_pack(model),grad,state,cfg.learning_rate);
    model = fnn_unpack(min(max(theta,lo),hi),model);
end
history = history(1:epoch+1,:); model = best_model;
end
