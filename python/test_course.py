"""Run: python -m unittest -v test_course.py"""
import tempfile, unittest
from pathlib import Path
import numpy as np
from course_core import *
from optimizers import optimizer_ga, optimizer_pso

class NumericalTests(unittest.TestCase):
    def setUp(self):
        rng=np.random.default_rng(7);self.X=rng.normal(size=(30,3))
        self.y=(np.sin(self.X[:,0])+.2*self.X[:,1]**2)[:,None]
        self.cfg=Config.for_profile('smoke')

    def numeric_gradient(self,f,theta):
        result=np.zeros_like(theta);h=1e-5
        for k in range(theta.size):
            a=theta.copy();b=theta.copy();a[k]+=h;b[k]-=h
            result[k]=(f(a)-f(b))/(2*h)
        return result

    def test_gradients_scalar_and_multiclass(self):
        for y in [self.y,np.eye(3)[np.arange(30)%3]]:
            o=y.shape[1];rng=np.random.default_rng(1)
            theta=rng.normal(size=3*4+4+4*o+o)*.1
            g=mlp_loss(theta,self.X,y,4,1e-4)[1]
            gn=self.numeric_gradient(lambda t:mlp_loss(t,self.X,y,4,1e-4)[0],theta)
            np.testing.assert_allclose(g,gn,atol=1e-7,rtol=1e-5)
            for order in (0,1):
                m=init_fnn(self.X,3,order,7);m['beta']=ridge_solve(fnn_design(m,self.X)[0],y,1e-4)
                g=fnn_gradient(m,self.X,y,1e-4)[1]
                gn=self.numeric_gradient(lambda t:fnn_gradient(unpack(t,m),self.X,y,1e-4)[0],pack(m))
                np.testing.assert_allclose(g,gn,atol=1e-7,rtol=1e-5)

    def test_rule_stability_and_ridge(self):
        m=init_fnn(self.X,3,1,7);A,w,_=fnn_design(m,np.r_[self.X,np.full((1,3),1e4)])
        self.assertTrue(np.isfinite(w).all());np.testing.assert_allclose(w.sum(1),1)
        A=A[:-1];beta=ridge_solve(A,self.y,1e-4)
        np.testing.assert_allclose(A.T@(A@beta-self.y)+len(A)*1e-4*beta,0,atol=1e-10)

    def test_optimizer_budget_bounds_repeatability(self):
        lo=np.full(5,-3.);hi=-lo;x=np.full(5,2.);opts=dict(population=6,max_evals=101,seed=4)
        for optimizer in (optimizer_ga,optimizer_pso):
            calls=[]
            def objective(z): calls.append(z.copy());return np.sum(z*z)
            a=optimizer(objective,lo,hi,x,opts)
            self.assertEqual(len(calls),101);self.assertEqual(a['evals'],101)
            self.assertTrue(np.all(np.diff(a['history'])<=0));self.assertLess(a['best_cost'],20)
            self.assertTrue(np.all((np.array(calls)>=lo)&(np.array(calls)<=hi)))
            b=optimizer(lambda z:np.sum(z*z),lo,hi,x,opts)
            np.testing.assert_array_equal(a['history'],b['history'])
            self.assertAlmostEqual(a['best_cost'],np.sum(a['best_position']**2))

    def test_data_isolation_and_stratification(self):
        for ex in examples():
            kw={k:v for k,v in ex.items() if k!='name'};d=prepare_data(**kw)
            self.assertEqual(len(np.unique(np.r_[d['train_idx'],d['val_idx'],d['test_idx']])),
                             sum(len(d[k]) for k in ('train_idx','val_idx','test_idx')))
            np.testing.assert_allclose(d['Xtrain'].mean(0),0,atol=1e-12)
            raw=np.loadtxt(ex['path'],delimiter=',',skiprows=1);raw[d['test_idx'][0],ex['features'][0]]=1e6
            if ex['task']=='classification':
                for ids in ('train_idx','val_idx','test_idx'):
                    self.assertEqual(len(np.unique(raw[d[ids],ex['target']])),len(d['classes']))
            else:raw[d['test_idx'][0],ex['target']]=-1e6
            with tempfile.TemporaryDirectory() as folder:
                p=Path(folder)/'changed.csv';np.savetxt(p,raw,delimiter=',',header='header',comments='')
                changed=prepare_data(**dict(kw,path=p))
                np.testing.assert_array_equal(d['Xtrain'],changed['Xtrain'])
                np.testing.assert_array_equal(d['ytrain'],changed['ytrain'])

    def test_metrics_and_meta_reconstruction(self):
        metrics=classification_metrics(np.array([1,2,3]),np.eye(3),np.array([1,2,3]))
        self.assertEqual(metrics['accuracy'],1);self.assertEqual(metrics['macro_f1'],1)
        m=init_fnn(self.X,3,1,7)
        result,search=train_meta_fnn(m,self.X,self.y,self.X,self.y,self.cfg,7,optimizer_pso)
        self.assertAlmostEqual(rmse(predict(result,self.X),self.y),search['best_cost'])

if __name__=='__main__':unittest.main()
