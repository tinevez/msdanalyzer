function varargout = plotDrift(obj, ha)
%%PLOTDRIFT Plot drift stored in this object.
%
% obj.plotDrift plots the calculated drift position in the
% current axes.
%
% obj.plotDrift(ha) plots the drift position in the axes
% specified by the handle ha.
%
% hp = obj.plotDrift(...) returns the plot handle for the
% created line.
%
% [hp, ha] = obj.plotDrift(...) also returns the axes handle.

if obj.n_dim < 2 || obj.n_dim > 3
    error('msdanalyzer:plotDrift:UnsupportedDimensionality', ...
        'Can only plot drift for 2D or 3D problems, got %dD.', obj.n_dim);
end

if isempty(obj.drift)
    if nargout > 0
        varargout{1} = [];
        if nargout > 1
            varargout{2} = [];
        end
    end
    return
end

if nargin < 2
    ha = gca;
end

if obj.n_dim == 2
    hp = plot(ha, obj.drift(:,2), obj.drift(:,3), 'k-', ...
        'LineWidth', 2);
else
    hp = plot3(ha, obj.drift(:,2), obj.drift(:,3), obj.drift(:,4), 'k-', ...
        'LineWidth', 2);
end

if nargout > 0
    varargout{1} = hp;
    if nargout > 1
        varargout{2} = ha;
    end
end

end