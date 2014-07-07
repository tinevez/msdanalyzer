function varargout = labelPlotTracks(obj, ha)
%%LABELPLOTTRACKS A convenience method to set the axes labels.
%
% obj.labelPlotTracks(ha) sets the axis label of the axes with
% the specified handle ha. It is meant for axes containing the
% plot of the particles trajectories and their drift.
%
% hl = obj.plotTracks(...) returns the handle to the generated
% labels.

if obj.n_dim < 2 || obj.n_dim > 3
    error('msdanalyzer:labelPlotTracks:UnsupportedDimensionality', ...
        'Can only label axis for 2D or 3D problems, got %dD.', obj.n_dim);
end

if nargin < 2
    ha = gca;
end

hl = NaN(obj.n_dim, 1);
hl(1) = xlabel(ha, ['X (' obj.space_units ')'] );
hl(2) = ylabel(ha, ['Y (' obj.space_units ')'] );
if obj.n_dim ==3
    hl(3) = zlabel(ha, ['Z (' obj.space_units ')'] );
end
axis equal
if nargout > 0
    varargout{1} = hl;
end
end