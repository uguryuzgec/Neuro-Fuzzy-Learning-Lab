function results = run_all(profile)
if nargin < 1, profile = 'classroom'; end
setup_course();
cfg = course_config(profile);
results = [];
for stage = 1:3
    results = [results; run_stage(stage, cfg)]; %#ok<AGROW>
end
end
