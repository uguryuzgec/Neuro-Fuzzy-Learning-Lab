"""Working integration example. Replace optimizer_pso with your optimizer_xx."""
from course_core import (Config, examples, prepare_data, init_fnn, train_meta_fnn,
                         predict, classification_metrics, rmse)
from optimizers import optimizer_pso

def run_student(optimizer=optimizer_pso, cfg=None, datasets=None):
    cfg=cfg or Config(); rows=[]
    for ex in examples() if datasets is None else datasets:
        data=prepare_data(**{k:v for k,v in ex.items() if k!='name'})
        for seed in cfg.seeds:
            initial=init_fnn(data['Xtrain'],cfg.rules,1,seed)
            model,search=train_meta_fnn(initial,data['Xtrain'],data['ytrain'],
                data['Xval'],data['yval'],cfg,seed,optimizer)
            pred=predict(model,data['Xtest'])*data['ystd']+data['ymean']
            metrics=classification_metrics(data['ytest'],pred,data['classes']) if ex['task']=='classification' \
                else dict(rmse=rmse(pred.ravel(),data['ytest']))
            print(ex['name'],seed,metrics)
            rows.append(dict(example=ex['name'],seed=seed,model=model,search=search,metrics=metrics))
    return rows

if __name__=='__main__':run_student()
