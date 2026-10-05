"""Create a clean, portable GitHub upload ZIP from an explicit allowlist.

Run from any directory: python tools/build_release.py
Existing work/results/environments are never modified or included.
"""
from pathlib import Path
from datetime import datetime
import hashlib,json,zipfile

ROOT=Path(__file__).resolve().parents[1]

def build():
    files=[p for p in ROOT.iterdir() if p.is_file() and (p.suffix in ('.m','.md') or p.name=='.gitignore')]
    for dirname,extensions in [('src',{'.m'}),('tests',{'.m'}),('python',{'.py','.txt'}),
                               ('data',{'.csv','.json','.md','.m','.ps1'}),('tools',{'.py'})]:
        files += [p for p in (ROOT/dirname).iterdir() if p.is_file() and p.suffix in extensions]
    required=['README.md','KULLANIM_KILAVUZU.md','PYTHON_KULLANIM_KILAVUZU.md','run_interactive.m','python/run_interactive.py']
    rels={p.relative_to(ROOT).as_posix() for p in files}
    assert set(required)<=rels
    assert len([r for r in rels if r.startswith('data/') and r.endswith('.csv')])==12
    dist=ROOT/'dist';dist.mkdir(exist_ok=True)
    target=dist/('hybrid-intelligent-systems_'+datetime.now().strftime('%Y%m%d_%H%M%S')+'.zip')
    manifest={}
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(files):
            rel=p.relative_to(ROOT).as_posix();payload=p.read_bytes()
            z.writestr(rel,payload);manifest[rel]=hashlib.sha256(payload).hexdigest()
        z.writestr('MANIFEST.sha256.json',json.dumps(manifest,indent=2))
    with zipfile.ZipFile(target) as z:
        assert z.testzip() is None
        for name,digest in manifest.items():assert hashlib.sha256(z.read(name)).hexdigest()==digest
    print(target)
    print(f'{len(files)} files + manifest; {target.stat().st_size} bytes; SHA256 {hashlib.sha256(target.read_bytes()).hexdigest()}')
    return target

if __name__=='__main__':build()
