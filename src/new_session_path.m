function path = new_session_path(root)
% Merely choose a name. This function does not create a directory.
base=fullfile(root,'results',['session_' datestr(now,'yyyymmdd_HHMMSS_FFF')]);
path=base;i=1;
while exist(path,'dir'),path=sprintf('%s_%d',base,i);i=i+1;end
end
