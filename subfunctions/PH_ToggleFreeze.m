function PH_ToggleFreeze(hButton,varargin)
	
	%get data
	sGUI = guidata(hButton);
	hMain = sGUI.handles.hMain;
	
	%get toggle
	h = rotate3d(sGUI.handles.axes_atlas);
	if sGUI.handles.ptrButtonFreeze.Value == 0
		%enable redrawing
		h.ActionPostCallback = @PH_UpdateSlice;
		%trigger redraw
		PH_UpdateSlice(hMain);
	elseif sGUI.handles.ptrButtonFreeze.Value == 1
		%disable redrawing
		h.ActionPostCallback = [];
	end
end