function PH_ToggleControl(hButton,varargin)
	
	%get data
	sGUI = guidata(hButton);
	
	%get toggle
	if sGUI.handles.ptrButtonRotate.Value == 0
		%enable redrawing
		hButton.String = 'Rotate';
		strEnable = 'on';
	elseif sGUI.handles.ptrButtonRotate.Value == 1
		%disable redrawing
		strEnable = 'off';
		hButton.String = 'Data tips';
	end
	
	%toggle rotation and enable key press listener
	h = rotate3d(sGUI.handles.axes_atlas);
	h.Enable = strEnable;
	hManager = uigetmodemanager(sGUI.handles.hMain);
	[hManager.WindowListenerHandles.Enabled] = deal(false);
	set(sGUI.handles.hMain,'KeyPressFcn',@PH_KeyPress);
end