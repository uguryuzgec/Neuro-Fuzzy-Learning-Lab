function root = setup_course()
% Only core MATLAB/Octave operations: no fuzzy, optim, statistics or NN toolbox.
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'src'));
addpath(fullfile(root, 'tests'));
end
