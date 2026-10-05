function metrics = regression_metrics(y, pred)
assert(isequal(size(y),size(pred)) && all(isfinite(pred)));
e = pred-y;
metrics.rmse = sqrt(mean(e.^2));
metrics.mae = mean(abs(e));
den = sum((y-mean(y)).^2);
if den < eps, metrics.r2 = NaN; else, metrics.r2 = 1-sum(e.^2)/den; end
end
