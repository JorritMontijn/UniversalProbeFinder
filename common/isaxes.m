function tf = isaxes(h)
	tf = (isgraphics(h,'axes') | isgraphics(h,'polaraxes')) & (verLessThan('matlab','8.4') | ~isa(h,'double'));
end