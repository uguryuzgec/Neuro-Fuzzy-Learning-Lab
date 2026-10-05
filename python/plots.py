"""Shared classroom figures. PNG for reports; SVG for editable vector graphics."""
from pathlib import Path
import numpy as np
from course_core import classification_metrics, prepare_data


def pyplot():
    # Respect MPLBACKEND; do not force Agg in an interactive application.
    import matplotlib.pyplot as plt
    return plt


def finish(fig, stem, cfg):
    plt = pyplot()
    if cfg.save_results:
        stem = Path(stem)
        stem.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(str(stem)+'.png', dpi=140)
        fig.savefig(str(stem)+'.svg')
    if cfg.show_figures:
        plt.show(block=False)
        plt.pause(.05)
    else:
        plt.close(fig)
    return fig


def preview_dataset(ex, cfg):
    d = prepare_data(**{k:v for k,v in ex.items() if k != 'name'})
    raw = np.loadtxt(ex['path'], delimiter=',', skiprows=1, ndmin=2)
    with open(ex['path'], encoding='utf-8-sig') as f:
        labels = f.readline().strip().split(',')
    X = raw[d['train_idx']][:, ex['features']]
    y = raw[d['train_idx'], ex['target']]
    xlabels = [labels[i] for i in ex['features']]
    print(f"\n{ex['name']} [{ex['task']}]: {len(raw)} ornek, {X.shape[1]} girdi; "
          f"egitim={len(d['train_idx'])}, dogrulama={len(d['val_idx'])}, test={len(d['test_idx'])}")
    print('Gorseller yalnizca egitim verisi. Hedef:', labels[ex['target']])
    print('Girdi sirasi:', ', '.join(xlabels))
    plt = pyplot()
    fig, axes = plt.subplots(1, 3, figsize=(14, 5), layout='constrained', num=None)
    fig.suptitle(ex['name'])
    if ex['task'] == 'regression':
        axes[0].hist(y, bins=20)
        axes[0].set(title='Hedef dagilimi', xlabel=labels[ex['target']], ylabel='Ornek sayisi')
        axes[1].plot(X[:,0], y, '.', ms=4)
        axes[1].set(title='Ilk girdi ve hedef', xlabel=xlabels[0], ylabel=labels[ex['target']])
        with np.errstate(invalid='ignore', divide='ignore'):
            corr = np.corrcoef(np.c_[X,y], rowvar=False)
        im = axes[2].imshow(corr, vmin=-1, vmax=1, cmap='coolwarm')
        axes[2].set(title='Korelasyon: girdiler + hedef', xlabel='Sutun', ylabel='Sutun',
                    xticks=range(len(xlabels)+1), xticklabels=range(1,len(xlabels)+2),
                    yticks=range(len(xlabels)+1), yticklabels=range(1,len(xlabels)+2))
        fig.colorbar(im, ax=axes[2])
        print('Korelasyon kategorik kodlamaya baglidir.')
    else:
        classes = d['classes']
        axes[0].bar([str(c) for c in classes], [np.sum(y==c) for c in classes])
        axes[0].set(title='Sinif dagilimi', xlabel='Sinif', ylabel='Ornek sayisi')
        z = (X-X.mean(0))/np.maximum(X.std(0, ddof=1), 1e-12)
        second = min(1, X.shape[1]-1)
        for c in classes:
            axes[1].plot(X[y==c,0], X[y==c,second], '.', label=f'Sinif {c:g}')
            axes[2].plot(np.arange(X.shape[1])+1, z[y==c].mean(0), '-o', ms=3, label=f'Sinif {c:g}')
        axes[1].set(title='Ilk iki ozellik', xlabel=xlabels[0], ylabel=xlabels[second])
        axes[2].set(title='Siniflarin ozellik profili', xlabel='Ozellik numarasi', ylabel='Standart ortalama')
        axes[1].legend(); axes[2].legend()
    return finish(fig, Path(cfg.output_dir or '.')/'data_preview'/f"{ex['name']}_training", cfg)


def model_plot(stem, data, pred, history, name, is_meta, cfg):
    plt = pyplot()
    isclass = data['task'] == 'classification'
    count = (2 if isclass else 3) + bool(len(history))
    nr, nc = (2, 2) if count == 4 else (1, count)
    fig, ax = plt.subplots(nr, nc, figsize=(13, 6), layout='constrained', squeeze=False)
    ax = ax.ravel(); fig.suptitle(name)
    y = data['ytest']
    if isclass:
        cm = classification_metrics(y,pred,data['classes'])['confusion']
        im = ax[0].imshow(cm, cmap='Blues'); fig.colorbar(im, ax=ax[0])
        for (i,j), v in np.ndenumerate(cm):
            ax[0].text(j,i,str(v),ha='center',va='center', color='white' if v>.5*cm.max() else 'black')
        ax[0].set(title='Karisiklik matrisi (test)', xlabel='Tahmin sinifi', ylabel='Gercek sinif',
                  xticks=range(len(cm)),yticks=range(len(cm)),xticklabels=data['classes'],yticklabels=data['classes'])
        ax[1].bar([str(c) for c in data['classes']],100*np.diag(cm)/np.maximum(cm.sum(1),1))
        ax[1].set(title='Sinif bazinda duyarlilik',xlabel='Sinif',ylabel='Recall (%)',ylim=(0,105))
        print(f'{name}: ciktilar sinif skorudur; kalibre olasilik degildir.')
    else:
        p = pred.ravel(); lo,hi = min(y.min(),p.min()),max(y.max(),p.max())
        ax[0].plot(y,p,'.'); ax[0].plot([lo,hi],[lo,hi],'k--')
        ax[0].set(title='Test: gercek ve tahmin',xlabel='Gercek',ylabel='Tahmin')
        ax[1].plot(y,label='Gercek'); ax[1].plot(p,'--',label='Tahmin'); ax[1].legend()
        ax[1].set(title='Gercek ve tahmin',xlabel='Test ornegi (zaman degildir)',ylabel='Hedef')
        ax[2].hist(p-y,bins=18); ax[2].set(title='Test hata dagilimi',xlabel='Tahmin - gercek',ylabel='Ornek sayisi')
    if len(history):
        a=ax[-1]
        if is_meta:
            a.plot(np.arange(len(history))+1,history)
            a.set(title='Optimizasyon',xlabel='Fitness degerlendirmesi',ylabel='En iyi dogrulama RMSE')
        else:
            a.plot(history[:,0],label='Egitim');a.plot(history[:,1],label='Dogrulama');a.legend()
            a.set(title='Egitim gecmisi',xlabel='Kaydedilen adim',ylabel='Standart / one-hot RMSE')
    else:
        print(f'{name}: iteratif egitim yok; yakinsama egrisi uretilmez.')
    return finish(fig,stem,cfg)


def comparison_plot(stem,data,predictions,names,cfg):
    plt=pyplot();fig,ax=plt.subplots(figsize=(13,6),layout='constrained')
    if data['task']=='regression':
        order=np.argsort(data['ytest'],kind='stable')
        for name,p in zip(names,predictions):ax.plot(p.ravel()[order],label=name,lw=1)
        ax.plot(data['ytest'][order],'k-',lw=2.5,label='Gercek')
        ax.set(title='Test tahminleri',xlabel='Gercek hedefe gore siralanmis test ornegi',ylabel='Hedef')
        print('Ortak grafik: ayni test ornekleri gercek hedefe gore siralandi; zaman serisi degildir.')
    else:
        f1=[]
        for p in predictions:
            cm=classification_metrics(data['ytest'],p,data['classes'])['confusion']
            tp=np.diag(cm);pr=tp/np.maximum(cm.sum(0),1);re=tp/np.maximum(cm.sum(1),1)
            f1.append(2*pr*re/np.maximum(pr+re,np.finfo(float).eps))
        f1=np.asarray(f1);k=len(data['classes']);width=.8/k;x=np.arange(len(names))
        for j,c in enumerate(data['classes']):
            ax.bar(x+(j-(k-1)/2)*width,f1[:,j],width,label=f'Sinif {c:g}')
        ax.set(title='Test: sinif bazinda F1',xticks=x,xticklabels=names,ylabel='F1',ylim=(0,1.05))
        plt.setp(ax.get_xticklabels(),rotation=35,ha='right')
        print('Ortak grafik: sinif bazinda F1; yuksek daha iyi.')
    ax.legend(loc='upper left',bbox_to_anchor=(1,1));ax.grid(alpha=.25)
    return finish(fig,stem,cfg)


def show_results_table(rows):
    for target in dict.fromkeys(r['target'] for r in rows):
        subset=[r for r in rows if r['target']==target]
        isclass=not np.isnan(subset[0]['accuracy'])
        keys=('accuracy','macro_f1','balanced_accuracy') if isclass else ('test_rmse','test_mae','test_r2')
        headers=('Accuracy %','Macro-F1','Bal. acc. %') if isclass else ('Test RMSE','Test MAE','Test R2')
        print(f'\n{target} -- TEST SONUCLARI')
        print(f"{'Model':18s} {'Seed':>5s} "+' '.join(f'{k:>18s}' for k in headers)+f" {'Sure(s)':>10s}")
        for r in subset:
            vals=[r[k]*100 if isclass and k!='macro_f1' else r[k] for k in keys]
            print(f"{r['model']:18s} {r['seed']:5d} "+' '.join(f'{v:18.4f}' for v in vals)+f" {r['seconds']:10.3f}")
