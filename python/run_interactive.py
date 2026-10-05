"""Interactive classroom entry: python run_interactive.py."""
from dataclasses import replace
from datetime import datetime
from pathlib import Path
import argparse
import re
from course_core import Config, ROOT, examples
from run_course import STAGES, run_stage
from plots import preview_dataset, pyplot


def parse_selection(value, maximum, multiple=False):
    value=value.strip()
    if value=='0':return []
    if not re.fullmatch(r'[0-9]+(?:[ ,;]+[0-9]+)*',value):raise ValueError('Gecersiz secim')
    ids=list(dict.fromkeys(int(v) for v in re.split(r'[ ,;]+',value)))
    if any(i<1 or i>maximum for i in ids) or (not multiple and len(ids)!=1):
        raise ValueError('Secim aralik disinda veya birden fazla secim girildi')
    return ids


def ask(prompt,maximum,multiple=False):
    while True:
        try:return parse_selection(input(prompt),maximum,multiple)
        except ValueError as error:print(error)


def run_interactive(stage=0,cfg=None,datasets=None,block=True):
    cfg=replace(cfg or Config(),plots=True,show_figures=True)
    datasets=examples() if datasets is None else datasets
    names=STAGES[stage]
    print('\nHIBRIT ZEKI SISTEMLER -- Python')
    print('Kayit: 1=Evet (PNG + SVG + NPZ + JSON + CSV), 2=Hayir, 0=Iptal')
    try:
        answer=ask('Seciminiz: ',2)
        if not answer:return []
        cfg.save_results=answer==[1]
        cfg.output_dir=str(ROOT/'results_python'/('session_'+datetime.now().strftime('%Y%m%d_%H%M%S_%f'))) if cfg.save_results else ''
        print('Problem: 1=Regresyon, 2=Siniflandirma, 0=Iptal')
        answer=ask('Hangi problem? ',2)
        if not answer:return []
        task=('regression','classification')[answer[0]-1]
        available=[e for e in datasets if e['task']==task]
        if not available:print('Bu problem icin veri yok.');return []
        for i,e in enumerate(available,1):print(f"{i}: {e['name']}")
        index=ask('Veri seti (0=iptal): ',len(available)) if len(available)>1 else [1]
        if not index:return []
        selected=available[index[0]-1]
        preview_dataset(selected,cfg)
        print('Model calistirma: 1=Tek model, 2=Secilen modeller, 3=Tumu, 0=Iptal')
        mode=ask('Seciminiz: ',3)
        if not mode:return []
        for i,name in enumerate(names,1):print(f'{i}: {name}')
        if mode!=[3]:
            ids=ask('Model numaralari (or. 4 5 6, 0=iptal): ',len(names),mode==[2])
            if not ids:return []
            names=[names[i-1] for i in ids]
        rows=run_stage(stage,cfg,[selected],names)
        if cfg.save_results:print('Dosyalar:',cfg.output_dir)
        print('Tamamlandi. Grafik pencerelerini kapatinca program sona erer.')
        if block:pyplot().show(block=True)
        return rows
    except (EOFError,KeyboardInterrupt):
        print('\nIslem iptal edildi.');return []


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--stage',type=int,choices=range(4),default=0)
    parser.add_argument('--profile',choices=['smoke','classroom','repeated'],default='classroom')
    args=parser.parse_args()
    run_interactive(args.stage,Config.for_profile(args.profile))
