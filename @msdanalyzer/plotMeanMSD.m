function varargout = plotMeanMSD(obj, ha, errorbar, indices)
%%PLOTMEANMSD Plot the weighted mean of the MSD curves.
%
% obj,plotMeanMSD computes and plots the weighted of all MSD
% curves. See msdanalyzer.getMeanMSD.
%
% obj,plotMeanMSD(ha) plots the curve in the axes with the
% specified handle.
%
% obj,plotMeanMSD(ha, errorbar) where 'errorbar' is a boolean allow
% to specify whether to plot the curve with error bars indicating
% the weighted standard deviation. Default is false.
%
% obj,plotMeanMSD(ha, errorbar, indices) computes and plots the
% mean only fothe MSD curves whose indices are given on the
% 'indices' array.
%
% h = obj,plotMeanMSD(...) returns the handle to the line plotted.
%
% [h, ha] = obj,plotMeanMSD(...) also returns the handle of the
% axes in which the curve was plotted.

if nargin < 4
    indices = [];
end

msmsd = obj.getMeanMSD(indices);

if nargin < 3
    errorbar = false;
    if nargin < 2
        ha = gca;
    end
end

if errorbar
    h = msdanalyzer.errorShade(ha, msmsd(:,1), msmsd(:,2), msmsd(:,3), [0 0 0], false);
    set(h.mainLine, 'LineWidth', 2);
    
else
    h = plot(ha, msmsd(:,1), msmsd(:,2), 'k', ...
        'LineWidth', 2);
end

obj.labelPlotMSD(ha);

if nargout > 0
    varargout{1} = h;
    if nargout > 1
        varargout{2} = ha;
    end
end

end