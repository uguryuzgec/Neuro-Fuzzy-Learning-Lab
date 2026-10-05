"""Batch entry for all six datasets. Use run_interactive.py for classroom menus."""
from __future__ import annotations
import argparse, csv, json, time
from pathlib import Path
from dataclasses import asdict
import numpy as np
from course_core import (ROOT, Config, examples, prepare_data, ridge_solve, rmse,
    init_fnn, fnn_design, train_mlp, train_random_nn, train_fnn, train_fuzzy_rvfl,
    train_meta_fnn, predict, classification_metrics)
from optimizers import optimizer_ga, optimizer_pso
from plots import model_plot, comparison_plot, show_results_table

STAGES={1:['Mean','Ridge','kNN','MLP','ELM','RVFL'],
        2:['Fixed-TSK1','Adaptive-TSK0','ANFIS','Fuzzy-RVFL'],
        3:['ANFIS','FNN-GA','FNN-PSO']}
STAGES[0]=list(dict.fromkeys(name for group in STAGES.values() for name in group))

def json_value(value):
    if isinstance(value,np.ndarray): return json_value(value.tolist())
    if isinstance(value,np.generic): return json_value(value.item())
    if isinstance(value,float) and not np.isfinite(value): return None
    if isinstance(value,Path): return str(value)
    if isinstance(value,dict): return {str(k):json_value(v) for k,v in value.items()}
    if isinstance(value,(list,tuple)): return [json_value(v) for v in value]
    return value

def run_stage(stage,cfg=None,datasets=None,names=None):
    cfg=cfg or Config(); datasets=examples() if datasets is None else datasets
    names=STAGES[stage] if names is None else list(names)
    if not names or len(set(names))!=len(names) or any(n not in STAGES[stage] for n in names):
        raise ValueError('Invalid or duplicate model selection')
    if not datasets:raise ValueError('Select at least one dataset')
    base=Path(cfg.output_dir) if cfg.output_dir else ROOT/'results_python'/cfg.profile
    outdir=base/f'stage_{stage}'
    if cfg.save_results:outdir.mkdir(parents=True,exist_ok=True)
    rows=[]
    for ex in datasets:
        data=prepare_data(**{k:v for k,v in ex.items() if k!='name'})
        X,y,Xv,yv=[data[k] for k in ('Xtrain','ytrain','Xval','yval')]
        for seed in cfg.seeds:
            initial=init_fnn(X,cfg.rules,1,seed)
            predictions=[]
            for name in names:
                history=np.empty((0,2));search=None;calls=0;started=time.perf_counter()
                if name=='Mean': model=dict(kind='mean',value=y.mean(0))
                elif name=='Ridge':model=dict(kind='ridge',beta=ridge_solve(np.c_[np.ones(len(X)),X],y,cfg.ridge))
                elif name=='kNN':model=dict(kind='knn',X=X,y=y,k=5)
                elif name=='MLP':model,history=train_mlp(X,y,Xv,yv,cfg,seed)
                elif name in ('ELM','RVFL'):model=train_random_nn(X,y,cfg,seed,name=='RVFL')
                elif name=='Fixed-TSK1':
                    model=initial.copy();model['beta']=ridge_solve(fnn_design(model,X)[0],y,cfg.ridge)
                elif name in ('Adaptive-TSK0','ANFIS'):
                    base=initial.copy();base['order']=0 if name=='Adaptive-TSK0' else 1
                    model,history=train_fnn(base,X,y,Xv,yv,cfg)
                elif name=='Fuzzy-RVFL':model=train_fuzzy_rvfl(initial,X,y,cfg,seed)
                else:
                    optimizer=optimizer_ga if name=='FNN-GA' else optimizer_pso
                    model,search=train_meta_fnn(initial,X,y,Xv,yv,cfg,seed,optimizer)
                    history=search['history'];calls=search['evals']
                elapsed=time.perf_counter()-started
                # Held-out test is touched only here, after training and selection.
                pred=predict(model,data['Xtest'])*data['ystd']+data['ymean']
                predictions.append(pred)
                if not np.isfinite(pred).all():raise ValueError('Nonfinite prediction')
                row=dict(stage=stage,target=ex['name'],model=name,seed=seed,split_seed=42,
                         train_rmse=rmse(predict(model,X),y)*data['ystd'],
                         val_rmse=rmse(predict(model,Xv),yv)*data['ystd'],
                         test_rmse=float('nan'),test_mae=float('nan'),test_r2=float('nan'),
                         accuracy=float('nan'),macro_f1=float('nan'),balanced_accuracy=float('nan'),
                         seconds=elapsed,fitness_evals=calls)
                confusion=np.empty((0,0))
                if data['task']=='classification':
                    metrics=classification_metrics(data['ytest'],pred,data['classes'])
                    confusion=metrics.pop('confusion');row.update(metrics)
                else:
                    error=pred.ravel()-data['ytest'];den=np.sum((data['ytest']-data['ytest'].mean())**2)
                    row.update(test_rmse=float(np.sqrt(np.mean(error**2))),test_mae=float(np.mean(abs(error))),
                               test_r2=float(1-np.sum(error**2)/den) if den>0 else float('nan'))
                rows.append(row);stem=f"{ex['name']}_{name}_seed{seed}"
                if cfg.save_results:
                    np.savez_compressed(outdir/(stem+'.npz'),pred=pred,ytest=data['ytest'],history=history,
                                    confusion=confusion,train_idx=data['train_idx'],val_idx=data['val_idx'],test_idx=data['test_idx'])
                # JSON is safe to inspect; no pickle loading required.
                preprocessing={k:data[k] for k in ('xmean','xstd','ymean','ystd','classes','categories','features','categorical','target','task')}
                if cfg.save_results:
                    (outdir/(stem+'.json')).write_text(json.dumps(json_value(dict(model=model,preprocessing=preprocessing,
                        config=asdict(cfg),name=name,is_meta=search is not None)),indent=2),encoding='utf-8')
                if cfg.plots:model_plot(outdir/stem,data,pred,history,name,search is not None,cfg)
                print(f"{ex['name']:15s} {name:14s} seed={seed} RMSE={row['test_rmse']:.4f} "
                      f"accuracy={row['accuracy']:.4f} macroF1={row['macro_f1']:.4f} ({elapsed:.2f}s)",flush=True)
            if cfg.plots and len(names)>1:
                comparison_plot(outdir/f"{ex['name']}_models_seed{seed}",data,predictions,names,cfg)
    if cfg.save_results:
        with (outdir/'metrics.csv').open('w',newline='',encoding='utf-8') as f:
            writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
        (outdir/'summary.json').write_text(json.dumps(json_value(dict(results=rows,config=asdict(cfg))),indent=2),encoding='utf-8')
    show_results_table(rows)
    return rows

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--stage',choices=['0','1','2','3','all'],default='0')
    parser.add_argument('--profile',choices=['smoke','classroom','repeated'],default='classroom')
    parser.add_argument('--no-plots',action='store_true')
    parser.add_argument('--no-save',action='store_true');parser.add_argument('--hide-figures',action='store_true')
    parser.add_argument('--datasets',nargs='+',choices=[e['name'] for e in examples()])
    parser.add_argument('--models',nargs='+',choices=STAGES[0]);args=parser.parse_args()
    cfg=Config.for_profile(args.profile)
    if args.no_plots:cfg.plots=False
    cfg.save_results=not args.no_save
    if args.hide_figures:cfg.show_figures=False
    datasets=[e for e in examples() if not args.datasets or e['name'] in args.datasets]
    if args.stage=='all' and args.models:parser.error('--models icin --stage 0 kullanin')
    for stage in (1,2,3) if args.stage=='all' else (int(args.stage),):run_stage(stage,cfg,datasets,args.models)
    if cfg.plots and cfg.show_figures:
        from plots import pyplot
        pyplot().show()

if __name__=='__main__':main()
