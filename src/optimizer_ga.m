function out = optimizer_ga(objective, lower, upper, initial, opts)
% Real-coded GA: tournament selection, arithmetic crossover, Gaussian mutation.
% Contract shared by every FNN-XX optimizer; all objective calls are counted.
lower = lower(:)'; upper = upper(:)'; initial = initial(:)';
D = numel(lower); N = opts.population; budget = opts.max_evals;
assert(N>=2 && budget>=N && numel(initial)==D && all(upper>lower));
rng(opts.seed,'twister'); span = upper-lower;
pop = bsxfun(@plus,lower,bsxfun(@times,rand(N,D),span));
pop(1,:) = min(max(initial,lower),upper);
costs = Inf(N,1); best = Inf; best_x = initial; calls = 0;
history = zeros(budget,1);
for i = 1:N
    costs(i) = objective(pop(i,:)'); calls = calls+1;
    assert(isfinite(costs(i)), 'Nonfinite GA objective.');
    if costs(i)<best, best=costs(i); best_x=pop(i,:); end
    history(calls) = best;
end
while calls < budget
    next = pop; next_cost = costs;
    next(1,:) = best_x; next_cost(1) = best; % cached elitism, no extra call
    for i = 2:N
        if calls >= budget, break; end
        a = randi(N,1,2); [~,ia] = min(costs(a)); parent1 = pop(a(ia),:);
        b = randi(N,1,2); [~,ib] = min(costs(b)); parent2 = pop(b(ib),:);
        alpha = rand(1,D);
        child = alpha.*parent1+(1-alpha).*parent2;
        mask = rand(1,D)<max(1/D,0.05);
        step = 0.1*(1-0.8*calls/budget);
        child = child+mask.*randn(1,D).*span*step;
        child = min(max(child,lower),upper);
        value = objective(child'); calls = calls+1;
        assert(isfinite(value), 'Nonfinite GA objective.');
        next(i,:) = child; next_cost(i) = value;
        if value<best, best=value; best_x=child; end
        history(calls) = best;
    end
    pop = next; costs = next_cost;
end
out.best_position = best_x'; out.best_cost = best;
out.history = history; out.evals = calls;
end
