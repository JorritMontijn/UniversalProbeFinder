function boolClickCallback = SH_ButtonDownFilterFcn(hObject,objEvent)
	
	if isa(hObject,'matlab.ui.Figure')
		hAx = hObject.CurrentAxes;
	elseif isaxes(hObject)
		hAx = hObject;
	elseif isaxes(hObject.Parent)
		hAx = hObject.Parent;
	else
		hAx = [];
	end
	
	if ~isempty(hAx) && strcmp(hAx.Tag,'Rotate3D')
		boolClickCallback = false;
	else
		boolClickCallback = true;
	end
end