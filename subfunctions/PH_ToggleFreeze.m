function PH_ToggleFreeze(hButton,varargin)
	
	%get data
	sGUI = guidata(hButton);
	hMain = sGUI.handles.hMain;
	
	%get toggle
	h = rotate3d(sGUI.handles.axes_atlas);
	if strcmp(h.Enable,'off')
		h.Enable = 'on';
		h.ActionPostCallback = @PH_UpdateSlice;
		%(need to restore key-press functionality with rotation)
		hManager = uigetmodemanager(hMain);
		[hManager.WindowListenerHandles.Enabled] = deal(false);
		set(hMain,'KeyPressFcn',@PH_KeyPress);
		sGUI.handles.ptrButtonFreeze.Value = 0;
	elseif strcmp(h.Enable,'on')
		h.Enable = 'off';
		sGUI.handles.ptrButtonFreeze.Value = 1;
	end
	
end