function jFig = maxfig(ptrHandle,dblRescaleHeight,dblRescaleWidth)
	%maxfig Maximizes figure. Syntax:
	%   jFig = maxfig(ptrHandle,dblRescaleHeight,dblRescaleWidth)
	
	%get handle
	if ~exist('ptrHandle','var') || isempty(ptrHandle)
		ptrHandle = gcf;
	end
	if ~exist('dblRescaleHeight','var') || isempty(dblRescaleHeight)
		dblRescaleHeight = 1;
	end
	if ~exist('dblRescaleWidth','var') || isempty(dblRescaleWidth)
		dblRescaleWidth = 1;
	end
	
	%maximize
	try
		%try new method
		h = handle(ptrHandle);
		h.WindowState = 'maximized';
	catch
		%try old method with javaframe
		sWarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
		drawnow;
		jFig = get(handle(ptrHandle), 'JavaFrame');
		jFig.setMaximized(true);
		drawnow;
		warning(sWarn);
	end
	
	%adjust distances
	if dblRescaleHeight ~= 1 || dblRescaleWidth ~= 1
		vecAxes = ptrHandle.Children;
		intNumAxes = numel(vecAxes);
		matPos = nan(intNumAxes,4);
		for intAx=1:numel(vecAxes)
			matPos(intAx,:) = get(vecAxes(intAx),'Position');
			set(vecAxes(intAx),'Position',[matPos(intAx,1:2) dblRescaleWidth*matPos(intAx,3) dblRescaleHeight*matPos(intAx,4)]);
		end
	end
	drawnow;
end

