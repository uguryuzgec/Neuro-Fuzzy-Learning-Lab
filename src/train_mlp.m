function [model, history] = train_mlp(X,y,Xval,yval,cfg,seed)
rng(seed,'twister'); d = size(X,2); h = cfg.hidden;
W = randn(d,h)*sqrt(2/(d+h));
outputs=size(y,2); V=randn(h,outputs)/sqrt(h);
theta = [W(:); zeros(h,1); V(:); zeros(outputs,1)];
state = []; best = Inf; stale = 0;
history = zeros(cfg.epochs,2);
for epoch = 1:cfg.epochs
    [~,g] = mlp_loss(theta,X,y,h,cfg.lambda);
    [theta,state] = adam_update(theta,g,state,cfg.learning_rate);
    [~,~,pt] = mlp_loss(theta,X,y,h,cfg.lambda);
    [~,~,pv] = mlp_loss(theta,Xval,yval,h,cfg.lambda);
    history(epoch,:) = [rmse_all(pt,y),rmse_all(pv,yval)];
    if history(epoch,2) < best
        best = history(epoch,2); best_theta = theta; stale = 0;
        best_epoch = epoch;
    else
        stale = stale+1;
    end
    if stale >= cfg.patience, break; end
end
history = history(1:epoch,:);
model.kind = 'mlp'; model.theta = best_theta; model.hidden = h;
model.best_epoch = best_epoch; model.outputs = outputs;
end
