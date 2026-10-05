function finish_figure(f,stem,cfg)
% PNG is a rendered image; FIG stores editable Octave graphics objects.
% Octave FIG is not guaranteed to be interchangeable with MATLAB FIG.
drawnow();
% Octave may inherit invisible state for legends in headless exports.
legends=findall(f,'tag','legend');
for k=1:numel(legends),set(legends(k),'visible','on');end
if cfg.save_results
    folder=fileparts(stem);if ~exist(folder,'dir'),mkdir(folder);end
    % Octave 11 bar baselines store a private cleanup callback which cannot
    % resolve after openfig. Omit only that callback from the saved snapshot;
    % restore it immediately on the live figure (also if savefig fails).
    handles=[];callbacks={};
    if exist('OCTAVE_VERSION','builtin')
        objects=findall(f);
        for j=1:numel(objects)
            cb=get(objects(j),'deletefcn');
            if iscell(cb) && ~isempty(cb) && isa(cb{1},'function_handle') && strcmp(func2str(cb{1}),'rm_axes_listeners')
                handles(end+1)=objects(j);callbacks{end+1}=cb;
                set(objects(j),'deletefcn',[]);
            end
        end
    end
    restore=onCleanup(@() restore_callbacks(handles,callbacks));
    savefig(f,[stem '.fig']);
    clear restore;
    set(f,'paperpositionmode','auto');
    print(f,[stem '.png'],'-dpng','-r120');
end
if cfg.show_figures
    set(f,'visible','on');drawnow();
else
    close(f);
end
end

function restore_callbacks(handles,callbacks)
for j=1:numel(handles)
    if ishghandle(handles(j)),set(handles(j),'deletefcn',callbacks{j});end
end
end
