function msmsd = getMeanMSD(obj, indices)
%%GETMEANMSD Compute the weighted mean of all MSD curves.
%
% msd = obj.getMeanMSD computes and return the weighted mean of all
% MSD curves stored in this object. All possible delays are first
% derived, and for each delay, a weighted mean is computed from all
% the MSD curves stored in this object. Weights are set to be the
% number of points averaged to generate the mean square
% displacement value at the given delay. Thus, we give more weight
% to MSD curves with greater certainty (larger number of elements
% averaged).
%
% Results are returned as a N x 4 double array, and ordered as
% following: [ dT M STD N ] with:
% - dT the delay vector
% - M the weighted mean of MSD for each delay
% - STD the weighted standard deviation
% - N the number of degrees of freedom in the weighted mean
% (see http://en.wikipedia.org/wiki/Weighted_mean)
%
% msd = obj.getMeanMSD(indices) only takes into account the MSD
% curves with the specified indices.

if ~obj.msd_valid
    obj = obj.computeMSD(indices);
end

if nargin < 2 || isempty(indices)
    indices = 1 : numel(obj.msd);
end

n_tracks = numel(indices);

% First, collect all possible delays
all_delays = cell(n_tracks, 1);
for i = 1 : n_tracks
    index = indices(i);
    
    if isempty( obj.msd{index} )
        continue
    end
    all_delays{i} = obj.msd{index}(:,1);
end
delays = unique( vertcat( all_delays{:} ) );
n_delays = numel(delays);

% Collect
sum_weight          = zeros(n_delays, 1);
sum_weighted_mean   = zeros(n_delays, 1);

% 1st pass
for i = 1 : n_tracks
    
    index = indices(i);
    if isempty( obj.msd{index} )
        continue
    end
    
    t = obj.msd{index}(:,1);
    m = obj.msd{index}(:,2);
    n = obj.msd{index}(:,4);
    
    % Do not tak NaNs
    valid = ~isnan(m);
    t = t(valid);
    m = m(valid);
    n = n(valid);
    
    % Find common indices
    [~, index_in_all_delays, ~] = intersect(delays, t);
    
    % Accumulate
    sum_weight(index_in_all_delays)           = sum_weight(index_in_all_delays)         + n;
    sum_weighted_mean(index_in_all_delays)    = sum_weighted_mean(index_in_all_delays)  + m .* n;
end

% Compute weighted mean
mmean = sum_weighted_mean ./ sum_weight;

% 2nd pass: unbiased variance estimator
sum_weighted_variance = zeros(n_delays, 1);
sum_square_weight     = zeros(n_delays, 1);

for i = 1 : n_tracks
    
    index = indices(i);
    if isempty( obj.msd{index} )
        continue
    end
    
    t = obj.msd{index}(:,1);
    m = obj.msd{index}(:,2);
    n = obj.msd{index}(:,4);
    
    % Do not tak NaNs
    valid = ~isnan(m);
    t = t(valid);
    m = m(valid);
    n = n(valid);
    
    % Find common indices
    [~, index_in_all_delays, ~] = intersect(delays, t);
    
    % Accumulate
    sum_weighted_variance(index_in_all_delays)    = sum_weighted_variance(index_in_all_delays)  + n .* (m - mmean(index_in_all_delays)).^2 ;
    sum_square_weight(index_in_all_delays)        = sum_square_weight(index_in_all_delays)      + n.^2;
end

% Standard deviation
mstd = sqrt( sum_weight ./ (sum_weight.^2 - sum_square_weight) .* sum_weighted_variance );

% Output [ T mean std Nfreedom ]
msmsd = [ delays mmean mstd (sum_weight.^2 ./ sum_square_weight) ];

end