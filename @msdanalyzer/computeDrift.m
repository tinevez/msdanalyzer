function obj = computeDrift(obj, method, extra, interpmethod)
%%COMPUTEDRIFT Compute and store drift correction.
%
% obj = obj.computeDrift(method) computes and stores the drift
% using one of the 4 following methods:
%
% 'clear' does not compute drift and remove any prior drift
% computation results.
%
% 'manual' allow to specify manually the drift vector:
% obj = obj.computeDrift('manual', dv); where dv is a double array
% of size N x (nDim+1) (nDim being the problem dimensionality), and
% must be arranged as following: [ Ti Xi Yi ... ] etc...
% On top of this, the drift vector must cover all the possible time
% points specified in the tracks field of this object: It must
% start before the first point and end after the last one,
% otherwise an error is thrown.
%
% Missing values within these extremities are interpolated using a
% linear interpolation scheme by default. To specify another
% interpolation scheme, use the following syntax:
% obj.computeDrift('manual', dv, interpmethod), with interpmethod
% being any value accepted by interp1 ('linear', 'nearest',
% 'spline', 'pchip', 'cubic').
%
% 'centroid' derives the drift by computing the center of mass of
% all particles at each time point. This method best work for a
% large number of particle and when the same number of particles is
% found at every time points. It fails silently otherwise.
%
% 'velocity' derives drift by computing instantaneous velocities
% and averaging them all together, at each time point. If the
% particles are in sufficient number, and if their real movement is
% indeed uncorrelated, the uncorrelated part will cancel when
% averaging, leaving only the correlated part. We assume this part
% is due to the drift. This method is more robust than the
% 'centroid' method against particle disappearance and appearance.
%
% Results are stored in the 'drift' field of the returned object.
% It is a double array of size N x (nDim+1) (nDim being the problem
% dimensionality), and must be arranged as following: [ Ti Xi Yi ... ]
% etc. If present, it will by used for any call to computeMSD and
% computeVCorr methods.


% First compute common time points
time = obj.getCommonTimes();
n_times = numel(time);
n_tracks = numel(obj.tracks);

switch lower(method)
    
    case 'manual'
        
        if nargin < 4
            interpmethod = 'linear';
        end
        
        drift_dim = size(extra, 2);
        if drift_dim ~= obj.n_dim + 1
            error('msdanalyzer:computeDrift:BadDimensionality', ...
                'Drift must be of size N x (nDim+1) with [ T0 X0 Y0 ... ] etc...');
        end
        
        uninterpolated_time = extra(:, 1);
        uninterpolated_drift = extra(:, 2:end);
        if min(uninterpolated_time) > min(time) || max(uninterpolated_time) < max(time)
            error('msdanalyzer:computeDrift:BadTimeVector', ...
                'For manual drift correction, time vector must cover all time vector from all tracks.');
        end
        
        ldrift = interp1(...
            uninterpolated_time, ...
            uninterpolated_drift, ...
            time, interpmethod);
        
        obj.drift = [time ldrift];
        
    case 'centroid'
        
        ldrift = zeros(n_times, obj.n_dim);
        n_drift = zeros(n_times, 1);
        for i = 1 : n_tracks
            
            t = obj.tracks{i}(:,1);
            t = msdanalyzer.roundn(t, msdanalyzer.TOLERANCE);
            
            % Determine target time index in bulk
            [~, index_in_all_tracks_time, ~] = intersect(time, t);
            
            % Add to mean accum for these indexes
            n_drift(index_in_all_tracks_time) = n_drift(index_in_all_tracks_time) + 1;
            ldrift(index_in_all_tracks_time, :) = ldrift(index_in_all_tracks_time, :) + obj.tracks{i}(:, 2:end);
            
        end
        
        ldrift = ldrift ./ repmat(n_drift, [1 obj.n_dim]);
        obj.drift = [time ldrift];
        
        
    case 'velocity'
        
        sum_V = zeros(n_times, obj.n_dim);
        n_V = zeros(n_times, 1);
        
        for i = 1 : n_tracks
            
            t = obj.tracks{i}(:,1);
            t = msdanalyzer.roundn(t, msdanalyzer.TOLERANCE);
            
            % Determine target time index in bulk
            [~, index_in_all_tracks_time, ~] = intersect(time, t);
            
            % Remove first element
            index_in_all_tracks_time(1) = [];
            
            % Compute speed
            V = diff( obj.tracks{i}(:, 2:end) ) ./ repmat(diff(t), [ 1 obj.n_dim]);
            
            % Add to mean accum for these indexes
            n_V(index_in_all_tracks_time) = n_V(index_in_all_tracks_time) + 1;
            sum_V(index_in_all_tracks_time, :) = sum_V(index_in_all_tracks_time, :) + V;
            
        end
        
        % Build accumulated drift
        sum_V(1, :) = 0;
        n_V(1, :) = 1;
        % Integrate
        d_time = [0; diff(time) ];
        ldrift = cumsum( sum_V ./ repmat(n_V, [1 obj.n_dim]) .* repmat(d_time, [1 obj.n_dim]), 1);
        obj.drift = [time ldrift];
        
    case 'clear'
        
        obj.drift = [];
        
        
    otherwise
        error('msdanalyzer:computeDriftCorrection:UnknownCorrectionMethod', ...
            'Unknown correction method %s. Must be ''clear'', ''manual'', ''centroid'' or ''velocity''.', ...
            method);
end

obj.msd_valid = false;
obj.vcorr_valid = false;

end