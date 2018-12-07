function obj = fitLogLogMSD(obj, clip_factor, silent, fitError, tE)
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
% silent: do not print progress.
% fitError: if 0, fit line, if 1, take into account dynamic error, if 2,
% take into account static error, if 3, take into account both

if nargin < 2
    clip_factor = 0.25;
end
if nargin<3
    silent=false;
end
if nargin<4
    fitError=0;
    tE=1;
end
if ~obj.msd_valid
    obj = obj.computeMSD;
end
n_spots = numel(obj.msd);

if ~silent
    if clip_factor < 1
        fprintf('Fitting %d curves of log(MSD) = f(log(t)), taking only the first %d%% of each curve... ',...
            n_spots, ceil(100 * clip_factor) )
    else
        fprintf('Fitting %d curves of log(MSD) = f(log(t)), taking only the first %d points of each curve... ',...
            n_spots, round(clip_factor) )
    end
end

alpha = NaN(n_spots, 1);
gamma = NaN(n_spots, 1);
if fitError>1, sigma = NaN(n_spots, 1); end
r2fit = NaN(n_spots, 1);
ft = fittype('poly1');

if ~silent
    fprintf('%4d/%4d', 0, n_spots);
end
msd=obj.msd;
parfor i_spot = 1 : n_spots
    if ~silent
        fprintf('\b\b\b\b\b\b\b\b\b%4d/%4d', i_spot, n_spots);
    end
    
    msd_spot = msd{i_spot};
    
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
    if fitError
        try
            [p,resnorm] = fitMSDlogAlphaError(t,y,tE,fitError);
        catch
            p=nan(1,3); resnorm=nan;
        end
        alpha(i_spot) = p(2);
        gamma(i_spot) = 4*p(1); % gamma=4D % Consistent with line 119
        r2fit(i_spot) = resnorm;
        if fitError>1
            sigma(i_spot) = p(3);
        end
    else
        [fo, gof] = fit(xl, yl, ft, 'Weights', w);
        
        alpha(i_spot) = fo.p1;
        gamma(i_spot) = exp(fo.p2);
        r2fit(i_spot) = gof.adjrsquare;
    end
end
if ~silent
    fprintf('\b\b\b\b\b\b\b\b\bDone.\n')
end

obj.loglogfit = struct(...
    'alpha', alpha, ...
    'gamma', gamma, ...
    'r2fit', r2fit);
if fitError>1
    obj.loglogfit.sigma=sigma;
end
end

function [p,resnorm] = fitMSDlogAlphaError(t,msd,tE,fitError)
% Function to fit MSD to the function form Backlund et al., which takes
% into account super/subdiffusion (parameter alpha) and static and dynamic
% error. 
% INPUT:
% t:
% msd: 
% tE: exposure time
% OUTPUT: 
% formula: fitted function formula(p,t)
% (from lsqnonlin)
% p: fitted parameters: [D, alpha, s]
%   p(1), 'D': apparent diffusion coefficient
%   p(2), 'alpha': exponent
%   p(3), 's': localization error (standard deviation of position)
% resnorm,residual,exitflag,output: see documentation lsqnonlin

if ~exist('tE','var')
    tE=0.05;
end
% % p = [D, alpha, s]
% p = [D, alpha]
% To prevent t(1)<tE by a tiny amount, leading to imaginary solutions
% because of the term "(t-tE).^(p(2)+2)"
tE=tE-10^-16;

switch fitError
    case 1
        formula=@(p,t) 2*p(1)./((p(2)+2).*(p(2)+1).*tE.^2).*((t+tE).^(p(2)+2)+(t-tE).^(p(2)+2)-2*t.^(p(2)+2))-4.*p(1).*tE.^p(2)./((p(2)+2).*(p(2)+1)); %+2.*p(3).^2
    case 2
        formula=@(p,t) 2*p(1).*t.^p(2) +2.*p(3).^2;
    case 3
        formula=@(p,t) 2*p(1)./((p(2)+2).*(p(2)+1).*tE.^2).*((t+tE).^(p(2)+2)+(t-tE).^(p(2)+2)-2*t.^(p(2)+2))-4.*p(1).*tE.^p(2)./((p(2)+2).*(p(2)+1))+2.*p(3).^2;
    otherwise
        error('Invalid input for fitError, should be 1, 2 or 3')
end

fun = @(p)(log(msd)-log(formula(p,t))).^2;
fitopts.FunctionTolerance=10^-16;
fitopts.Display='off';
p0 = [1, 0.4, 0.02];
try
    [~,idx]=min(abs(t-1));
    p0(1)=msd(idx)/2;
catch
end
lb =  [0    , 0  , 0   ];
ub =  [10^10 , 2  , 0.1 ];
if fitError==1
    p0=p0(1:2);lb=lb(1:2);ub=ub(1:2);
end
[p,resnorm,~,~,~]= lsqnonlin(fun,p0,lb,ub,fitopts);

end
