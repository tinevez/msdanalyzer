function time = getCommonTimes(obj)

n_tracks = numel(obj.tracks);
times = cell(n_tracks, 1);
for i = 1 : n_tracks
    times{i} = obj.tracks{i}(:,1);
end
time = unique( vertcat(times{:}) );
time = msdanalyzer.roundn(time, msdanalyzer.TOLERANCE);

end