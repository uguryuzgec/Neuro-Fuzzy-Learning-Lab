"""Drop-in optimizers: minimize objective(theta); count EVERY fitness call."""
import numpy as np

def _initialize(objective,lower,upper,initial,opts):
    lo=np.asarray(lower); hi=np.asarray(upper); initial=np.asarray(initial)
    N=opts['population']; budget=opts['max_evals']; rng=np.random.default_rng(opts['seed'])
    if N<2 or budget<N or not np.all(hi>lo): raise ValueError('Invalid search configuration')
    pop=lo+rng.random((N,len(lo)))*(hi-lo); pop[0]=np.clip(initial,lo,hi)
    values=np.array([objective(x.copy()) for x in pop])
    if not np.isfinite(values).all(): raise ValueError('Nonfinite objective')
    i=values.argmin(); best=float(values[i]); xbest=pop[i].copy()
    history=np.minimum.accumulate(values).tolist()
    return rng,pop,values,best,xbest,history

def _result(best,xbest,history):
    return dict(best_position=xbest,best_cost=best,history=np.asarray(history),evals=len(history))

def optimizer_ga(objective,lower,upper,initial,opts):
    rng,pop,costs,best,xbest,history=_initialize(objective,lower,upper,initial,opts)
    N,D=pop.shape; budget=opts['max_evals']; span=upper-lower
    while len(history)<budget:
        nxt=pop.copy(); ncost=costs.copy(); nxt[0]=xbest; ncost[0]=best
        for i in range(1,N):
            if len(history)>=budget: break
            a=rng.integers(N,size=2); b=rng.integers(N,size=2)
            p1=pop[a[costs[a].argmin()]];p2=pop[b[costs[b].argmin()]]
            alpha=rng.random(D); child=alpha*p1+(1-alpha)*p2
            mask=rng.random(D)<max(1/D,.05);step=.1*(1-.8*len(history)/budget)
            child=np.clip(child+mask*rng.normal(size=D)*span*step,lower,upper)
            value=float(objective(child.copy()))
            if not np.isfinite(value): raise ValueError('Nonfinite GA objective')
            nxt[i]=child;ncost[i]=value
            if value<best: best=value;xbest=child.copy()
            history.append(best)
        pop,costs=nxt,ncost
    return _result(best,xbest,history)

def optimizer_pso(objective,lower,upper,initial,opts):
    rng,pop,costs,best,xbest,history=_initialize(objective,lower,upper,initial,opts)
    N,D=pop.shape; budget=opts['max_evals']; span=upper-lower
    pbest=pop.copy(); velocity=np.zeros_like(pop)
    while len(history)<budget:
        for i in range(N):
            if len(history)>=budget: break
            velocity[i]=.7*velocity[i]+1.5*rng.random(D)*(pbest[i]-pop[i])+1.5*rng.random(D)*(xbest-pop[i])
            velocity[i]=np.clip(velocity[i],-.2*span,.2*span)
            proposal=pop[i]+velocity[i]; hit=(proposal<lower)|(proposal>upper)
            pop[i]=np.clip(proposal,lower,upper);velocity[i,hit]=0
            value=float(objective(pop[i].copy()))
            if not np.isfinite(value): raise ValueError('Nonfinite PSO objective')
            if value<costs[i]:costs[i]=value;pbest[i]=pop[i].copy()
            if value<best:best=value;xbest=pop[i].copy()
            history.append(best)
    return _result(best,xbest,history)

def optimizer_xx_template(objective,lower,upper,initial,opts):
    """Return best_position, best_cost, history (per evaluation), evals.

    opts keys: population, max_evals, seed. Optimize only the passed objective.
    This intentionally raises until the student implements their own heuristic.
    """
    raise NotImplementedError('Implement your selected heuristic here')
