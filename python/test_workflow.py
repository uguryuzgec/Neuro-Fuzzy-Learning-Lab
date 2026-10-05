"""Integration tests for menus, six datasets, file output and graphics."""
import contextlib,io,json,os,tempfile,unittest
os.environ['MPLBACKEND']='Agg'
from pathlib import Path
from unittest.mock import patch
import numpy as np
import matplotlib.pyplot as plt
from course_core import Config,examples
from run_course import run_stage,STAGES
from run_interactive import run_interactive,parse_selection
from plots import preview_dataset
from replot import replot

class WorkflowTests(unittest.TestCase):
    def tearDown(self):plt.close('all')

    def test_all_models_six_data_no_save(self):
        cfg=Config.for_profile('smoke');cfg.save_results=False
        with tempfile.TemporaryDirectory() as folder,contextlib.redirect_stdout(io.StringIO()):
            cfg.output_dir=str(Path(folder)/'must_not_exist')
            rows=run_stage(0,cfg)
            self.assertEqual(len(rows),72)
            self.assertFalse(Path(cfg.output_dir).exists())
            for r in rows:
                self.assertTrue(np.isfinite(r['val_rmse']))
                self.assertTrue(np.isfinite(r['test_rmse']) or 0<=r['accuracy']<=1)

    def test_save_graphics_and_replot(self):
        cfg=Config.for_profile('smoke');cfg.plots=True
        with tempfile.TemporaryDirectory() as folder,contextlib.redirect_stdout(io.StringIO()):
            cfg.output_dir=folder
            for ex in examples():preview_dataset(ex,cfg)
            self.assertEqual(len(list((Path(folder)/'data_preview').glob('*.svg'))),6)
            rows=run_stage(0,cfg,examples()[2:3]+examples()[5:6],['ELM','ANFIS'])
            out=Path(folder)/'stage_0'
            self.assertEqual(len(list(out.glob('*.png'))),6)
            self.assertEqual(len(list(out.glob('*.svg'))),6)
            self.assertEqual(len(rows),4)
            self.assertFalse(any(out.glob('*comparison*')))
            with patch('matplotlib.pyplot.show'),patch('matplotlib.pyplot.pause'):
                fig=replot(out/'sonar_ELM_seed11.npz')
                self.assertTrue(plt.fignum_exists(fig.number))
            self.assertEqual(json.loads((out/'summary.json').read_text())['results'][0]['model'],'ELM')

    def test_interactive_selection_and_visible_figures(self):
        # no save, classification, Sonar, one model, ELM: exactly two figures
        with patch('builtins.input',side_effect=['2','2','3','1','5']),patch('matplotlib.pyplot.show'),patch('matplotlib.pyplot.pause'),contextlib.redirect_stdout(io.StringIO()):
            rows=run_interactive(cfg=Config.for_profile('smoke'),block=False)
        self.assertEqual(rows[0]['target'],'sonar');self.assertEqual(len(plt.get_fignums()),2)
        plt.close('all')
        with patch('builtins.input',side_effect=['2','1','2','2','5 6']),patch('matplotlib.pyplot.show'),patch('matplotlib.pyplot.pause'),contextlib.redirect_stdout(io.StringIO()):
            rows=run_interactive(cfg=Config.for_profile('smoke'),block=False)
        self.assertEqual([r['model'] for r in rows],['ELM','RVFL'])
        self.assertEqual(rows[0]['target'],'airfoil');self.assertEqual(len(plt.get_fignums()),4)

    def test_selection_validation(self):
        self.assertEqual(parse_selection('4,5 6 4',12,True),[4,5,6])
        self.assertEqual(parse_selection('0',12),[])
        for value in ['1:3','-1','99','1.5','1 0','__import__("os")','']:
            with self.assertRaises(ValueError):parse_selection(value,12,True)
        with self.assertRaises(ValueError):parse_selection('1 2',12)
        self.assertEqual(len(STAGES[0]),12)

    def test_interactive_save_all_models(self):
        with tempfile.TemporaryDirectory() as folder,patch('run_interactive.ROOT',Path(folder)), \
             patch('builtins.input',side_effect=['1','1','1','3']), \
             patch('matplotlib.pyplot.show'),patch('matplotlib.pyplot.pause'), \
             contextlib.redirect_stdout(io.StringIO()):
            rows=run_interactive(1,Config.for_profile('smoke'),block=False)
            self.assertEqual([r['model'] for r in rows],STAGES[1])
            sessions=list((Path(folder)/'results_python').glob('session_*'))
            self.assertEqual(len(sessions),1)
            self.assertEqual(len(list(sessions[0].rglob('*.png'))),8)
            self.assertEqual(len(list(sessions[0].rglob('*.svg'))),8)
            text=(sessions[0]/'stage_1'/'summary.json').read_text()
            self.assertNotIn('NaN',text)
            self.assertIsNone(json.loads(text)['results'][0]['accuracy'])

if __name__=='__main__':unittest.main()
