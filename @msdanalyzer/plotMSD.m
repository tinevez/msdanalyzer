function varargout = plotMSD(obj, ha, indices, errorbar, hideZero)
%% PLOTMSD Plot the mean square displacement curves.
%
% obj.plotMSD plots the MSD curves in the current axes.
%
% obj.plotMSD(ha) plots the MSD curves in the axes
% specified by the handle ha.
%
% obj.plotMSD(ha, indices) plots the MSD curves for the
% particles with the specified indices only. Leave empty to
% plot MSD for all particles.
%
% obj.plotMSD(ha, indices, errorbar), where errorbar is a
% boolean flag, allows to specify whether the curves should be
% plotted with error bars (equal to standard deviation). It is
% false by default.
%
% obj.plotMSD(ha, indices, errorbar,hideZero), where hideZero is a
% boolean flag, allows to specify whether a the point corresponding to
% (0,0) should be included in the plotted tracks. Hiding them can be useful
% in case when plotting tracks from pooled datasets with different time
% intervals. Default is false, the (0,0) points are plotted.
%
% hps =  obj.plotMSD(...) returns the handle array for the
% lines generated.
%
% [hps, ha] =  obj.plotMSD(...) also return the axes handle in
% which the lines were plotted.

if ~obj.msd_valid
    obj = obj.computeMSD;
end

if nargin < 2 || isempty(ha)
    ha = gca;
end
if nargin < 3 || isempty(indices)
    indices = 1 : numel(obj.msd);
end
if nargin < 4 || isempty(errorbar)
    errorbar = false;
end
if nargin < 5
    hideZero = false;
end

n_spots = numel(indices);
colors = jet(n_spots);

hold(ha, 'on');
if errorbar
else
    hps = NaN(n_spots, 1);
end

for idx = 1 : n_spots
    
    index = indices(idx);
    
    msd_spot = obj.msd{index};
    if isempty( msd_spot )
        continue
    end
    
    trackName = sprintf('Track %d', index );
    
    if hideZero && isequal(msd_spot(1,1:2), [0 0])
        t = msd_spot(2:end,1);
        m = msd_spot(2:end,2);
    else
        t = msd_spot(:,1);
        m = msd_spot(:,2);
    end
    if ~sum(~isnan(m))
        warning(['No msd for spot ' num2str(idx)])
        continue
    end
    if errorbar
        s = msd_spot(:,3);
        hps(idx) = msdanalyzer.errorShade(ha, t, m, s, colors(idx,:), true);
        set( hps(idx), 'DisplayName', trackName );
    else
        hps(idx) = plot(ha, t(~isnan(m)), m(~isnan(m)), ...
            'Color', colors(idx,:), ...
            'DisplayName', trackName); %, 'Marker','+','MarkerSize',2
    end
    
end

obj.labelPlotMSD(ha);

if nargout > 0
    varargout{1} = hps;
    if nargout > 1
        varargout{2} = ha;
    end
end
end