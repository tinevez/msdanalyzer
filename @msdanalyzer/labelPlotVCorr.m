function varargout = labelPlotVCorr(obj, ha)
%%LABELPLOTVCORR A convenience method to set the axes labels.
%
% obj.labelPlotVCorr(ha) sets the axis label of the axes with
% the specified handle ha. It is meant for axes containing the
% plot of the velocity autocorrelation.
%
% hl = obj.labelPlotVCorr(...) returns the handle to the generated
% labels.
%
% [hl, hline] = obj.labelPlotVCorr(...) also returns the handle
% to generate y=0 dashed line.

if nargin < 2
    ha = gca;
end

hl = NaN(2, 1);
hl(1) = xlabel(ha, ['Delay (' obj.time_units ')']);
hl(2) = ylabel(ha, 'Normalized velocity autocorrelation');


xl = xlim(ha);
xlim(ha, [0 xl(2)]);
box(ha, 'off')

hline = line([0 xl(2)], [0 0], ...
    'Color', 'k', ...
    'LineStyle', '--');
uistack(hline, 'bottom')

if nargout > 0
    varargout{1} = hl;
    if nargout > 1
        varargout{2} = hline;
    end
end
end