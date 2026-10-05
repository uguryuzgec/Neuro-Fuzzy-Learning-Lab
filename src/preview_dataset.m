function f = preview_dataset(ex,cfg)
% Use only training rows for all exploratory plots. Held-out test stays unseen.
d=prepare_data(ex.csv_path,ex.feature_columns,ex.target_column,cfg.split_seed, ...
               ex.categorical_columns,ex.task,ex.split_file);
raw=dlmread(ex.csv_path,',',1,0);X=raw(d.train_idx,ex.feature_columns);y=raw(d.train_idx,ex.target_column);
fid=fopen(ex.csv_path,'r');assert(fid>=0);header=fgetl(fid);fclose(fid);
labels=strsplit(header,',');xlabels=labels(ex.feature_columns);target=labels{ex.target_column};
fprintf('\n%s [%s]: %d ornek, %d ham girdi; egitim=%d, dogrulama=%d, test=%d\n', ...
    ex.name,ex.task,size(raw,1),size(X,2),numel(d.train_idx),numel(d.val_idx),numel(d.test_idx));
fprintf('Gorseller yalnizca egitim verisidir. Hedef: %s\n',target);
f=course_figure([ex.name ' | Veri tanitimi (egitim)'],cfg);
if strcmp(ex.task,'regression')
    subplot(1,3,1);hist(y,20);xlabel(target,'interpreter','none');ylabel('Ornek sayisi');title('Hedef dagilimi');grid on;
    subplot(1,3,2);plot(X(:,1),y,'.','markersize',10);xlabel(xlabels{1},'interpreter','none');ylabel(target,'interpreter','none');title('Ilk girdi ve hedef');grid on;
    subplot(1,3,3);imagesc(corrcoef([X,y]));colorbar;caxis([-1 1]);
    title('Korelasyon: girdiler + hedef');xlabel('Sutun');ylabel('Sutun');
    set(gca,'xtick',1:size(X,2)+1,'ytick',1:size(X,2)+1);
    fprintf('Girdiler: %s\nKorelasyon kategorik kodlamaya baglidir.\n',strjoin(xlabels,', '));
else
    classes=d.classes;counts=zeros(numel(classes),1);
    subplot(1,3,1);
    for c=1:numel(classes),counts(c)=sum(y==classes(c));end
    bar(counts);set(gca,'xtick',1:numel(classes),'xticklabel',arrayfun(@num2str,classes,'UniformOutput',false));
    xlabel('Sinif');ylabel('Egitim ornegi');title('Sinif dagilimi');grid on;
    subplot(1,3,2);hold on;colors=lines(numel(classes));
    for c=1:numel(classes)
        plot(X(y==classes(c),1),X(y==classes(c),2),'.','markersize',12,'color',colors(c,:));
    end
    class_key(classes,colors);
    xlabel(xlabels{1},'interpreter','none');ylabel(xlabels{2},'interpreter','none');title('Ilk iki ozellik');grid on;
    subplot(1,3,3);hold on;
    Z=bsxfun(@rdivide,bsxfun(@minus,X,mean(X,1)),max(std(X,0,1),1e-12));
    for c=1:numel(classes),plot(mean(Z(y==classes(c),:),1),'-o','color',colors(c,:));end
    class_key(classes,colors);
    xlabel('Ozellik numarasi');ylabel('Standartlastirilmis ortalama');title('Siniflarin ozellik profili');grid on;
    fprintf('Ozellik sirasi: %s\n',strjoin(xlabels,', '));
end
stem=fullfile(cfg.output_dir,'data_preview',[ex.name '_training']);
finish_figure(f,stem,cfg);
end

function class_key(classes,colors)
% Keep labels visible in exported PNG/FIG, including Octave gnuplot.
for k=1:numel(classes)
    text(.64,.96-.055*(k-1),sprintf('Sinif %g',classes(k)), ...
        'units','normalized','color',colors(k,:),'backgroundcolor','w', ...
        'fontweight','bold','verticalalignment','top');
end
end

