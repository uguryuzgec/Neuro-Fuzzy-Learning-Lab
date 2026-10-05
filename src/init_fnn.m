function model = init_fnn(X, rules, order, seed)
% Sparse rule base: one Gaussian per input PER RULE (no Cartesian explosion).
% Simple Lloyd clustering written here to avoid the statistics toolbox.
assert(rules >= 1 && rules <= size(X,1));
rng(seed,'twister'); idx = randperm(size(X,1)); C = X(idx(1:rules),:);
for it = 1:20
    dist = zeros(size(X,1),rules);
    for r = 1:rules, dist(:,r) = sum(bsxfun(@minus,X,C(r,:)).^2,2); end
    [~,labels] = min(dist,[],2); old = C;
    for r = 1:rules
        members = X(labels==r,:);
        if ~isempty(members), C(r,:) = mean(members,1); end
    end
    if max(abs(C(:)-old(:))) < 1e-8, break; end
end
sigma = repmat(max(std(X,0,1),0.5),rules,1);
model.kind = 'fnn'; model.C = C; model.logS = log(sigma);
model.order = order; model.beta = []; model.rules = rules;
end
