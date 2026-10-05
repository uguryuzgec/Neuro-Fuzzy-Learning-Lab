function plot_text_lines(lines,font_size)
% Separate text objects also render reliably through Octave's gnuplot backend.
axis([0 1 0 1]);axis off;
step=min(.095,.90/max(numel(lines)-1,1));
for k=1:numel(lines)
    text(0,.96-(k-1)*step,lines{k},'verticalalignment','top', ...
         'interpreter','none','fontsize',font_size);
end
end
