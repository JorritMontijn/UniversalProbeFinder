function PH_ToggleControl(hButton,varargin)
	
	%get data
	sGUI = guidata(hButton);
	
	%get toggle
	h = rotate3d(sGUI.handles.axes_atlas);
	if sGUI.handles.ptrButtonRotate.Value == 0
		%enable redrawing
		hButton.String = 'Rotate';
		h.Enable = 'on';
	elseif sGUI.handles.ptrButtonRotate.Value == 1
		%disable redrawing
		h.Enable = 'off';
		hButton.String = 'Data tips';
	end
end