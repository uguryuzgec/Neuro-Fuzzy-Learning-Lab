"""Unpack a generated release into a fresh temp directory and test portability."""
from pathlib import Path
import os,sys,tempfile,zipfile,subprocess,json,hashlib

def verify(archive):
    with tempfile.TemporaryDirectory(prefix='hyz_release_') as folder:
        root=Path(folder)
        with zipfile.ZipFile(archive) as z:
            for name in z.namelist():
                dest=(root/name).resolve()
                if not dest.is_relative_to(root.resolve()):raise ValueError('Unsafe ZIP path')
                if any(part in {'.venv','__pycache__','work','results','results_python','.git'} for part in Path(name).parts):
                    raise ValueError('Unexpected local artifact')
            manifest=json.loads(z.read('MANIFEST.sha256.json'))
            for name,digest in manifest.items():
                assert hashlib.sha256(z.read(name)).hexdigest()==digest
            z.extractall(root)
        env=dict(os.environ,MPLBACKEND='Agg',OPENBLAS_NUM_THREADS='1',PYTHONPATH='')
        subprocess.run([sys.executable,'-m','unittest','discover','-s','python','-p','test_*.py','-v'],cwd=root,env=env,check=True)
        print('CLEAN RELEASE PASS:',archive)

if __name__=='__main__':verify(Path(sys.argv[1]).resolve())
