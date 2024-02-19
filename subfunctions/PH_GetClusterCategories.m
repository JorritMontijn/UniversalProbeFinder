function cellCategories = PH_GetClusterCategories(hObject,eventdata)
	%PH_GetClusterCategories Retrieve cluster categories
	%   cellCategories = PH_GetClusterCategories(hMain,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%get selected property
	hShowCategProp = sGUI.handles.ptrButtonCategProp;
	if isempty(hShowCategProp.String)
		cellCategories = {};
		return;
	end
	
	%find property categories
	strFindField = hShowCategProp.String{hShowCategProp.Value};
	strFullField = PH_GetClusterField(sGUI.sClusters,strFindField);
	cellPropertyData = sGUI.sClusters.(strFullField);
	cellCategories = {'all'};
	cellUnique = unique(cellPropertyData);
	if numel(cellUnique) <= 10
		cellCategories = cat(1,cellCategories,cellUnique(:));
	end
end

