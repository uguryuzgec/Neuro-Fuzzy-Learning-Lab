function results = run_interactive(stage,cfg)
% Main Octave classroom entry. Console prompts also work from the Octave GUI.
root=setup_course();if nargin<1,stage=0;end
if nargin<2,cfg=course_config('classroom');end
names=stage_models(stage);results=[];
cfg.plots=true;cfg.show_figures=true;
fprintf('\nHIBRIT ZEKI SISTEMLER -- GNU Octave\n');
fprintf('Kayit: 1=Evet (PNG + FIG + MAT + CSV), 2=Hayir, 0=Iptal\n');
choice=ask_selection('Seciminiz: ',2,false);if isequal(choice,0),return;end
cfg.save_results=choice==1;
if cfg.save_results
    cfg.output_dir=new_session_path(root);fprintf('Kayit klasoru: %s\n',cfg.output_dir);
else
    cfg.output_dir='';fprintf('Dosya kaydi kapali; sekiller ekranda acik kalacak.\n');
end
fprintf('\nProblem: 1=Regresyon, 2=Siniflandirma, 0=Iptal\n');
choice=ask_selection('Hangi problem? ',2,false);if isequal(choice,0),return;end
tasks={'regression','classification'};available=find(strcmp({cfg.examples.task},tasks{choice}));
if isempty(available),fprintf('Bu problem icin tanimli veri seti yok.\n');return;end
if numel(available)>1
    for i=1:numel(available),fprintf('%d: %s\n',i,cfg.examples(available(i)).name);end
    choice=ask_selection('Veri seti (0=iptal): ',numel(available),false);
    if isequal(choice,0),return;end
    available=available(choice);
end
cfg.examples=cfg.examples(available);
preview_dataset(cfg.examples,cfg);
fprintf('\nModel calistirma: 1=Tek model, 2=Secilen modeller, 3=Tumu, 0=Iptal\n');
mode=ask_selection('Seciminiz: ',3,false);if isequal(mode,0),return;end
for i=1:numel(names),fprintf('%2d: %s\n',i,names{i});end
if mode~=3
    ids=ask_selection('Model numarasi/numaralari (or. 4 5 6, 0=iptal): ',numel(names),mode==2);
    if isequal(ids,0),return;end
    names=names(ids);
end
fprintf('\nVeri: %s | Modeller: %s\n',cfg.examples.name,strjoin(names,', '));
fprintf('Test sonuclari yalnizca egitim tamamlandiktan sonra hesaplanir.\n');
results=run_stage(stage,cfg,names);
if cfg.save_results,fprintf('\nDosyalar: %s\n',cfg.output_dir);end
fprintf('Tamamlandi. Sekiller acik; sayisal tablo results degiskeninde.\n');
end
