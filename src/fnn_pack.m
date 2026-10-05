function theta = fnn_pack(model)
theta = [model.C(:);model.logS(:)];
end
