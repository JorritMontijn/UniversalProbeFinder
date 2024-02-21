function c = redblack(m)
	%REDBLACK    Shades of red and black color map
	%   REDBLACK(M), is an M-by-3 matrix that defines a colormap.
	%   The colors begin with bright red, then to black.
	%   REDBLACK, by itself, is the same length as the current figure's
	%   colormap. If no figure exists, MATLAB creates one.
	%
	%   For example, to reset the colormap of the current figure:
	%
	%             redblack(redblue)
	%
	%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG,
	%   COLORMAP, RGBPLOT.
	
	if nargin < 1, m = size(get(gcf,'colormap'),1); end
	
	r = linspace(1,0,m)';
	g = zeros(size(r));
	b = zeros(size(r));
	
	c = [r g b];
	
