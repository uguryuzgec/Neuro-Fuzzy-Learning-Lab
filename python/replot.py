"""Recreate an interactive model plot from trusted numeric NPZ + JSON outputs."""
import argparse,json
from pathlib import Path
import numpy as np
from course_core import Config
from plots import model_plot,pyplot

def replot(path):
    path=Path(path)
    meta=json.loads(path.with_suffix('.json').read_text(encoding='utf-8'))
    with np.load(path,allow_pickle=False) as a:
        data=dict(task=meta['preprocessing']['task'],classes=np.array(meta['preprocessing']['classes']),ytest=a['ytest'])
        fig=model_plot(path.with_suffix(''),data,a['pred'],a['history'],meta['name'],meta['is_meta'],Config(save_results=False))
    return fig

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('npz_file');args=parser.parse_args()
    replot(args.npz_file);pyplot().show()
