function [loss, gradient] = fnn_gradient(model,X,y,lambda)
% Premise gradient with consequent beta held fixed (ANFIS backward pass).
[A,w,B] = fnn_design(model,X); pred = A*model.beta;
err = pred-y;
% Sum output losses / N; matches ridge_solve's N*lambda penalty.
loss = sum(err(:).^2)/size(X,1)+lambda*sum(model.beta(:).^2);
q=zeros(size(w));
for c=1:size(y,2)
    local_pred = B*reshape(model.beta(:,c),size(B,2),model.rules);
    q=q+bsxfun(@times,2*err(:,c)/size(X,1),w.*bsxfun(@minus,local_pred,pred(:,c)));
end
gc = zeros(size(model.C)); gs = gc;
for r = 1:model.rules
    diff = bsxfun(@minus,X,model.C(r,:)); s2 = exp(2*model.logS(r,:));
    gc(r,:) = sum(bsxfun(@times,bsxfun(@rdivide,diff,s2),q(:,r)),1);
    gs(r,:) = sum(bsxfun(@times,bsxfun(@rdivide,diff.^2,s2),q(:,r)),1);
end
gradient = [gc(:);gs(:)];
end
