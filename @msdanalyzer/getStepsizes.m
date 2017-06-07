function [stepsizesXY, stepsizesR] = getStepsizes(obj, indices)
%%GETSTEPSIZES Generate and return the step sizes.
%
% [stepsizesXY, stepsizesR] = obj.getStepsizes returns the step sizes 
% calculated over all the particles tracjectories stored in this object.
% The step sizes are corrected for drift if this object holds a proper
% drift field.
%
% stepsizesXY is a cell array, one cell per particle. Arrays are N x
% (Ndim+1) double arrays, with Ndim the dimensionality set at object
% creation. Data is organized as follow:  [ Ti Xi Yi ... ].
% 
% dR = obj.getStepsizes(indices) restrict the calculation over only
% the particles with specified indices. Use an empty array to use
% take all.
% 
% Note: This function is not present in the original msdAnalyzer package,
% but is adapted from getVelocities.

if nargin < 2 || isempty(indices)
    indices = 1 : numel(obj.tracks);
end

n_tracks = numel(indices);
stepsizesXY = cell(n_tracks, 1);
stepsizesR = cell(n_tracks, 1);

for i = 1 : n_tracks
    
    index = indices(i);
    
    t = obj.tracks{index}(:, 1);
    XY = obj.tracks{index}(:, 2:end);
    
    % Determine drift correction
    if ~isempty(obj.drift)
        tdrift = obj.drift(:, 1);
        xdrift = obj.drift(:, 2:end);
        % Determine target delay index in bulk
        [~, index_in_drift_time, index_in_track_time] = intersect(tdrift, t);
        % Keep only track times that can be corrected.
        XY = XY(index_in_track_time, :);
        t = t(index_in_track_time);
        % Subtract drift position to track position
        XY = XY - xdrift(index_in_drift_time, :);
        
    end
    
    dXY = diff(XY, 1);
    stepsizesXY{i} = [ t(1:end-1) dXY];
    stepsizesR{i} = [ t(1:end-1) sqrt( sum( dXY.^2 ,2) )]; % Calculate distance
end

end