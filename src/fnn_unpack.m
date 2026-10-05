function model = fnn_unpack(theta,model)
k = numel(model.C); assert(numel(theta)==2*k);
model.C = reshape(theta(1:k),size(model.C));
model.logS = reshape(theta(k+1:end),size(model.logS));
end
