function varargout = plotTracks(obj, ha, indices, corrected)
%%PLOTTRACKS Plot the tracks stored in this object.
%
% obj.plotTracks plots the particle trajectories stored in the
% msdanalyzer object obj in the current axes. This method only
% works for 2D or 3D problems.
%
% obj.plotTracks(ha) plots the trajectories in the axes with
% handle ha.
%
% obj.plotTracks(ha, indices) where indices is a vector, allows
% to specify the track to be plotted, using their indices.
% Leave the vector empty to plot all trajectories.
%
% obj.plotTracks(ha, indices, corrected) where corrected is a a
% boolean flag, allows to specify whether the plot should
% display the trajectories corrected for drift (true) or
% uncorrected (false). A proper drift vector must be computed
% prior to setting this flag to true. See
% msdanalyzer.computeDrift.
%
% hps = obj.plotTracks(...) returns the handles to the
% individual line objects created.
%
% [hps, ha] = obj.plotTracks(...) returns also the handle to
% the axes handle the trajectories are plot in.

if obj.n_dim < 2 || obj.n_dim > 3
    error('msdanalyzer:plotTracks:UnsupportedDimensionality', ...
        'Can only plot tracks for 2D or 3D problems, got %dD.', obj.n_dim);
end

if nargin < 2
    ha = gca;
end
if nargin < 3 || isempty(indices)
    indices = 1 : numel(obj.tracks);
end
if nargin < 4
    corrected = false;
end

n_tracks = numel(indices);
colors = jet(n_tracks);

hold(ha, 'on');
hps = NaN(n_tracks, 1);

if obj.n_dim == 2
    % 2D case
    for i = 1 : n_tracks
        
        index = indices(i);
        track = obj.tracks{index};
        trackName = sprintf('Track %d', index );
        
        x = track(:,2);
        y = track(:,3);
        
        if corrected && ~isempty(obj.drift)
            tdrift = obj.drift(:,1);
            xdrift = obj.drift(:, 2);
            ydrift = obj.drift(:, 3);
            t = track(:,1);
            [~, index_in_drift_time, ~] = intersect(tdrift, t);
            % Subtract drift position to track position
            x = x - xdrift(index_in_drift_time);
            y = y - ydrift(index_in_drift_time);
        end
        
        hps(i) =  plot(ha, x, y, ...
            'Color', colors(i,:), ...
            'DisplayName', trackName );
        
    end
    
else
    % 3D case
    for i = 1 : n_tracks
        
        index = indices(i);
        track = obj.tracks{index};
        trackName = sprintf('Track %d', index );
        
        x = track(:,2);
        y = track(:,3);
        z = track(:,4);
        
        if corrected && ~isempty(obj.drift)
            tdrift = obj.drift(:,1);
            xdrift = obj.drift(:, 2);
            ydrift = obj.drift(:, 3);
            zdrift = obj.drift(:, 4);
            t = track(:,1);
            [~, index_in_drift_time, ~] = intersect(tdrift, t);
            % Subtract drift position to track position
            x = x - xdrift(index_in_drift_time);
            y = y - ydrift(index_in_drift_time);
            z = z - zdrift(index_in_drift_time);
        end
        
        hps(i) =  plot3(ha, x, y, z, ...
            'Color', colors(i,:), ...
            'DisplayName', trackName );
        
    end
    
end

% Output
if nargout > 0
    varargout{1} = hps;
    if nargout > 1
        varargout{2} = ha;
    end
end

end