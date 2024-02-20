function cellProps = PH_GetClusterPropertyList(hObject,eventdata)
	%PH_GetClusterPropertyList Retrieve cluster property list
	%   cellProps = PH_GetClusterPropertyList(hObject,eventdata)
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%remove prefixes
	if ~isstruct(sGUI.sClusters),cellProps={};return;end
	cellAllProperties = fieldnames(sGUI.sClusters.Clust);
	cellAllProperties = PH_RemPrefixes(cellAllProperties);

	% find eligible properties
	cellIgnoreProperties = {'ChanIdx','ChanPos','ProbeMatrixTitle','ProbeMatrixDepths','ProbeMatrix','ProbeLength','UseClusters',...
		'cluster_id','OrigIdx','Depth','SpikeTimes'};
	indRemFields = ismember(cellAllProperties,cellIgnoreProperties);
	cellProps = cellAllProperties(~indRemFields);
end

