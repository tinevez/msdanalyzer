function delays = getAllDelays(obj, indices)
% First, find all possible delays in time vectors.
% Time can be arbitrary spaced, with frames missings,
% non-uniform sampling, etc... so we have to do this clean.

if nargin < 2 || isempty(indices)
    indices = 1 : numel(obj.tracks);
end

n_tracks = numel(indices);
all_delays = cell(n_tracks, 1);
for i = 1 : n_tracks
    index = indices(i);
    track = obj.tracks{index};
    t = track(:,1);
    [T1, T2] = meshgrid(t, t);
    dT = msdanalyzer.roundn(abs(T1(:)-T2(:)), msdanalyzer.TOLERANCE);
    all_delays{i} = unique(dT);
end
delays = unique( vertcat(all_delays{:}) );
end
