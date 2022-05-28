function SF_PlotIms(hMain,varargin)
	%SH_PlotPrepIms plot header+current slice and update slice in atlas + redraw atlas on slice

	%get data
	sGUI = guidata(hMain);
	sSliceData = sGUI.sSliceData;
	vecPlotAx = sGUI.handles.vecHeaderAxes;
	
	%message
	sGUI.handles.ptrTextMessages.String = 'Working...';drawnow;
	
	%plot header images
	intCurrSlice = sGUI.intCurrIm;
	vecPlotPos=1:numel(vecPlotAx);
	vecShowSlices = (intCurrSlice-3):(intCurrSlice+3);
	for intMakePlot=vecPlotPos
		%plot image
		intPlotSlice = vecShowSlices(intMakePlot);
		if intPlotSlice < 1 || intPlotSlice > numel(sSliceData.Slice)
			cla(vecPlotAx(intMakePlot));
		else
			imPlot = sSliceData.Slice(intPlotSlice).ImTransformed;
			imshow(imPlot,'Parent',vecPlotAx(intMakePlot));
			setAllowAxesRotate(rotate3d(vecPlotAx(intMakePlot)),vecPlotAx(intMakePlot),0);
		end
	end
	
	%show main image
	cla(sGUI.handles.hAxSlice);
	intMaxY = size(sSliceData.Slice(sGUI.intCurrIm).ImTransformed,1);
	[matY,matX]=meshgrid(intMaxY:-1:1,1:size(sSliceData.Slice(sGUI.intCurrIm).ImTransformed,2));
	C = double(sSliceData.Slice(sGUI.intCurrIm).ImTransformed)./255;
	sGUI.handles.hIm = surface(sGUI.handles.hAxSlice,matX',matY',ones(size(matY')),C,...
		'edgecolor','none','linestyle','none');
	xlim(sGUI.handles.hAxSlice,[min(matX(:)) max(matX(:))]);
	ylim(sGUI.handles.hAxSlice,[min(matY(:)) max(matY(:))]);
	sGUI.SliceX = xlim(sGUI.handles.hAxSlice);
	sGUI.SliceY = ylim(sGUI.handles.hAxSlice);
	
	%update info bar
	sGUI.handles.ptrTextInfo.String = sprintf('Image %d/%d: %s',intCurrSlice,numel(sSliceData.Slice),sSliceData.Slice(intCurrSlice).ImageName);
	
	%plot tracks
	intIm = sGUI.intCurrIm;
	intClickNum = numel(sGUI.sSliceData.Slice(intIm).TrackClick);
	for intClick=1:intClickNum
		%get data
		intTrack = sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Track;
		matVec = sGUI.sSliceData.Slice(intIm).TrackClick(intClick).Vec;
		strMarker = sGUI.sSliceData.Track(intTrack).marker;
		vecColor = sGUI.sSliceData.Track(intTrack).color;
		
		%plot[x1 y1; x2 y2]
		sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine = ...
			line(sGUI.handles.hAxSlice,[matVec(1,1) matVec(2,1)],intMaxY-[matVec(1,2) matVec(2,2)],[1 1],... %[x1 y1; x2 y2]
			'color',vecColor,'LineWidth',1.5); %track #k
		sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hScatter = ...
			scatter3(sGUI.handles.hAxSlice,[matVec(1,1) matVec(2,1)],intMaxY-[matVec(1,2) matVec(2,2)],[1 1],...
			20,vecColor,'LineWidth',1.5,'Marker',strMarker); %track #k
		
		%add deletion context menu
		%hMenu = uicontextmenu;
		%m1 = uimenu(hMenu,'Label','Delete','Callback',{@SH_DeleteTrackVector,sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine});
		%sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).hLine.UIContextMenu = hMenu;
		%sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).hScatter.UIContextMenu = hMenu;
	end
	
	%disable interactions
	setAllowAxesRotate(rotate3d(sGUI.handles.hAxSlice),sGUI.handles.hAxSlice,0);
	
	%update data
	guidata(hMain,sGUI);
	
	%plot slice in atlas
	SF_PlotSliceInAtlas(hMain);
end