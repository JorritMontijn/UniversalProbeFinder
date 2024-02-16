function cellCategories = PH_GetClusterCategories(hMain,eventdata)
	%PH_GetClusterCategories Retrieve cluster categories
	%   cellCategories = PH_GetClusterCategories(hMain,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	hMain=sGUI.handles.hMain;
	
	%get selected property
	hShowClustProp = sGUI.handles.ptrButtonClustProp;
	strProperty = hShowClustProp.String{hShowClustProp.Value};
	
	%find property categories
	cellPropertyData = sGUI.sClusters.(strProperty);
	cellCategories = {'all'};
	cellUnique = unique(cellPropertyData);
	if numel(cellUnique) <= 10
		cellCategories = cat(1,cellCategories,cellUnique(:));
	end
end

