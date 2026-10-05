function check_extra_graphics()
root=setup_course();cfg=course_config('smoke');cfg.plots=true;
cfg.graphics_toolkit='gnuplot';cfg.output_dir=fullfile(root,'work','six_data_graphics');
for i=3:6
    ex=cfg.examples(i);preview_dataset(ex,cfg);
    f=openfig(fullfile(cfg.output_dir,'data_preview',[ex.name '_training.fig']),'new','invisible');
    assert(ishghandle(f));close(f);
end
cfg.examples=cfg.examples([3 6]);run_stage(0,cfg,{'ELM','ANFIS'});
fprintf('EXTRA GRAPHICS PASS: 4 previews, regression/classification model and combined plots.\n');
end
