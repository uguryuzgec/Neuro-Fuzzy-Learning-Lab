function f=plot_model_comparison(data,predictions,names,dataset,seed,cfg,outdir)
% Identical test samples, separately for each dataset and random seed.
f=course_figure(sprintf('%s | Modeller | seed %d',dataset,seed),cfg);
if strcmp(data.task,'regression')
    [y,order]=sort(data.ytest);hold on;colors=lines(numel(names));
    for j=1:numel(names)
        plot(predictions{j}(order),'color',colors(j,:),'linewidth',1);
    end
    plot(y,'k-','linewidth',2.5);
    comparison_key([names,{'Gercek'}],[colors;0 0 0]);
    xlabel('Gercek hedefe gore siralanmis test ornegi');ylabel('Hedef');
    title('Test tahminleri');grid on;
    fprintf('\nOrtak grafik: tum tahminler gercek hedefe gore ayni sirada; zaman serisi degildir.\n');
else
    scores=zeros(numel(names),numel(data.classes));
    for j=1:numel(names)
        m=classification_metrics(data.ytest,predictions{j},data.classes);
        tp=diag(m.confusion);precision=tp./max(sum(m.confusion,1)',1);
        recall=tp./max(sum(m.confusion,2),1);
        scores(j,:)=(2*precision.*recall./max(precision+recall,eps))';
    end
    bars=bar(scores,'grouped');ylim([0 1.05]);
    colors=lines(numel(data.classes));
    for c=1:numel(bars),set(bars(c),'facecolor',colors(c,:));end
    set(gca,'xtick',1:numel(names),'xticklabel',names,'ticklabelinterpreter','none');
    xtickangle(35);
    comparison_key(arrayfun(@(c)sprintf('Sinif %g',c),data.classes,'UniformOutput',false),colors);
    ylabel('F1');xlabel('Model');title('Test: sinif bazinda F1');grid on;
    fprintf('\nOrtak grafik: sinif bazinda F1 (0-1; yuksek daha iyi). Sinif etiketleri surekli buyukluk degildir.\n');
end
finish_figure(f,fullfile(outdir,sprintf('%s_models_seed%d',dataset,seed)),cfg);
end

function comparison_key(labels,colors)
% Explicit compact color key also survives Octave 11 gnuplot PNG export.
set(gca,'position',[.09 .17 .70 .75]);
for k=1:numel(labels)
    text(1.03,.97-(k-1)*min(.08,.9/numel(labels)),labels{k}, ...
        'units','normalized','color',colors(k,:),'interpreter','none', ...
        'fontweight','bold','clipping','off');
end
end
