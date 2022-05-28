function SH_SliceClick(hObject,eventdata)
	%SH_SliceClick Summary of this function goes here
	%   Detailed explanation goes here
	
	%get gui data
	sGUI = guidata(hObject);
	
	%check update
	if sGUI.IsBusy || toc(sGUI.LastUpdate) < 1/30
		return;
	else
		sGUI.LastUpdate = tic;
		sGUI.IsBusy = true;
	end
	%update guidata
	guidata(sGUI.handles.hMain,sGUI);
	
	%check if click right mouse
	if eventdata.Button == 3
		%cancel previous click
		SH_ClearClick(sGUI.handles.hMain);
		
		%release
		sGUI.IsBusy = false;
		guidata(sGUI.handles.hMain,sGUI);
		return;
	end
	
	%key:
	currKey=get(sGUI.handles.hMain, 'Currentkey');
	cellCurrModifiers=get(sGUI.handles.hMain, 'Currentmodifier');
	
	%check if click is second click
	if ~any(isnan(sGUI.LastClickLoc))
		%disable callback
		sGUI.handles.hMain.WindowButtonMotionFcn = [];
		
		%get previous click
		vecLastClickLoc = sGUI.LastClickLoc;
		strLastClickType = sGUI.LastClickType;
		
		%reset
		sGUI.LastClickLoc = [nan nan];
		sGUI.LastClickType = '';
		sGUI.handles.hLastClick.Visible = 'off';
		sGUI.handles.hTempLine.Visible = 'off';
		
		%update guidata
		guidata(sGUI.handles.hMain,sGUI);
		
		if strcmp(strLastClickType,'control')
			%calculate angle
			vecNewPoint = sGUI.handles.hAxSlice.CurrentPoint(1,1:2);
			dX = vecNewPoint(1) - vecLastClickLoc(1);
			dY = vecNewPoint(2) - vecLastClickLoc(2);
			[theta,rho] = cart2pol(dX,dY);
			
			%rotate image so midline is vertical
			imNew = sGUI.sSliceData.Slice(sGUI.intCurrIm).ImTransformed;
			intMaxSize = max(sGUI.sSliceData.Slice(sGUI.intCurrIm).ImageSize);
			imNew = imrotate(imNew,rad2deg(theta)-90,'bicubic','loose');
			
			%crop to max size
			dblMidX = (vecNewPoint(1) + vecLastClickLoc(1))/2;
			dblMidY = size(imNew,1)/2;
			
			vecRangeX = round(dblMidX) + ceil([1-intMaxSize/2 intMaxSize/2]);
			vecRangeY = round(dblMidY) + ceil([1-intMaxSize/2 intMaxSize/2]);
			intMinX = max(vecRangeX(1),1);
			intMaxX = min(vecRangeX(2),size(imNew,2));
			intMinY = max(vecRangeY(1),1);
			intMaxY = min(vecRangeY(2),size(imNew,1));
			
			%add x-offset
			sGUI.sSliceData.Slice(sGUI.intCurrIm).MidlineX = dblMidX;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).ImTransformed = imNew(intMinY:intMaxY,intMinX:intMaxX,:);
			
			%update guidata
			guidata(sGUI.handles.hMain,sGUI);
			
			%redraw
			SH_PlotPrepIms(sGUI.handles.hMain);
		elseif isempty(strLastClickType)
			%get active track
			intActiveTrack = sGUI.handles.ptrListSelectTrack.Value;
			if intActiveTrack > 0
				vecColor = sGUI.sSliceData.Track(intActiveTrack).color;
				strMarker = sGUI.sSliceData.Track(intActiveTrack).marker;
				
				%finish track
				vecNewPoint = sGUI.handles.hAxSlice.CurrentPoint(1,1:2);
				intNewClick = numel(sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick)+1;
				sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intNewClick).Vec = [vecLastClickLoc; vecNewPoint]; %[x1 y1; x2 y2] => normalized location in [0 1] range
				sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intNewClick).Track = intActiveTrack; %track #k
				sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intNewClick).hLine = ...
					line(sGUI.handles.hAxSlice,[vecLastClickLoc(1) vecNewPoint(1)],[vecLastClickLoc(2) vecNewPoint(2)],...
					'color',vecColor,'LineWidth',1.5); %track #k
				sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intNewClick).hScatter = ...
					scatter(sGUI.handles.hAxSlice,[vecLastClickLoc(1) vecNewPoint(1)],[vecLastClickLoc(2) vecNewPoint(2)],...
					20,vecColor,'LineWidth',1.5,'Marker',strMarker); %track #k
				
				%add deletion context menu
				hMenu = uicontextmenu;
				m1 = uimenu(hMenu,'Label','Delete','Callback',{@SH_DeleteTrackVector,sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intNewClick).hLine});
				sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intNewClick).hLine.UIContextMenu = hMenu;
				sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intNewClick).hScatter.UIContextMenu = hMenu;
				
				%update guidata
				guidata(sGUI.handles.hMain,sGUI);
			end
		end
	elseif ismember('control',cellCurrModifiers)
		%set midline color
		vecClickColor = [0.6350 0.0780 0.1840];
		
		%add first control click
		sGUI.handles.hLastClick.XData = eventdata.IntersectionPoint(1);
		sGUI.handles.hLastClick.YData = eventdata.IntersectionPoint(2);
		sGUI.handles.hLastClick.MarkerFaceColor = vecClickColor;
		sGUI.handles.hLastClick.Marker = 'x';
		sGUI.handles.hLastClick.LineWidth = 2;
		sGUI.handles.hLastClick.Visible = 'on';
		sGUI.LastClickLoc = eventdata.IntersectionPoint(1:2);
		sGUI.LastClickType = 'control';
		
		%draw line to mouse position
		sGUI.handles.hMain.WindowButtonMotionFcn = @SH_UpdateMousePointerLine;
		sGUI.handles.hTempLine.Color = vecClickColor;
		sGUI.handles.hTempLine.XData([1 2]) = eventdata.IntersectionPoint(1);
		sGUI.handles.hTempLine.YData([1 2]) = eventdata.IntersectionPoint(2);
		sGUI.handles.hTempLine.Visible = 'on';
		sGUI.handles.hTempLine.PickableParts = 'none';
		
		%update guidata
		guidata(sGUI.handles.hMain,sGUI);
		
	elseif isempty(cellCurrModifiers)
		%find active track
		intActiveTrack = sGUI.handles.ptrListSelectTrack.Value;
		if intActiveTrack > 0
			strName = sGUI.sSliceData.Track(intActiveTrack).name;
			strMarker = sGUI.sSliceData.Track(intActiveTrack).marker;
			vecColor = sGUI.sSliceData.Track(intActiveTrack).color;
			
			%normal first click
			sGUI.handles.hLastClick.MarkerFaceColor = vecColor;
			sGUI.handles.hLastClick.Marker = strMarker;
			sGUI.handles.hLastClick.LineWidth = 2;
			sGUI.handles.hLastClick.Visible = 'on';
			sGUI.LastClickLoc = eventdata.IntersectionPoint(1:2);
			sGUI.LastClickType = '';
			sGUI.LastUpdate = tic;
			
			%draw line to mouse position
			sGUI.handles.hMain.WindowButtonMotionFcn = @SH_UpdateMousePointerLine;
			sGUI.handles.hTempLine.Color = vecColor;
			sGUI.handles.hTempLine.XData([1 2]) = eventdata.IntersectionPoint(1);
			sGUI.handles.hTempLine.YData([1 2]) = eventdata.IntersectionPoint(2);
			sGUI.handles.hTempLine.Visible = 'on';
			sGUI.handles.hTempLine.PickableParts = 'none';
			
			%update guidata
			guidata(sGUI.handles.hMain,sGUI);
			
		end
	end
	
	%get gui data
	sGUI = guidata(sGUI.handles.hMain);
	
	%release
	sGUI.IsBusy = false;
	
	%update guidata
	guidata(sGUI.handles.hMain,sGUI);
end

