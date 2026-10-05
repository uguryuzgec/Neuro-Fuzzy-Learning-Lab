function test_course()
% Meaningful numerical checks for hand-coded learning and search algorithms.
root = setup_course(); rng(7,'twister');
X = randn(30,3); y = sin(X(:,1))+0.2*X(:,2).^2;
cfg = course_config('smoke'); cfg.rules = 3; cfg.hidden = 4;
m = init_fnn(X,3,1,7); A = fnn_design(m,X); m.beta = ridge_solve(A,y,cfg.lambda);
[~,w] = fnn_design(m,[X; 1e4*ones(1,3)]);
assert(max(abs(sum(w,2)-1))<1e-12 && all(isfinite(w(:))));
% ANFIS backward derivatives with fixed consequents.
[~,g] = fnn_gradient(m,X,y,cfg.lambda); t = fnn_pack(m); gn = zeros(size(t)); h=1e-5;
for k = 1:numel(t)
    a=t; b=t; a(k)=a(k)+h; b(k)=b(k)-h;
    la=fnn_gradient(fnn_unpack(a,m),X,y,cfg.lambda);
    lb=fnn_gradient(fnn_unpack(b,m),X,y,cfg.lambda);
    gn(k)=(la-lb)/(2*h);
end
relative = norm(g-gn)/max(1,norm(g)+norm(gn));
assert(relative<1e-6,'ANFIS gradient check failed.');
fprintf('ANFIS gradient relative error: %.3g\n',relative);
% MLP full backprop derivative.
t=randn(3*4+2*4+1,1)*0.1;
[~,g]=mlp_loss(t,X,y,4,cfg.lambda); gn=zeros(size(t));
for k=1:numel(t)
    a=t;b=t;a(k)=a(k)+h;b(k)=b(k)-h;
    la=mlp_loss(a,X,y,4,cfg.lambda);lb=mlp_loss(b,X,y,4,cfg.lambda);
    gn(k)=(la-lb)/(2*h);
end
relative=norm(g-gn)/max(1,norm(g)+norm(gn));
assert(relative<1e-6,'MLP gradient check failed.');
fprintf('MLP gradient relative error: %.3g\n',relative);
% Ridge normal-equation residual and an exactly representable linear target.
beta=ridge_solve(A,y,cfg.lambda);
assert(norm(A'*(A*beta-y)+size(A,1)*cfg.lambda*beta)<1e-8);
% Optimizer budget (including partial generation), bounds, repeatability.
opts=struct('population',6,'max_evals',101,'seed',4);
lo=-3*ones(5,1);hi=-lo;initial=2*ones(5,1);
for fun={@optimizer_ga,@optimizer_pso}
    out=fun{1}(@(z)sum(z.^2),lo,hi,initial,opts);
    again=fun{1}(@(z)sum(z.^2),lo,hi,initial,opts);
    assert(out.evals==101 && numel(out.history)==101);
    assert(all(diff(out.history)<=0) && out.best_cost<sum(initial.^2));
    assert(all(out.best_position>=lo & out.best_position<=hi));
    assert(isequal(out.history,again.history));
    assert(abs(out.best_cost-sum(out.best_position.^2))<1e-12);
end
% Shared split and train-only scalers, including nominal encoding.
d=prepare_data(fullfile(root,'data','energy.csv'),1:8,9,42,[6 8]);
d2=prepare_data(fullfile(root,'data','energy.csv'),1:8,10,42,[6 8]);
assert(isequal(d.train_idx,d2.train_idx) && isequal(d.test_idx,d2.test_idx));
assert(isempty(intersect(d.train_idx,d.test_idx)) && isempty(intersect(d.val_idx,d.test_idx)));
assert(numel(unique([d.train_idx,d.val_idx,d.test_idx]))==768);
assert(max(abs(mean(d.Xtrain)))<1e-12 && abs(mean(d.ytrain))<1e-12);
% A changed TEST row cannot change training data or train-fitted scaling.
raw=dlmread(fullfile(root,'data','energy.csv'),',',1,0);
raw(d.test_idx(1),1)=1e6; raw(d.test_idx(1),9)=-1e6;
tmp=[tempname '.csv']; fid=fopen(tmp,'w'); fprintf(fid,'X1,X2,X3,X4,X5,X6,X7,X8,Y1,Y2\n');fclose(fid);
dlmwrite(tmp,raw,'-append','delimiter',',','precision',17);
cleanup=onCleanup(@()delete(tmp)); altered=prepare_data(tmp,1:8,9,42,[6 8]);
assert(isequal(d.Xtrain,altered.Xtrain) && isequal(d.ytrain,altered.ytrain));
assert(isequal(d.xmean,altered.xmean) && isequal(d.ystd,altered.ystd));
% Both FNN orders, reconstructed meta model, and all predictions finite.
for order=0:1
    base=init_fnn(X,3,order,7);
    [model,history]=train_fnn(base,X,y,X,y,cfg);
    assert(all(isfinite(predict_model(model,X))) && all(isfinite(history(:))));
end
[model,search]=train_meta_fnn(m,X,y,X,y,cfg,7,@optimizer_pso);
cost=sqrt(mean((predict_model(model,X)-y).^2));
assert(abs(cost-search.best_cost)<1e-10);
fprintf('All numerical and data-isolation checks PASSED.\n');
test_multiclass(X,cfg);
end

function test_multiclass(X,cfg)
Y=eye(3);Y=Y(mod(0:size(X,1)-1,3)+1,:);h=1e-5;
t=randn(3*4+4+4*3+3,1)*0.1;
[~,g]=mlp_loss(t,X,Y,4,cfg.lambda);gn=zeros(size(t));
for k=1:numel(t)
    a=t;b=t;a(k)=a(k)+h;b(k)=b(k)-h;
    gn(k)=(mlp_loss(a,X,Y,4,cfg.lambda)-mlp_loss(b,X,Y,4,cfg.lambda))/(2*h);
end
assert(norm(g-gn)/max(1,norm(g)+norm(gn))<1e-6);
for order=0:1
    m=init_fnn(X,3,order,7);m.beta=ridge_solve(fnn_design(m,X),Y,cfg.lambda);
    [~,g]=fnn_gradient(m,X,Y,cfg.lambda);t=fnn_pack(m);gn=zeros(size(t));
    for k=1:numel(t)
        a=t;b=t;a(k)=a(k)+h;b(k)=b(k)-h;
        gn(k)=(fnn_gradient(fnn_unpack(a,m),X,Y,cfg.lambda)-fnn_gradient(fnn_unpack(b,m),X,Y,cfg.lambda))/(2*h);
    end
    assert(norm(g-gn)/max(1,norm(g)+norm(gn))<1e-6);
end
metrics=classification_metrics([1;2;3],eye(3),[1;2;3]);
assert(metrics.accuracy==1 && metrics.macro_f1==1);
fprintf('Multiclass gradients and metrics PASSED.\n');
end
