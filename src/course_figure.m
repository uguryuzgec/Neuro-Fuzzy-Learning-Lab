function f = course_figure(name,cfg)
visibility='off';if cfg.show_figures,visibility='on';end
f=figure('name',name,'numbertitle','off','visible',visibility, ...
         'color','w','position',[80 80 1180 660]);
% Optional headless test override; interactive GUI keeps its chosen toolkit.
if isfield(cfg,'graphics_toolkit') && exist('OCTAVE_VERSION','builtin')
    graphics_toolkit(f,cfg.graphics_toolkit);
end
end
