function cfg = course_config(profile)
% Fixed classroom settings, NOT a publication-quality hyperparameter search.
if nargin < 1, profile = 'classroom'; end
cfg.profile = profile;
folder = fullfile(fileparts(mfilename('fullpath')),'data');
cfg.examples(1) = struct('name','energy_heating','task','regression', ...
    'csv_path',fullfile(folder,'energy.csv'),'feature_columns',1:8, ...
    'target_column',9,'categorical_columns',[6 8],'split_file',fullfile(folder,'energy_split42.csv'));
cfg.examples(2) = struct('name','wine','task','classification', ...
    'csv_path',fullfile(folder,'wine.csv'),'feature_columns',2:14, ...
    'target_column',1,'categorical_columns',[],'split_file',fullfile(folder,'wine_split42.csv'));
cfg.examples(3) = struct('name','airfoil','task','regression', ...
    'csv_path',fullfile(folder,'airfoil.csv'),'feature_columns',1:5, ...
    'target_column',6,'categorical_columns',[],'split_file',fullfile(folder,'airfoil_split42.csv'));
cfg.examples(4) = struct('name','yacht','task','regression', ...
    'csv_path',fullfile(folder,'yacht.csv'),'feature_columns',1:6, ...
    'target_column',7,'categorical_columns',[],'split_file',fullfile(folder,'yacht_split42.csv'));
cfg.examples(5) = struct('name','seeds','task','classification', ...
    'csv_path',fullfile(folder,'seeds.csv'),'feature_columns',1:7, ...
    'target_column',8,'categorical_columns',[],'split_file',fullfile(folder,'seeds_split42.csv'));
cfg.examples(6) = struct('name','sonar','task','classification', ...
    'csv_path',fullfile(folder,'sonar.csv'),'feature_columns',1:60, ...
    'target_column',61,'categorical_columns',[],'split_file',fullfile(folder,'sonar_split42.csv'));
cfg.split_seed = 42;
cfg.seeds = 11;
cfg.hidden = 24;
cfg.rules = 6;
cfg.lambda = 1e-4; % objective: mean squared error + lambda * ||beta||^2
cfg.epochs = 150;
cfg.patience = 30;
cfg.learning_rate = 0.01;
cfg.population = 16;
cfg.max_evals = 320; % includes initialization; same GA and PSO budget
cfg.plots = true;
cfg.save_results = true;
cfg.show_figures = true; % Keep result windows open after training.
cfg.output_dir = ''; % Empty: use the usual results/profile/stage_N path.
if strcmp(profile, 'smoke')
    cfg.epochs = 8; cfg.patience = 8;
    cfg.population = 6; cfg.max_evals = 24; cfg.plots = false; cfg.show_figures=false;
elseif strcmp(profile, 'repeated')
    cfg.seeds = 11:20;
elseif ~strcmp(profile, 'classroom')
    error('Profile must be classroom, smoke or repeated.');
end
end
