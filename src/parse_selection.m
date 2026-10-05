function [ids,valid] = parse_selection(answer,count,multiple)
% No eval/str2num: input must contain only integer choices and separators.
answer=strtrim(answer); ids=[]; valid=false;
if isempty(answer) || isempty(regexp(answer,'^\d+([ ,;]+\d+)*$','once')),return;end
tokens=regexp(answer,'\d+','match'); ids=cellfun(@str2double,tokens);
if isequal(ids,0),valid=true;return;end
if any(ids<1 | ids>count) || (~multiple && numel(ids)~=1),ids=[];return;end
% Keep the user's order, removing duplicates.
keep=true(size(ids));
for i=2:numel(ids),keep(i)=~any(ids(1:i-1)==ids(i));end
ids=ids(keep);valid=true;
end
