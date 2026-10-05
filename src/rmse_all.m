function value = rmse_all(pred,y)
e=pred-y; value=sqrt(mean(e(:).^2));
end
