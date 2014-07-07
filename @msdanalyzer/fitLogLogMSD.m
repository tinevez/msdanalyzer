function obj = fitLogLogMSD(obj, clip_factor)
%%FITLOGLOGMSD Fit the log-log MSD to determine behavior.
%
% obj = obj.fitLogLogMSD fits each MSD curve stored in this object
% in a log-log fashion. If x = log(delays) and y = log(msd) where
% 'delays' are the delays at which the msd is calculated, then this
% method fits y = f(x) by a straight line y = alpha * x + gamma, so
% that we approximate the MSD curves by MSD = gamma * delay^alpha.
% By default, only the first 25% of each MSD curve is considered
% for the fit,
%
% Results are stored in the 'loglogfit' field of the returned
% object. It is a structure with 3 fields:
% - alpha: all the values for the slope of the log-log fit.
% - gamma: all the values for the value at origin of the log-log fit.
% - r2fit: the adjusted R2 value as a indicator of the goodness of
% the fit.
%
% obj = obj.fitLogLogMSD(clip_factor) does the fit, taking into
% account only the first potion of each MSD curve specified by
% 'clip_factor' (a double between 0 and 1). If the value
% exceeds 1, then the clip factor is understood to be the
% maximal number of point to take into account in the fit. By
% default, it is set to 0.25.

if nargin < 2
    clip_factor = 0.25;
end

if ~obj.msd_valid
    obj = obj.computeMSD;
end
n_spots = numel(obj.msd);

if clip_factor < 1
    fprintf('Fitting %d curves of log(MSD) = f(log(t)), taking only the first %d%% of each curve... ',...
        n_spots, ceil(100 * clip_factor) )
else
    fprintf('Fitting %d curves of log(MSD) = f(log(t)), taking only the first %d points of each curve... ',...
        n_spots, round(clip_factor) )
end

alpha = NaN(n_spots, 1);
gamma = NaN(n_spots, 1);
r2fit = NaN(n_spots, 1);
ft = fittype('poly1');

fprintf('%4d/%4d', 0, n_spots);
for i_spot = 1 : n_spots
    
    fprintf('\b\b\b\b\b\b\b\b\b%4d/%4d', i_spot, n_spots);
    
    msd_spot = obj.msd{i_spot};
    
    t = msd_spot(:,1);
    y = msd_spot(:,2);
    w = msd_spot(:,4);
    
    % Clip data
    if clip_factor < 1
        t_limit = 2 : round(numel(t) * clip_factor);
    else
        t_limit = 2 : min(1+round(clip_factor), numel(t));
    end
    t = t(t_limit);
    y = y(t_limit);
    w = w(t_limit);
    
    % Thrash bad data
    nonnan = ~isnan(y);
    
    t = t(nonnan);
    y = y(nonnan);
    w = w(nonnan);
    
    if numel(y) < 2
        continue
    end
    
    xl = log(t);
    yl = log(y);
    
    bad_log =  isinf(xl) | isinf(yl);
    xl(bad_log) = [];
    yl(bad_log) = [];
    w(bad_log) = [];
    
    if numel(xl) < 2
        continue
    end
    
    [fo, gof] = fit(xl, yl, ft, 'Weights', w);
    
    alpha(i_spot) = fo.p1;
    gamma(i_spot) = exp(fo.p2);
    r2fit(i_spot) = gof.adjrsquare;
    
end
fprintf('\b\b\b\b\b\b\b\b\bDone.\n')

obj.loglogfit = struct(...
    'alpha', alpha, ...
    'gamma', gamma, ...
    'r2fit', r2fit);

end