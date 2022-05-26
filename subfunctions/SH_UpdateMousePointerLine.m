function SH_UpdateMousePointerLine(hObject,eventdata)
	%UNTITLED2 Summary of this function goes here
	%   Detailed explanation goes here
	
	%get data
	sGUI = guidata(hObject);
	if toc(sGUI.LastUpdate) < (1/30)
		return;
	end
	sGUI.LastUpdate = tic;
	
	%get location on axis
	hAxSlice = sGUI.handles.hAxSlice;
	vecCurrPoint2 = hAxSlice.CurrentPoint(1,1:2);
	
	%limit to axes limits
	dblX = max([min(hAxSlice.XLim) min([max(hAxSlice.XLim) vecCurrPoint2(1)])]);
	dblY = max([min(hAxSlice.YLim) min([max(hAxSlice.YLim) vecCurrPoint2(2)])]);
	
	%plot
	sGUI.handles.hTempLine.XData(2) = dblX;
	sGUI.handles.hTempLine.YData(2) = dblY;
	
	%update data
	guidata(hObject,sGUI);
end

