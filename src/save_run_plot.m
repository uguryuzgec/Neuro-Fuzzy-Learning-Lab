function f = save_run_plot(stem,y,pred,history,model_name,is_meta,data,cfg)
f=course_figure([model_name ' | Test sonuclari'],cfg);
isclass=strcmp(data.task,'classification');
count=3-isclass+~isempty(history);
nr=1;nc=count;if count==4,nr=2;nc=2;end
subplot(nr,nc,1);
if strcmp(data.task,'classification')
    cm=classification_metrics(y,pred,data.classes);imagesc(cm.confusion);colorbar;
    xlabel('Tahmin sinifi');ylabel('Gercek sinif');
    labels=arrayfun(@num2str,data.classes,'UniformOutput',false);
    set(gca,'xtick',1:numel(labels),'ytick',1:numel(labels),'xticklabel',labels,'yticklabel',labels);
    for i=1:numel(labels)
        for j=1:numel(labels)
            ink='k';if cm.confusion(i,j)<.5*max(cm.confusion(:)),ink='w';end
            text(j,i,num2str(cm.confusion(i,j)),'horizontalalignment','center','fontweight','bold','color',ink);
        end
    end
    title('Karisiklik matrisi (test)');
    fprintf('%s: %d test ornegi; ciktilar sinif skorudur, kalibre olasilik degildir.\n',model_name,numel(y));
    subplot(nr,nc,2);recall=diag(cm.confusion)./max(sum(cm.confusion,2),1);
    bar(100*recall);ylim([0 105]);set(gca,'xtick',1:numel(labels),'xticklabel',labels);
    xlabel('Sinif');ylabel('Recall (%)');title('Sinif bazinda duyarlilik');grid on;
else
plot(y,pred,'.','markersize',12); hold on;
limits = [min([y;pred]),max([y;pred])]; plot(limits,limits,'k--');
xlabel('Gercek deger'); ylabel('Tahmin');title('Test: gercek ve tahmin'); grid on;
subplot(nr,nc,2);plot(y,'b-');hold on;plot(pred,'r--');
xlabel('Test ornegi (zaman degildir)');ylabel('Hedef degeri');legend('Gercek','Tahmin');
title('Gercek ve tahmin');grid on;
subplot(nr,nc,3);hist(pred-y,18);xlabel('Tahmin - gercek');ylabel('Ornek sayisi');title('Test hata dagilimi');grid on;
end
if isempty(history)
    fprintf('%s: iteratif egitim yok; yakinsama egrisi uretilmez.\n',model_name);
elseif is_meta
    subplot(nr,nc,count);
    plot(1:numel(history),history,'linewidth',1.6); xlabel('Fitness degerlendirme sayisi');
    ylabel('En iyi dogrulama RMSE (skor olcegi)');title('Optimizasyon'); grid on;
else
    subplot(nr,nc,count);
    plot(history,'linewidth',1.2); xlabel('Kaydedilen egitim adimi');
    ylabel('RMSE (standart / one-hot olcegi)'); legend('Egitim','Dogrulama');title('Egitim gecmisi'); grid on;
end
finish_figure(f,stem,cfg);
end
