function cellCategories = PH_GetClusterCategories(hObject,eventdata)
	%PH_GetClusterCategories Retrieve cluster categories
	%   cellCategories = PH_GetClusterCategories(hMain,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%get selected property
	hShowCategProp = sGUI.handles.ptrButtonCategProp;
	strProperty = hShowCategProp.String{hShowCategProp.Value};
	
	%find property categories
	cellFields = fieldnames(sGUI.sClusters);
	strProperty = cellFields{contains(cellFields,strProperty)};
	cellPropertyData = sGUI.sClusters.(strProperty);
	cellCategories = {'all'};
	cellUnique = unique(cellPropertyData);
	if numel(cellUnique) <= 10
		cellCategories = cat(1,cellCategories,cellUnique(:));
	end
end

