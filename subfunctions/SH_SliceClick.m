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
			dblRotDeg = rad2deg(theta)-90;
			imNew = sGUI.sSliceData.Slice(sGUI.intCurrIm).ImTransformed;
			
			%get new size
			imNew = imrotate(imNew,dblRotDeg,'bicubic','crop');
			dblMidX = size(imNew,2)/2;
			dblMidY = size(imNew,1)/2;
			
			%rotate trajectories
			intClickNum = numel(sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick);
			for intClick=1:intClickNum
				%rotate
				matVec = sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).Vec;
				[theta,rho]=cart2pol(matVec(:,1)-dblMidX,matVec(:,2)-dblMidY);
				[x,y]=pol2cart(theta-deg2rad(dblRotDeg),rho);
				matNewVec = [x+dblMidX y+dblMidY];
				
				%add track
				sGUI = SH_AddTrajectory(sGUI,sGUI.intCurrIm,intClick,sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick(intClick).Track,matNewVec);
			end
			
			%add x-offset
			sGUI.sSliceData.Slice(sGUI.intCurrIm).MidlineX = dblMidX;
			sGUI.sSliceData.Slice(sGUI.intCurrIm).ImTransformed = imNew;%(intMinY:intMaxY,intMinX:intMaxX,:);
			
			%update guidata
			guidata(sGUI.handles.hMain,sGUI);
			
			%redraw
			SH_PlotPrepIms(sGUI.handles.hMain);
		elseif isempty(strLastClickType)
			%get active track
			intActiveTrack = sGUI.handles.ptrListSelectTrack.Value;
			if intActiveTrack > 0
				
				%finish track
				vecNewPoint = sGUI.handles.hAxSlice.CurrentPoint(1,1:2);
				intNewClick = numel(sGUI.sSliceData.Slice(sGUI.intCurrIm).TrackClick)+1;
				
				%add track
				intIm = sGUI.intCurrIm;
				intClick = intNewClick;
				intTrack = intActiveTrack;
				matVec = [vecLastClickLoc; vecNewPoint];
				sGUI = SH_AddTrajectory(sGUI,intIm,intClick,intTrack,matVec);
				
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

