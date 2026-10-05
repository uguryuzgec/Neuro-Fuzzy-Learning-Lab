function data = prepare_data(csv_path, feature_columns, target_column, seed, categorical_columns, task, split_file)
% Numeric CSV, exactly one header row. Explicit columns prevent target leakage.
raw = dlmread(csv_path, ',', 1, 0);
if nargin < 5, categorical_columns = []; end
if nargin < 6, task = 'regression'; end
if nargin < 7, split_file = ''; end
assert(any(strcmp(task,{'regression','classification'})));
assert(~ismember(target_column, feature_columns), 'Target is also an input!');
assert(numel(unique(feature_columns)) == numel(feature_columns));
X = raw(:, feature_columns); y = raw(:, target_column);
assert(size(X,1) >= 30, 'At least 30 observations required.');
assert(all(isfinite(X(:))) && all(isfinite(y)), 'Handle missing/nonfinite data explicitly.');
n = size(X,1); rng(seed, 'twister');
if ~isempty(split_file)
    split = dlmread(split_file,',',1,0);
    assert(numel(split)==n && all(ismember(split,[0 1 2])));
else
    split = zeros(n,1); groups = {1:n};
    if strcmp(task,'classification')
        labels = unique(y); groups = cell(1,numel(labels));
        for c=1:numel(labels), groups{c}=find(y==labels(c))'; end
    end
    for c=1:numel(groups)
        group=groups{c}; group=group(randperm(numel(group)));
        assert(numel(group)>=5,'Each class needs at least 5 observations.');
        a=floor(.6*numel(group));b=a+floor(.2*numel(group));
        split(group(1:a))=0;split(group(a+1:b))=1;split(group(b+1:end))=2;
    end
end
data.train_idx = find(split==0)'; data.val_idx = find(split==1)'; data.test_idx = find(split==2)';
assert(~isempty(data.train_idx) && ~isempty(data.val_idx) && ~isempty(data.test_idx));
data.task = task; data.split_file = split_file;
% Category vocabulary comes ONLY from training. Unknown values become all-zero.
% Save the mapping so future observations can use the same transformation.
data.category_values = cell(1,numel(feature_columns)); encoded = [];
for j = 1:numel(feature_columns)
    if ismember(feature_columns(j),categorical_columns)
        values = unique(X(data.train_idx,j)); data.category_values{j} = values;
        encoded = [encoded,bsxfun(@eq,X(:,j),values')]; %#ok<AGROW>
    else
        encoded = [encoded,X(:,j)]; %#ok<AGROW>
    end
end
X = double(encoded); data.categorical_columns = categorical_columns;
% Fit both scalers ONLY on training rows; do not standardize before splitting.
data.xmean = mean(X(data.train_idx,:),1);
data.xstd = std(X(data.train_idx,:),0,1);
data.xstd(data.xstd < 1e-12) = 1;
if strcmp(task,'regression')
    data.ymean = mean(y(data.train_idx)); data.ystd = std(y(data.train_idx));
    if data.ystd < 1e-12, data.ystd = 1; end
    ys = (y-data.ymean)/data.ystd; data.classes = [];
else
    data.ymean = 0; data.ystd = 1; data.classes = unique(y(data.train_idx));
    assert(all(ismember(y,data.classes)), 'Unseen class outside training.');
    ys = double(bsxfun(@eq,y,data.classes'));
end
Xs = bsxfun(@rdivide, bsxfun(@minus, X, data.xmean), data.xstd);
data.Xtrain = Xs(data.train_idx,:); data.ytrain = ys(data.train_idx,:);
data.Xval = Xs(data.val_idx,:); data.yval = ys(data.val_idx,:);
data.Xtest = Xs(data.test_idx,:); data.ytest = y(data.test_idx);
data.feature_columns = feature_columns; data.target_column = target_column;
data.split_seed = seed; data.source = csv_path;
end
