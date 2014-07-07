function obj = addAll(obj, tracks)
%%ADDALL Add specified trajectories to msd analyzer.
%
% obj = obj.addAll(tracks) adds the given tracks the
% msdanalyzer object obj.
%
% Tracks must be specified as a cell array, one array per
% track. Each track array must be of size N x (Ndim+1) where N
% is the number of individual measurements of the particle
% position and Ndim is the dimensionality specified during
% object construction. Track array must be arranged with time
% and space as follow: [ Ti Xi Yi ... ] etc. Time must be
% strictly increasing.
%
% Adding new tracks to an existing object invalidates its
% stored MSD values, and will cause them to be recalculated if
% needed.

tracks = tracks(:);
n_tracks = numel(tracks);

% Check dimensionality & validity
for i = 1 : n_tracks
    track = tracks{i};
    
    % Dimensionality
    track_dim = size(track, 2);
    if track_dim ~= obj.n_dim + 1
        error('msdanalyzer:addAll:BadDimensionality', ...
            'Tracks must be of size N x (nDim+1) with [ T0 X0 Y0 ... ] etc...');
    end
    
    % Non 0-interval
    t = track(:,1);
    if any(diff(t) <= 0)
        error('msdanalyzer:addAll:BadTimeVector', ...
            'Track %d has a time vector which is not strictly increasing.', i);
    end
    
end

% Add to track collection
obj.tracks = [
    obj.tracks;
    tracks
    ];
obj.msd_valid = false;
obj.vcorr_valid = false;

end