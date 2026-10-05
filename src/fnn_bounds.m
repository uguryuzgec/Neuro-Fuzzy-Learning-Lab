function [lower,upper] = fnn_bounds(model,X)
% Bound centers in standardized training domain; sigma in [0.15, 3].
lo = repmat(min(X,[],1)-0.5,model.rules,1);
hi = repmat(max(X,[],1)+0.5,model.rules,1);
k = numel(lo);
lower = [lo(:);log(0.15)*ones(k,1)];
upper = [hi(:);log(3)*ones(k,1)];
end
