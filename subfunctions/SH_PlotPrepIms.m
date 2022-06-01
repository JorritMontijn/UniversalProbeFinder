function SH_PlotPrepIms(hMain,varargin)
	%SH_PlotPrepIms Summary of this function goes here
	
	%get data
	sGUI = guidata(hMain);
	sSliceData = sGUI.sSliceData;
	vecPlotAx = sGUI.handles.vecHeaderAxes;
	
	%reset ongoing data
	SH_ClearClick(hMain);
	
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
			hIm=imshow(imPlot,'Parent',vecPlotAx(intMakePlot));
			hIm.ButtonDownFcn = {@SH_HeaderClick,intPlotSlice};
		end
	end
	
	%show main image
	cla(sGUI.handles.hAxSlice);
	sGUI.handles.hIm = imshow(sSliceData.Slice(sGUI.intCurrIm).ImTransformed,'Parent',sGUI.handles.hAxSlice);
	sGUI.handles.hIm.ButtonDownFcn = @SH_SliceClick;
	
	%create dummy plots
	vecClickColor = [0.6350 0.0780 0.1840];
	sGUI.handles.hLastClick = scatter(sGUI.handles.hAxSlice,0,0,50,vecClickColor,'x','linewidth',1);
	sGUI.handles.hLastClick.Visible = 'off';
	sGUI.handles.hTempLine = line(sGUI.handles.hAxSlice,[0 0],[0 0],'color',vecClickColor,'linewidth',1);
	sGUI.handles.hTempLine.Visible = 'off';
	
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
			line(sGUI.handles.hAxSlice,[matVec(1,1) matVec(2,1)],[matVec(1,2) matVec(2,2)],... %[x1 y1; x2 y2]
			'color',vecColor,'LineWidth',1.5); %track #k
		sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hScatter = ...
			scatter(sGUI.handles.hAxSlice,[matVec(1,1) matVec(2,1)],[matVec(1,2) matVec(2,2)],...
			20,vecColor,'LineWidth',1.5,'Marker',strMarker); %track #k
		
		%add deletion context menu
		hMenu = uicontextmenu(sGUI.handles.hMain);
		m1 = uimenu(hMenu,'Label','Delete','Callback',{@SH_DeleteTrackVector,sGUI.sSliceData.Slice(intIm).TrackClick(intClick).hLine});
		sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).hLine.UIContextMenu = hMenu;
		sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).hScatter.UIContextMenu = hMenu;
	end
	
	%update text
	SH_SelectTrack(hMain);
	
	%update data
	guidata(hMain,sGUI);
	
end

