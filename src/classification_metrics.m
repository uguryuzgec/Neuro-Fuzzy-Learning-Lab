function metrics = classification_metrics(y,scores,classes)
assert(all(isfinite(scores(:)))); [~,idx]=max(scores,[],2); predicted=classes(idx);
K=numel(classes); cm=zeros(K);
for i=1:numel(y)
    a=find(classes==y(i));b=find(classes==predicted(i));cm(a,b)=cm(a,b)+1;
end
tp=diag(cm); recall=tp./max(sum(cm,2),1); precision=tp./max(sum(cm,1)',1);
f1=2*precision.*recall./max(precision+recall,eps);
metrics.accuracy=mean(y==predicted);metrics.macro_f1=mean(f1);
metrics.balanced_accuracy=mean(recall);metrics.confusion=cm;
end
