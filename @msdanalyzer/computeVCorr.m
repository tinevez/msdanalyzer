function obj = computeVCorr(obj, indices)
%%COMPUTEVCORR Compute velocity autocorrelation.
%
% obj = obj.computeVCorr computes the velocity autocorrelation for all
% the particles trajectories stored in this object. Velocity
% autocorrelation is defined as vc(t) = < v(i+t) x v(i) >, the mean
% being taken over all possible pairs inside a trajectories.
%
% Results are stored in the 'vcorr' field of the returned object.
% The velocity autocorrelation is stored for each particles in a
% cell array, one cell per particle. The array is a double array of
% size N x 4, and is arranged as follow: [dt mean std N ; ...]
% where dt is the delay for the autocorrelation, mean is the mean
% autocorrelation value for this delay, std the standard deviation
% and N the number of points in the average.
%
% obj = obj.computeVCorr(indices) computes the velocity
% autocorrelation only for the particles with the specified
% indices. Use an empty array to take all particles.

obj.vcorr = cell(numel(obj.tracks), 1);

if nargin < 2 || isempty(indices)
    indices = 1 : numel(obj.tracks);
end

% Get instantaneous velocities
velocities = obj.getVelocities(indices);
delays = obj.getAllDelays(indices);
n_delays = numel(delays);
n_tracks = numel(velocities);

fprintf('Computing velocity autocorrelation of %d tracks... ', n_tracks);
fprintf('%4d/%4d', 0, n_tracks);
for i = 1 : n_tracks
    fprintf('\b\b\b\b\b\b\b\b\b%4d/%4d', i, n_tracks);
    
    % Holder for mean, std calculations
    sum_vcorr     = zeros(n_delays-1, 1);
    sum_vcorr2    = zeros(n_delays-1, 1);
    n_vcorr       = zeros(n_delays-1, 1);
    
    % Unwrap data
    vc = velocities{i};
    t = vc(:, 1);
    V = vc(:, 2:end);
    n_detections = size(V, 1);
    
    % First compute velocity correleation at dt = 0 over all tracks
    Vc0     = mean( sum( V.^2, 2) );
    
    % Other dts
    for j = 1 : n_detections - 1
        
        % Delay in physical units
        dt = t(j+1:end) - t(j);
        dt = msdanalyzer.roundn(dt, msdanalyzer.TOLERANCE);
        
        % Determine target delay index in bulk
        [~, index_in_all_delays, ~] = intersect(delays, dt);
        
        % Velocity correlation in bulk
        lvcorr = sum( repmat(V(j, :), [ (n_detections-j) 1]) .* V(j+1:end, :), 2 );
        
        % Normalize
        lvcorr = lvcorr ./ Vc0;
        
        % Store for mean computation
        sum_vcorr(index_in_all_delays)   = sum_vcorr(index_in_all_delays) + lvcorr;
        sum_vcorr2(index_in_all_delays)  = sum_vcorr2(index_in_all_delays) + (lvcorr .^ 2);
        n_vcorr(index_in_all_delays)     = n_vcorr(index_in_all_delays) + 1;
        
    end
    
    mean_vcorr = sum_vcorr ./ n_vcorr;
    std_vcorr = sqrt( (sum_vcorr2 ./ n_vcorr) - (mean_vcorr .* mean_vcorr)) ;
    vcorrelation = [ delays(1:end-1) mean_vcorr std_vcorr n_vcorr ];
    vcorrelation(1,:) = [0 1 0 n_detections];
    
    % Store in object field
    index = indices(i);
    obj.vcorr{index} = vcorrelation;
    
end
fprintf('\b\b\b\b\b\b\b\b\bDone.\n')

obj.vcorr_valid = true;

end