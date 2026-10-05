function test_six_datasets()
root=setup_course();cfg=course_config('smoke');cfg.save_results=false;
assert(sum(strcmp({cfg.examples.task},'regression'))==3);
assert(sum(strcmp({cfg.examples.task},'classification'))==3);
expected=[768 178 1503 308 210 208];features=[8 13 5 6 7 60];
for i=1:6
    ex=cfg.examples(i);raw=dlmread(ex.csv_path,',',1,0);
    assert(size(raw,1)==expected(i));assert(numel(ex.feature_columns)==features(i));
    assert(all(isfinite(raw(:))));
    d=prepare_data(ex.csv_path,ex.feature_columns,ex.target_column,42,ex.categorical_columns,ex.task,ex.split_file);
    ids=[d.train_idx d.val_idx d.test_idx];assert(isequal(sort(ids),1:expected(i)));
    assert(max(abs(mean(d.Xtrain,1)))<1e-9);
    if strcmp(ex.task,'classification')
        assert(all(ismember(unique(d.ytest),d.classes)));
    end
end
r=run_stage(0,cfg);assert(numel(r)==72);
for i=1:numel(r)
    assert(isfinite(r(i).val_rmse));
    if strcmp(cfg.examples(strcmp({cfg.examples.name},r(i).target)).task,'regression')
        assert(isfinite(r(i).test_rmse));
    else
        assert(isfinite(r(i).accuracy)&&r(i).accuracy>=0&&r(i).accuracy<=1);
    end
end
fprintf('SIX DATASETS PASS: 72 model/dataset combinations, fixed splits, finite metrics.\n');
end
