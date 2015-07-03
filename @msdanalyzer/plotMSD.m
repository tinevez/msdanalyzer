function varargout = plotMSD(obj, ha, indices, errorbar)
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
% hps =  obj.plotMSD(...) returns the handle array for the
% lines generated.
%
% [hps, ha] =  obj.plotMSD(...) also return the axes handle in
% which the lines were plotted.

if ~obj.msd_valid
    obj = obj.computeMSD;
end

if nargin < 2
    ha = gca;
end
if nargin < 3 || isempty(indices)
    indices = 1 : numel(obj.msd);
end
if nargin < 4
    errorbar = false;
end

n_spots = numel(indices);
colors = jet(n_spots);

hold(ha, 'on');
if errorbar
else
    hps = NaN(n_spots, 1);
end

for i = 1 : n_spots
    
    index = indices(i);
    
    msd_spot = obj.msd{index};
    if isempty( msd_spot )
        continue
    end
    
    trackName = sprintf('Track %d', index );
    
    t = msd_spot(:,1);
    m = msd_spot(:,2);
    if errorbar
        s = msd_spot(:,3);
        hps(i) = msdanalyzer.errorShade(ha, t, m, s, colors(i,:), true);
        set( hps(i), 'DisplayName', trackName );
    else
        hps(i) = plot(ha, t, m, ...
            'Color', colors(i,:), ...
            'DisplayName', trackName );
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