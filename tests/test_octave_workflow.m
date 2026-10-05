function test_octave_workflow()
% Integration tests: selection, both tasks, PNG/FIG roundtrip, no-save mode.
root=setup_course();
[ids,ok]=parse_selection('4, 5 6 4',12,true);assert(ok && isequal(ids,[4 5 6]));
for value={'1:3','system(1)','-1','1.5','1 0','99',''}
    [~,ok]=parse_selection(value{1},12,true);assert(~ok);
end
[~,ok]=parse_selection('1 2',12,false);assert(~ok);
[ids,ok]=parse_selection('0',12,false);assert(ok && ids==0);
cfg=course_config('smoke');cfg.plots=true;cfg.show_figures=false;
cfg.examples=cfg.examples(1:2); % Keep the original graphics regression test bounded.
cfg.graphics_toolkit='gnuplot';
cfg.output_dir=fullfile(root,'work',['octave_check_' datestr(now,'yyyymmdd_HHMMSS')]);
for i=1:numel(cfg.examples),preview_dataset(cfg.examples(i),cfg);end
r=run_stage(0,cfg);assert(numel(r)==24); % twelve unique models x two tasks
assert(sum(strcmp({r.target},'wine'))==12);
folder=fullfile(cfg.output_dir,'stage_0');
figs=dir(fullfile(folder,'*.fig'));pngs=dir(fullfile(folder,'*.png'));
assert(numel(figs)==26 && numel(pngs)==26); % + two combined model plots
assert(isempty(dir(fullfile(folder,'*comparison*.fig'))));
assert(numel(dir(fullfile(folder,'*models_seed*.fig')))==2);
for i=1:numel(figs)
    f=openfig(fullfile(folder,figs(i).name),'new','invisible');
    assert(ishghandle(f));assert(~isempty(findall(f,'type','axes')));close(f);
end
assert(exist(fullfile(folder,'metrics.csv'),'file')==2);
assert(exist(fullfile(folder,'summary.mat'),'file')==2);
cfg.save_results=false;cfg.output_dir=fullfile(root,'work','no_save_must_not_exist');
assert(~exist(cfg.output_dir,'dir'));
cfg.examples=cfg.examples(1);
preview_dataset(cfg.examples,cfg);
single=run_stage(1,cfg,{'ELM'});assert(numel(single)==1 && strcmp(single.model,'ELM'));
multi=run_stage(1,cfg,{'MLP','RVFL'});assert(isequal({multi.model},{'MLP','RVFL'}));
assert(~exist(cfg.output_dir,'dir'),'No-save mode created files!');
cfg.show_figures=true;cfg.plots=true;
f=course_figure('Visibility check',cfg);plot(1:3);finish_figure(f,'unused',cfg);
assert(ishghandle(f) && strcmp(get(f,'visible'),'on'));close(f);
fprintf('\nOCTAVE WORKFLOW PASS: 24 models, both tasks, 26 FIG roundtrips, no-save, selection and visibility.\n');
end
