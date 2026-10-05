function run_student(optimizer,cfg)
% Example: run_student(@optimizer_xx_template,course_config('classroom'))
% A working demonstration: run_student(@optimizer_pso)
setup_course();
if nargin<1, optimizer=@optimizer_xx_template; end
if nargin<2, cfg=course_config('classroom'); end
root=fileparts(mfilename('fullpath'));
folder=fullfile(root,'results','student',func2str(optimizer));
if ~exist(folder,'dir'),mkdir(folder);end
for j=1:numel(cfg.examples)
    ex=cfg.examples(j);
    data=prepare_data(ex.csv_path,ex.feature_columns,ex.target_column,cfg.split_seed,ex.categorical_columns,ex.task,ex.split_file);
    for seed=cfg.seeds
        initial=init_fnn(data.Xtrain,cfg.rules,1,seed);
        [model,search]=train_meta_fnn(initial,data.Xtrain,data.ytrain,data.Xval,data.yval,cfg,seed,optimizer);
        pred=predict_model(model,data.Xtest)*data.ystd+data.ymean;
        if strcmp(ex.task,'classification')
            metrics=classification_metrics(data.ytest,pred,data.classes);
        else
            metrics=regression_metrics(data.ytest,pred);
        end
        disp(ex.name);disp(metrics);
        % save(fullfile(folder,sprintf('%s_seed%d.mat',ex.name,seed)),'model','data','cfg','search','pred','metrics','-v7');
    end
end
end
