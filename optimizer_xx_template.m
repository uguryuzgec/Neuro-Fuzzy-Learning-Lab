function out = optimizer_xx_template(objective,lower,upper,initial,opts)
% STUDENT CONTRACT (this is a template, not an implemented algorithm).
% objective(theta_column) -> scalar to MINIMIZE. Never access test data here.
% lower/upper/initial: column vectors; initial is a shared ANFIS initialization.
% opts: population, max_evals, seed. Count initialization and ALL evaluations.
% Return:
% out.best_position: bounded column vector with the winning candidate
% out.best_cost: objective value already observed for that candidate
% out.history: best-so-far fitness after each call, length opts.max_evals
% out.evals: exactly opts.max_evals
% See src/optimizer_ga.m and optimizer_pso.m for working examples.
error('Implement the chosen heuristic here before running FNN-XX.');
end
