function varargout = plotMeanVCorr(obj, ha, errorbar, indices)
%%PLOTMEANVCORR Plot the weighted mean of the velocity autocorrelation curves.
%
% obj,plotMeanVCorr computes and plots the weighted of all velocity
% autocorrelation curves. See msdanalyzer.getMeanVCorr.
%
% obj,plotMeanVCorr(ha) plots the curve in the axes with the
% specified handle.
%
% obj,plotMeanVCorr(ha, errorbar) where 'errorbar' is a boolean
% allow to specify whether to plot the curve with error bars
% indicating the weighted standard deviation. Default is false.
%
% obj,plotMeanVCorr(ha, errorbar, indices) computes and plots the
% mean only fothe velocity autocorrelation curves whose indices are
% given on the 'indices' array.
%
% h = obj,plotMeanVCorr(...) returns the handle to the line plotted.
%
% [h, ha] = obj,plotMeanVCorr(...) also returns the handle of the
% axes in which the curve was plotted.

if nargin < 4
    indices = [];
    
    if nargin < 3
        errorbar = false;
        if nargin < 2
            ha = gca;
        end
    end
end
mvc = obj.getMeanVCorr(indices);

if errorbar
    h = msdanalyzer.errorShade(ha, mvc(:,1), mvc(:,2), mvc(:,3), [0 0 0], false);
    set(h.mainLine, 'LineWidth', 2);
    
else
    h = plot(ha, mvc(:,1), mvc(:,2), 'k', ...
        'LineWidth', 2);
end

obj.labelPlotVCorr(ha);

if nargout > 0
    varargout{1} = h;
    if nargout > 1
        varargout{2} = ha;
    end
end

end