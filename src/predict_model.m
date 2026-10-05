function pred = predict_model(model,X)
switch model.kind
    case 'mean'
        pred = repmat(model.value,size(X,1),1);
    case 'ridge'
        pred = [ones(size(X,1),1),X]*model.beta;
    case 'knn'
        pred = zeros(size(X,1),size(model.y,2));
        for i = 1:size(X,1)
            dist = sum(bsxfun(@minus,model.X,X(i,:)).^2,2);
            [~,idx] = sort(dist); pred(i,:) = mean(model.y(idx(1:model.k),:),1);
        end
    case 'mlp'
        [~,~,pred] = mlp_loss(model.theta,X,zeros(size(X,1),model.outputs),model.hidden,0);
    case 'random_nn'
        H = tanh(bsxfun(@plus,X*model.W,model.b));
        if model.direct, A = [ones(size(X,1),1),X,H]; else, A = [ones(size(X,1),1),H]; end
        pred = A*model.beta;
    case 'fnn'
        pred = fnn_design(model,X)*model.beta;
    case 'fuzzy_rvfl'
        [~,w] = fnn_design(model,X);
        H = tanh(bsxfun(@plus,X*model.W,model.b));
        pred = [ones(size(X,1),1),X,w,H]*model.beta;
    otherwise
        error('Unknown model kind: %s',model.kind);
end
end
