function out = optimizer_pso(objective, lower, upper, initial, opts)
% Global-best PSO, inertia 0.7, cognitive/social gains 1.5, clipped velocity.
lower = lower(:)'; upper = upper(:)'; initial = initial(:)';
D = numel(lower); N = opts.population; budget = opts.max_evals;
assert(N>=2 && budget>=N && numel(initial)==D && all(upper>lower));
rng(opts.seed,'twister'); span = upper-lower;
pop = bsxfun(@plus,lower,bsxfun(@times,rand(N,D),span));
pop(1,:) = min(max(initial,lower),upper);
velocity = zeros(N,D); pbest = pop; pcost = Inf(N,1);
best = Inf; best_x = initial; calls = 0; history = zeros(budget,1);
for i = 1:N
    pcost(i) = objective(pop(i,:)'); calls = calls+1;
    assert(isfinite(pcost(i)), 'Nonfinite PSO objective.');
    if pcost(i)<best, best=pcost(i); best_x=pop(i,:); end
    history(calls) = best;
end
while calls < budget
    for i = 1:N
        if calls >= budget, break; end
        velocity(i,:) = 0.7*velocity(i,:) ...
            +1.5*rand(1,D).*(pbest(i,:)-pop(i,:)) ...
            +1.5*rand(1,D).*(best_x-pop(i,:));
        velocity(i,:) = min(max(velocity(i,:),-0.2*span),0.2*span);
        proposal = pop(i,:)+velocity(i,:);
        hit = proposal<lower | proposal>upper;
        pop(i,:) = min(max(proposal,lower),upper); velocity(i,hit) = 0;
        value = objective(pop(i,:)'); calls = calls+1;
        assert(isfinite(value), 'Nonfinite PSO objective.');
        if value<pcost(i), pcost(i)=value; pbest(i,:)=pop(i,:); end
        if value<best, best=value; best_x=pop(i,:); end
        history(calls) = best;
    end
end
out.best_position = best_x'; out.best_cost = best;
out.history = history; out.evals = calls;
end
