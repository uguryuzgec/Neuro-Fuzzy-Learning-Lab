function write_results(path,results)
fid = fopen(path,'w'); assert(fid>=0); cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'stage,target,model,seed,split_seed,train_rmse,val_rmse,test_rmse,test_mae,test_r2,accuracy,macro_f1,balanced_accuracy,seconds,fitness_evals\n');
for i = 1:numel(results)
    r = results(i);
    fprintf(fid,'%d,%s,%s,%d,%d,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.10g,%.6g,%d\n', ...
        r.stage,r.target,r.model,r.seed,r.split_seed,r.train_rmse,r.val_rmse, ...
        r.test_rmse,r.test_mae,r.test_r2,r.accuracy,r.macro_f1,r.balanced_accuracy,r.seconds,r.fitness_evals);
end
end
