function velocities = getVelocities(obj, indices)
%%GETVELOCITIES Generate and return the instantaneous velocities.
%
% v = obj.getVelocities returns in v the instantaneous velocities
% calculated over all the particles tracjectories stored in this
% object, using dX/dt. The velocities are corrected for drift if
% this object holds a proper drift field.
%
% This method returns a cell array, one cell per particle. Arrays
% are N x (Ndim+1) double arrays, with Ndim the dimensionality set
% at object creation. Data is organized as follow:  [ Ti Vxi Vyi ... ].
%
% v = obj.getVelocities(indices) restrict the calculation over only
% the particles with specified indices. Use an empty array to use
% take all.

if nargin < 2 || isempty(indices)
    indices = 1 : numel(obj.tracks);
end

n_tracks = numel(indices);
velocities = cell(n_tracks, 1);

for i = 1 : n_tracks
    
    index = indices(i);
    
    t = obj.tracks{index}(:, 1);
    X = obj.tracks{index}(:, 2:end);
    
    % Determine drift correction
    if ~isempty(obj.drift)
        tdrift = obj.drift(:, 1);
        xdrift = obj.drift(:, 2:end);
        % Determine target delay index in bulk
        [~, index_in_drift_time, index_in_track_time] = intersect(tdrift, t);
        % Keep only track times that can be corrected.
        X = X(index_in_track_time, :);
        t = t(index_in_track_time);
        % Subtract drift position to track position
        X = X - xdrift(index_in_drift_time, :);
        
    end
    
    dX = diff(X, 1) ./ repmat(diff(t), [1 obj.n_dim]);
    velocities{i} = [ t(1:end-1) dX];
end

end