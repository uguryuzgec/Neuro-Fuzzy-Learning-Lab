function create_extra_splits()
% One-time fixed splits shared by all models; does not touch original datasets.
root=fileparts(fileparts(mfilename('fullpath')));addpath(root);setup_course();
cfg=course_config('smoke');
for i=3:numel(cfg.examples)
    ex=cfg.examples(i);
    if exist(ex.split_file,'file'),error('Split already exists: %s',ex.split_file);end
    d=prepare_data(ex.csv_path,ex.feature_columns,ex.target_column,42,[],ex.task,'');
    n=numel(d.train_idx)+numel(d.val_idx)+numel(d.test_idx);split=zeros(n,1);
    split(d.val_idx)=1;split(d.test_idx)=2;
    fid=fopen(ex.split_file,'w');assert(fid>=0);fprintf(fid,'split\n');fprintf(fid,'%d\n',split);fclose(fid);
    fprintf('%s: %d / %d / %d\n',ex.name,numel(d.train_idx),numel(d.val_idx),numel(d.test_idx));
end
end
