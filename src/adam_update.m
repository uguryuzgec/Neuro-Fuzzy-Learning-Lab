function [theta, state] = adam_update(theta, grad, state, rate)
if isempty(state)
    state.m = zeros(size(theta)); state.v = state.m; state.t = 0;
end
state.t = state.t+1;
state.m = 0.9*state.m+0.1*grad;
state.v = 0.999*state.v+0.001*(grad.^2);
m = state.m/(1-0.9^state.t); v = state.v/(1-0.999^state.t);
theta = theta-rate*m./(sqrt(v)+1e-8);
end
