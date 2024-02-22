function cellCategories = PH_GetClusterCategories(hObject,eventdata)
	%PH_GetClusterCategories Retrieve cluster categories
	%   cellCategories = PH_GetClusterCategories(hMain,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%get selected property
	hShowCategProp = sGUI.handles.ptrButtonCategProp;
	if isempty(hShowCategProp.String) || isempty(sGUI.sClusters)
		cellCategories = {''};
		return;
	end
	
	%find property categories
	strFindField = hShowCategProp.String{hShowCategProp.Value};
	strFullField = PH_GetClusterField(sGUI.sClusters.Clust,strFindField);
	cellPropertyData = {sGUI.sClusters.Clust.(strFullField)};
	indIsnumeric = cellfun(@(x) isnumeric(x) | islogical(x),cellPropertyData);
	cellStrData = cellPropertyData;
	cellStrData(indIsnumeric) = cellfun(@num2str,cellPropertyData(indIsnumeric),'UniformOutput',false);
	cellCategories = {'all'};
	cellUnique = unique(cellStrData);
	if numel(cellUnique) <= 10
		cellCategories = cat(1,cellCategories,cellUnique(:));
	end
end

