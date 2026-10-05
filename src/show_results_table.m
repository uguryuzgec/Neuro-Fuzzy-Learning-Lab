function show_results_table(results,cfg,outdir)
% Separate tables for each task; preserve every seed instead of pooling rows.
targets=unique({results.target});
for t=1:numel(targets)
    rows=results(strcmp({results.target},targets{t}));
    isclass=~isnan(rows(1).accuracy);
    if isclass
        headers={'Model','Seed','Accuracy %','Macro-F1','Bal. acc. %','Sure (s)'};
        values=[[rows.accuracy]'*100,[rows.macro_f1]',[rows.balanced_accuracy]'*100,[rows.seconds]'];
    else
        headers={'Model','Seed','Test RMSE','Test MAE','Test R2','Sure (s)'};
        values=[[rows.test_rmse]',[rows.test_mae]',[rows.test_r2]',[rows.seconds]'];
    end
    fprintf('\n%s -- TEST KARSILASTIRMASI\n',targets{t});
    fprintf('%-18s %5s %13s %13s %13s %12s\n',headers{:});
    for i=1:numel(rows)
        fprintf('%-18s %5d %13.4f %13.4f %13.4f %12.3f\n',rows(i).model,rows(i).seed,values(i,:));
    end
end
end

