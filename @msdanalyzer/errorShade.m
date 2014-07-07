function H = errorShade(ha, x, y, errBar, col, transparent)
% Adapted from Rob Campbell code, at:
% http://www.mathworks.com/matlabcentral/fileexchange/26311-shadederrorbar/content/shadedErrorBar.m
hold on
H.mainLine = plot(ha, x, y, 'Color', col);

edgeColor = col + (1-col) * 0.55;
patchSaturation = 0.15; %How de-saturated or transparent to make the patch
if transparent
    faceAlpha=patchSaturation;
    patchColor=col;
    set(gcf,'renderer','openGL')
else
    faceAlpha=1;
    patchColor=col+(1-col)*(1-patchSaturation);
    set(gcf,'renderer','painters')
end

%Calculate the y values at which we will place the error bars
uE = y + errBar;
lE = y - errBar;

%Make the cordinats for the patch
yP = [ lE ; flipud(uE) ];
xP = [ x ; flipud(x) ];

invalid = isnan(xP) | isnan(yP) | isinf(xP) | isinf(yP);
yP(invalid) = [];
xP(invalid) = [];


H.patch = patch(xP, yP, 1, ...
    'Facecolor', patchColor,...
    'Edgecolor', 'none',...
    'Facealpha', faceAlpha, ...
    'Parent', ha);

%Make nice edges around the patch.
H.edge(1) = plot(ha, x, lE, '-', 'Color', edgeColor);
H.edge(2) = plot(ha, x, uE, '-', 'Color', edgeColor);

%The main line is now covered by the patch object and was plotted first to
%extract the RGB value of the main plot line. I am not aware of an easy way
%to change the order of plot elements on the graph so we'll just remove it
%and put it back (yuk!)
delete(H.mainLine)
H.mainLine = plot(ha, x, y, 'Color', col);
end