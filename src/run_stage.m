function results = run_stage(stage,cfg,names)
% Identical saved splits across lessons and languages.
root = fileparts(fileparts(mfilename('fullpath')));
if ~isfield(cfg,'save_results'),cfg.save_results=true;end
if ~isfield(cfg,'show_figures'),cfg.show_figures=true;end
if ~isfield(cfg,'output_dir'),cfg.output_dir='';end
if nargin<3,names=stage_models(stage);end
allowed=stage_models(stage);
assert(~isempty(names) && all(ismember(names,allowed)),'Invalid model selection.');
assert(numel(unique(names))==numel(names),'Duplicate model selection.');
if isempty(cfg.output_dir)
    outdir = fullfile(root,'results',cfg.profile,sprintf('stage_%d',stage));
else
    outdir = fullfile(cfg.output_dir,sprintf('stage_%d',stage));
end
if cfg.save_results && ~exist(outdir,'dir'), mkdir(outdir); end
plot_enabled=cfg.plots;
results = [];
for target = 1:numel(cfg.examples)
    ex=cfg.examples(target);
    data = prepare_data(ex.csv_path,ex.feature_columns,ex.target_column,cfg.split_seed,ex.categorical_columns,ex.task,ex.split_file);
    for seed = cfg.seeds
        predictions=cell(1,numel(names));
        initial = init_fnn(data.Xtrain,cfg.rules,1,seed);
        for j = 1:numel(names)
            name = names{j}; history = []; search = []; calls = 0; tic;
            switch name
                case 'Mean'
                    model = struct('kind','mean','value',mean(data.ytrain,1));
                case 'Ridge'
                    model.kind = 'ridge';
                    model.beta = ridge_solve([ones(size(data.Xtrain,1),1),data.Xtrain],data.ytrain,cfg.lambda);
                case 'kNN'
                    model.kind = 'knn'; model.X = data.Xtrain; model.y = data.ytrain; model.k = 5;
                case 'MLP'
                    [model,history] = train_mlp(data.Xtrain,data.ytrain,data.Xval,data.yval,cfg,seed);
                case {'ELM','RVFL'}
                    model = train_random_nn(data.Xtrain,data.ytrain,cfg.hidden,cfg.lambda,seed,strcmp(name,'RVFL'));
                case 'Fixed-TSK1'
                    model = initial; model.beta = ridge_solve(fnn_design(model,data.Xtrain),data.ytrain,cfg.lambda);
                case 'Adaptive-TSK0'
                    base = initial; base.order = 0;
                    [model,history] = train_fnn(base,data.Xtrain,data.ytrain,data.Xval,data.yval,cfg);
                case 'ANFIS'
                    [model,history] = train_fnn(initial,data.Xtrain,data.ytrain,data.Xval,data.yval,cfg);
                case 'Fuzzy-RVFL'
                    model = train_fuzzy_rvfl(initial,data.Xtrain,data.ytrain,cfg,seed);
                case {'FNN-GA','FNN-PSO'}
                    if strcmp(name,'FNN-GA'), optimizer=@optimizer_ga; else, optimizer=@optimizer_pso; end
                    [model,search] = train_meta_fnn(initial,data.Xtrain,data.ytrain,data.Xval,data.yval,cfg,seed,optimizer);
                    calls = search.evals; history = search.history;
            end
            elapsed = toc;
            % Evaluate held-out test only AFTER all parameter selection is complete.
            pred = predict_model(model,data.Xtest)*data.ystd+data.ymean;
            predictions{j}=pred;
            metrics=struct('rmse',NaN,'mae',NaN,'r2',NaN);
            classmetrics=struct('accuracy',NaN,'macro_f1',NaN,'balanced_accuracy',NaN);
            if strcmp(data.task,'classification')
                classmetrics=classification_metrics(data.ytest,pred,data.classes);
            else
                metrics=regression_metrics(data.ytest,pred);
            end
            train_rmse = rmse_all(predict_model(model,data.Xtrain),data.ytrain)*data.ystd;
            val_rmse = rmse_all(predict_model(model,data.Xval),data.yval)*data.ystd;
            r = struct('stage',stage,'target',ex.name,'model',name,'seed',seed, ...
                'split_seed',cfg.split_seed,'train_rmse',train_rmse,'val_rmse',val_rmse, ...
                'test_rmse',metrics.rmse,'test_mae',metrics.mae,'test_r2',metrics.r2, ...
                'accuracy',classmetrics.accuracy,'macro_f1',classmetrics.macro_f1, ...
                'balanced_accuracy',classmetrics.balanced_accuracy,'seconds',elapsed,'fitness_evals',calls);
            results = [results;r]; %#ok<AGROW>
            stem = sprintf('%s_%s_seed%d',ex.name,name,seed);
            if cfg.save_results
                save(fullfile(outdir,[stem '.mat']),'model','cfg','data','history','search','pred','r','classmetrics','-v7');
            end
            if plot_enabled
                try
                    save_run_plot(fullfile(outdir,stem),data.ytest,pred,history,name,~isempty(search),data,cfg);
                catch plot_error
                    warning('course:graphics','Figure display/export failed: %s',plot_error.message);
                    plot_enabled=false;
                end
            end
            fprintf('%s %-14s seed=%d RMSE=%.4f accuracy=%.4f macroF1=%.4f (%.2fs)\n', ...
                ex.name,name,seed,metrics.rmse,classmetrics.accuracy,classmetrics.macro_f1,elapsed);
            clear model;
        end
        if cfg.plots && numel(names)>1
            plot_model_comparison(data,predictions,names,ex.name,seed,cfg,outdir);
        end
    end
end
if cfg.save_results
    write_results(fullfile(outdir,'metrics.csv'),results);
    save(fullfile(outdir,'summary.mat'),'results','cfg','-v7');
end
show_results_table(results,cfg,outdir);
end
