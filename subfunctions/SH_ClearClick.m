function SH_ClearClick(hObject)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	%get data
	sGUI = guidata(hObject);
	
	%disable callback
	sGUI.handles.hMain.WindowButtonMotionFcn = [];
	
	%reset
	sGUI.LastClickLoc = [nan nan];
	sGUI.LastClickType = '';
	if ishandle(sGUI.handles.hLastClick)
		sGUI.handles.hLastClick.Visible = 'off';
	end
	if ishandle(sGUI.handles.hTempLine)
		sGUI.handles.hTempLine.Visible = 'off';
	end
	%update
	guidata(hObject,sGUI);
	
end

