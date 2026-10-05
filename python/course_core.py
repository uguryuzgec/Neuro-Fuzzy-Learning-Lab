"""Transparent NN / neuro-fuzzy teaching models. NumPy only for model training.

Regression targets have shape (n, 1); classification targets are one-hot (n, K).
Classifiers minimize squared error and predict argmax of *scores*, not probabilities.
"""
from __future__ import annotations
from copy import deepcopy
from dataclasses import dataclass
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1]

@dataclass
class Config:
    profile: str = 'classroom'
    seeds: tuple = (11,)
    hidden: int = 24
    rules: int = 6
    ridge: float = 1e-4
    epochs: int = 150
    patience: int = 30
    learning_rate: float = .01
    population: int = 16
    max_evals: int = 320
    plots: bool = True
    save_results: bool = True
    show_figures: bool = True
    output_dir: str = ''

    @classmethod
    def for_profile(cls, profile='classroom'):
        c = cls(profile=profile)
        if profile == 'smoke':
            c.epochs = c.patience = 8
            c.population, c.max_evals, c.plots = 6, 24, False
            c.show_figures = False
        elif profile == 'repeated':
            c.seeds = tuple(range(11,21))
        elif profile != 'classroom':
            raise ValueError('Unknown profile')
        return c

def examples():
    # Python columns are ZERO-based; MATLAB columns are ONE-based.
    return [dict(name='energy_heating', task='regression', path=ROOT/'data/energy.csv',
                 features=list(range(8)), target=8, categorical=[5,7],
                 split_file=ROOT/'data/energy_split42.csv'),
            dict(name='wine', task='classification', path=ROOT/'data/wine.csv',
                 features=list(range(1,14)), target=0, categorical=[],
                 split_file=ROOT/'data/wine_split42.csv')] + [
            dict(name=name, task=task, path=ROOT/f'data/{name}.csv',
                 features=list(range(d)), target=d, categorical=[],
                 split_file=ROOT/f'data/{name}_split42.csv')
            for name,task,d in [('airfoil','regression',5),('yacht','regression',6),
                                ('seeds','classification',7),('sonar','classification',60)]]

def prepare_data(path, features, target, categorical=(), task='regression', split_file=None, seed=42):
    raw = np.loadtxt(path, delimiter=',', skiprows=1, ndmin=2)
    if target in features or len(set(features)) != len(features):
        raise ValueError('Target leakage or duplicate feature columns')
    if task not in ('regression', 'classification'):
        raise ValueError('Unknown task')
    X, y = raw[:, features], raw[:, target]
    if len(y)<30 or not np.isfinite(X).all() or not np.isfinite(y).all():
        raise ValueError('Need >=30 finite numeric observations; handle missingness explicitly')
    if split_file is not None:
        split = np.loadtxt(split_file, delimiter=',', skiprows=1)
        if split.shape != (len(y),) or not np.isin(split, [0,1,2]).all():
            raise ValueError('Invalid saved split')
    else:
        rng = np.random.default_rng(seed); split = np.zeros(len(y), dtype=int)
        groups = [np.arange(len(y))] if task=='regression' else [np.flatnonzero(y==c) for c in np.unique(y)]
        for group in groups:
            if len(group)<5: raise ValueError('Each class needs >=5 samples')
            g=rng.permutation(group); a=int(.6*len(g)); b=a+int(.2*len(g))
            split[g[:a]]=0; split[g[a:b]]=1; split[g[b:]]=2
    tr,va,te = [np.flatnonzero(split==i) for i in range(3)]
    if min(map(len,(tr,va,te)))==0: raise ValueError('Empty partition')
    categories={}; blocks=[]
    for j,col in enumerate(features):
        if col in categorical:
            values=np.unique(X[tr,j]); categories[j]=values
            blocks.append((X[:,j,None]==values).astype(float))
        else: blocks.append(X[:,j,None])
    X=np.column_stack(blocks)
    xm=X[tr].mean(0); xs=X[tr].std(0,ddof=1); xs[xs<1e-12]=1
    X=(X-xm)/xs
    classes=np.array([])
    if task=='regression':
        ym=y[tr].mean(); ys=y[tr].std(ddof=1)
        if ys<1e-12: ys=1.
        Y=((y-ym)/ys)[:,None]
    else:
        ym,ys=0.,1.; classes=np.unique(y[tr])
        if not np.isin(y,classes).all(): raise ValueError('Unseen class outside training')
        Y=(y[:,None]==classes).astype(float)
    return dict(Xtrain=X[tr], ytrain=Y[tr], Xval=X[va], yval=Y[va], Xtest=X[te],
                ytest=y[te], train_idx=tr, val_idx=va, test_idx=te, xmean=xm, xstd=xs,
                ymean=ym, ystd=ys, classes=classes, categories=categories, task=task,
                features=list(features), categorical=list(categorical), target=target)

def rmse(pred,y): return float(np.sqrt(np.mean((pred-y)**2)))

def ridge_solve(A,y,lam):
    if lam<=0: raise ValueError('Positive ridge penalty required')
    p=A.shape[1]
    return np.linalg.lstsq(np.vstack([A,np.sqrt(len(A)*lam)*np.eye(p)]),
                          np.vstack([y,np.zeros((p,y.shape[1]))]),rcond=None)[0]

def adam(theta,g,state,rate):
    if state is None: state=(np.zeros_like(theta),np.zeros_like(theta),0)
    m,v,t=state; t+=1; m=.9*m+.1*g; v=.999*v+.001*g*g
    theta=theta-rate*(m/(1-.9**t))/(np.sqrt(v/(1-.999**t))+1e-8)
    return theta,(m,v,t)

def mlp_loss(theta,X,y,h,lam):
    d=X.shape[1]; k=d*h; outputs=y.shape[1]
    W=theta[:k].reshape(d,h); b=theta[k:k+h]
    V=theta[k+h:k+h+h*outputs].reshape(h,outputs); c=theta[-outputs:]
    H=np.tanh(X@W+b); pred=H@V+c; e=pred-y
    loss=np.mean(e*e)+lam*(np.sum(W*W)+np.sum(V*V))
    delta=2*e/y.size; gh=(delta@V.T)*(1-H*H)
    g=np.concatenate([(X.T@gh+2*lam*W).ravel(),gh.sum(0),
                      (H.T@delta+2*lam*V).ravel(),delta.sum(0)])
    return float(loss),g,pred

def train_mlp(X,y,Xv,yv,cfg,seed):
    rng=np.random.default_rng(seed); d=X.shape[1]; h=cfg.hidden; o=y.shape[1]
    theta=np.r_[rng.normal(size=d*h)*np.sqrt(2/(d+h)),np.zeros(h),
                rng.normal(size=h*o)/np.sqrt(h),np.zeros(o)]
    best=np.inf; stale=0; state=None; history=[]
    for epoch in range(cfg.epochs):
        _,g,_=mlp_loss(theta,X,y,h,cfg.ridge)
        theta,state=adam(theta,g,state,cfg.learning_rate)
        pt=mlp_loss(theta,X,y,h,0)[2]; pv=mlp_loss(theta,Xv,yv,h,0)[2]
        history.append([rmse(pt,y),rmse(pv,yv)])
        if history[-1][1]<best:
            best=history[-1][1]; saved=theta.copy(); best_epoch=epoch+1; stale=0
        else: stale+=1
        if stale>=cfg.patience: break
    return dict(kind='mlp',theta=saved,hidden=h,outputs=o,best_epoch=best_epoch),np.array(history)

def train_random_nn(X,y,cfg,seed,direct=False):
    rng=np.random.default_rng(seed)
    W=rng.normal(size=(X.shape[1],cfg.hidden))/np.sqrt(X.shape[1]); b=rng.uniform(-1,1,cfg.hidden)
    H=np.tanh(X@W+b)
    A=np.c_[np.ones(len(X)),X,H] if direct else np.c_[np.ones(len(X)),H]
    return dict(kind='random_nn',W=W,b=b,direct=direct,beta=ridge_solve(A,y,cfg.ridge))

def init_fnn(X,rules,order,seed):
    if not 1<=rules<=len(X): raise ValueError('Invalid rule count')
    rng=np.random.default_rng(seed); C=X[rng.permutation(len(X))[:rules]].copy()
    for _ in range(20):
        labels=((X[:,None,:]-C)**2).sum(2).argmin(1); old=C.copy()
        for r in range(rules):
            if np.any(labels==r): C[r]=X[labels==r].mean(0)
        if np.max(np.abs(C-old))<1e-8: break
    sigma=np.tile(np.maximum(X.std(0,ddof=1),.5),(rules,1))
    return dict(kind='fnn',C=C,logS=np.log(sigma),order=order,rules=rules,beta=None)

def fnn_design(m,X):
    logs=-.5*(((X[:,None,:]-m['C'])/np.exp(m['logS']))**2).sum(2)
    logs-=logs.max(1,keepdims=True); w=np.exp(logs); w/=w.sum(1,keepdims=True)
    B=np.ones((len(X),1)) if m['order']==0 else np.c_[np.ones(len(X)),X]
    A=(w[:,:,None]*B[:,None,:]).reshape(len(X),-1)
    return A,w,B

def pack(m): return np.r_[m['C'].ravel(),m['logS'].ravel()]

def unpack(theta,initial):
    m=deepcopy(initial); k=m['C'].size
    if theta.size!=2*k: raise ValueError('Wrong parameter count')
    m['C']=theta[:k].reshape(m['C'].shape).copy()
    m['logS']=theta[k:].reshape(m['logS'].shape).copy()
    return m

def bounds(m,X):
    k=m['C'].size
    lo=np.r_[np.tile(X.min(0)-.5,(m['rules'],1)).ravel(),np.full(k,np.log(.15))]
    hi=np.r_[np.tile(X.max(0)+.5,(m['rules'],1)).ravel(),np.full(k,np.log(3.))]
    return lo,hi

def fnn_gradient(m,X,y,lam):
    A,w,B=fnn_design(m,X); pred=A@m['beta']; e=pred-y
    local=np.einsum('np,rpk->nrk',B,m['beta'].reshape(m['rules'],B.shape[1],y.shape[1]))
    q=(2*e[:,None,:]/len(X)*w[:,:,None]*(local-pred[:,None,:])).sum(2)
    diff=X[:,None,:]-m['C']; s2=np.exp(2*m['logS'])
    gc=(q[:,:,None]*diff/s2).sum(0); gs=(q[:,:,None]*diff**2/s2).sum(0)
    loss=np.sum(e*e)/len(X)+lam*np.sum(m['beta']**2)
    return float(loss),np.r_[gc.ravel(),gs.ravel()]

def train_fnn(initial,X,y,Xv,yv,cfg):
    m=deepcopy(initial); lo,hi=bounds(m,X); state=None; best=np.inf; stale=0; history=[]
    for epoch in range(cfg.epochs+1):
        m['beta']=ridge_solve(fnn_design(m,X)[0],y,cfg.ridge)
        history.append([rmse(predict(m,X),y),rmse(predict(m,Xv),yv)])
        if history[-1][1]<best:
            best=history[-1][1]; saved=deepcopy(m); saved['best_epoch']=epoch; stale=0
        else: stale+=1
        if stale>=cfg.patience or epoch==cfg.epochs: break
        _,g=fnn_gradient(m,X,y,cfg.ridge)
        theta,state=adam(pack(m),g,state,cfg.learning_rate); m=unpack(np.clip(theta,lo,hi),m)
    return saved,np.array(history)

def train_fuzzy_rvfl(initial,X,y,cfg,seed):
    # Teaching feature-fusion variant, not a claimed reproduction of a paper.
    m=deepcopy(initial); m['kind']='fuzzy_rvfl'; rng=np.random.default_rng(seed)
    m['W']=rng.normal(size=(X.shape[1],cfg.hidden))/np.sqrt(X.shape[1]); m['b']=rng.uniform(-1,1,cfg.hidden)
    w=fnn_design(m,X)[1]; H=np.tanh(X@m['W']+m['b'])
    m['beta']=ridge_solve(np.c_[np.ones(len(X)),X,w,H],y,cfg.ridge)
    return m

def predict(m,X):
    kind=m['kind']
    if kind=='mean': return np.tile(m['value'],(len(X),1))
    if kind=='ridge': return np.c_[np.ones(len(X)),X]@m['beta']
    if kind=='knn':
        idx=((X[:,None,:]-m['X'][None,:,:])**2).sum(2).argsort(1)[:,:m['k']]
        return m['y'][idx].mean(1)
    if kind=='mlp': return mlp_loss(m['theta'],X,np.zeros((len(X),m['outputs'])),m['hidden'],0)[2]
    if kind=='fnn': return fnn_design(m,X)[0]@m['beta']
    H=np.tanh(X@m['W']+m['b'])
    if kind=='fuzzy_rvfl': A=np.c_[np.ones(len(X)),X,fnn_design(m,X)[1],H]
    elif kind=='random_nn': A=np.c_[np.ones(len(X)),X,H] if m['direct'] else np.c_[np.ones(len(X)),H]
    else: raise ValueError('Unknown model kind')
    return A@m['beta']

def classification_metrics(y,scores,classes):
    predicted=classes[scores.argmax(1)]; K=len(classes); cm=np.zeros((K,K),int)
    np.add.at(cm,(np.searchsorted(classes,y),np.searchsorted(classes,predicted)),1)
    tp=np.diag(cm); recall=tp/np.maximum(cm.sum(1),1); precision=tp/np.maximum(cm.sum(0),1)
    f1=2*precision*recall/np.maximum(precision+recall,np.finfo(float).eps)
    return dict(accuracy=float(np.mean(y==predicted)),macro_f1=float(f1.mean()),
                balanced_accuracy=float(recall.mean()),confusion=cm)

def fnn_objective(theta,initial,X,y,Xv,yv,lam):
    # Test data is not an argument and cannot enter fitness selection.
    m=unpack(theta,initial); m['beta']=ridge_solve(fnn_design(m,X)[0],y,lam)
    return rmse(predict(m,Xv),yv)

def train_meta_fnn(initial,X,y,Xv,yv,cfg,seed,optimizer):
    lo,hi=bounds(initial,X)
    objective=lambda theta: fnn_objective(theta,initial,X,y,Xv,yv,cfg.ridge)
    result=optimizer(objective,lo,hi,pack(initial),dict(population=cfg.population,max_evals=cfg.max_evals,seed=seed))
    assert result['evals']==cfg.max_evals
    assert np.all((result['best_position']>=lo)&(result['best_position']<=hi))
    m=unpack(result['best_position'],initial); m['beta']=ridge_solve(fnn_design(m,X)[0],y,cfg.ridge)
    return m,result
