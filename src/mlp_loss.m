function [loss, gradient, pred] = mlp_loss(theta, X, y, hidden, lambda)
% Tanh hidden layer, linear outputs; one-hot least squares classification.
d = size(X,2); k = d*hidden; outputs = size(y,2);
W = reshape(theta(1:k),d,hidden);
b = theta(k+(1:hidden))';
v = reshape(theta(k+hidden+(1:hidden*outputs)),hidden,outputs);
c = theta(k+hidden+hidden*outputs+(1:outputs))';
H = tanh(bsxfun(@plus,X*W,b)); pred = bsxfun(@plus,H*v,c);
err = pred-y; n = size(X,1);
loss = mean(err(:).^2)+lambda*(sum(W(:).^2)+sum(v(:).^2));
delta = 2*err/numel(y);
gH = (delta*v').*(1-H.^2);
gW = X'*gH+2*lambda*W;
gb = sum(gH,1)'; gv = H'*delta+2*lambda*v; gc = sum(delta,1)';
gradient = [gW(:); gb; gv(:); gc];
end
