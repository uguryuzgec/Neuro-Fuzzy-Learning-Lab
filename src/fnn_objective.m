function cost = fnn_objective(theta,initial,Xtrain,ytrain,Xval,yval,lambda)
% This interface deliberately cannot access test data.
% Each candidate fits consequent weights ONLY to training targets.
model = fnn_unpack(theta,initial);
model.beta = ridge_solve(fnn_design(model,Xtrain),ytrain,lambda);
pred = predict_model(model,Xval);
cost = rmse_all(pred,yval); % validation RMSE, standardized y
end
