function SDdts = getSDdt(obj, indices)
%%getSDdt Generate and return the square displacement per unit of time for
% each step. 
%
% SDdts = obj.getSDdt returns in SDdts the square displacement per unit of
% time for each step, calculated over all the particles tracjectories
% stored in this object. The step sizes are corrected for drift if this
% object holds a proper drift field. 
%
% This method returns a cell array, one cell per particle. Arrays
% are N x (Ndim+1) double arrays, with Ndim the dimensionality set
% at object creation. Data is organized as follow:  [ Ti SDdti ].
%
% SDdts = obj.getStepsizes(indices) restrict the calculation over only
% the particles with specified indices. Use an empty array to use
% take all.

if nargin < 2 || isempty(indices)
    indices = 1 : numel(obj.tracks);
end

n_tracks = numel(indices);
SDdts = cell(n_tracks, 1);

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
    
    dX = diff(X, 1);
    dt=diff(t, 1);
    SD=sum(dX.^2,2);
    SDdts{i} = [ t(1:end-1) SD./dt];
    
end

end