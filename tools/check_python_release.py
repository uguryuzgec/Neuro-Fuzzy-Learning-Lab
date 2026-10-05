"""Generate representative plots and verify shared deterministic baselines."""
import os
os.environ.setdefault('MPLBACKEND','Agg')
import sys,json,csv
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'python'))
from course_core import ROOT,Config,examples
from run_course import run_stage
from plots import preview_dataset
import numpy as np

def main():
    cfg=Config.for_profile('smoke');cfg.plots=True
    cfg.output_dir=str(ROOT/'work'/'python_release_check')
    for ex in examples():preview_dataset(ex,cfg)
    run_stage(0,cfg,[examples()[2],examples()[5]],['MLP','ELM','ANFIS','FNN-PSO'])
    # Compare the same Ridge prediction formula on the same saved splits.
    reference=ROOT/'work'/'six_data_classroom'/'stage_0'/'metrics.csv'
    if reference.exists():
        cfg.plots=False;cfg.save_results=False
        rows=run_stage(0,cfg,names=['Ridge'])
        with reference.open() as f:old={r['target']:r for r in csv.DictReader(f) if r['model']=='Ridge'}
        for r in rows:
            key='accuracy' if np.isfinite(r['accuracy']) else 'test_rmse'
            np.testing.assert_allclose(r[key],float(old[r['target']][key]),rtol=1e-7,atol=1e-8)
        print('CROSS-LANGUAGE RIDGE PASS: six shared datasets')
    print('PYTHON RELEASE GRAPHICS PASS')

if __name__=='__main__':main()
