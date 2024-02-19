function PH_LoadTsvFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%select folder
	strText = 'Select .tsv file(s)';
	if ismac; msgbox(strText,'OK');end
	[cellTsvFiles,strTsvPath] = uigetfile(fullpath(cd(),'*.tsv'),strText,'MultiSelect','on');
	if isempty(cellTsvFiles) || cellTsvFiles(1) == 0,return;end
	if ischar(cellTsvFiles),cellTsvFiles={cellTsvFiles};end
	
	%transform to struct
	sTsvs = struct;
	for intFile=1:numel(cellTsvFiles)
		sTsvs(intFile).folder = strTsvPath;
		sTsvs(intFile).name = cellTsvFiles{intFile};
	end
	
	%loads tsvs
	sClustTsv = loadClusterTsvs(sTsvs,false);
	vecClustIdx = sClustTsv.cluster_id;
	
	%add aditional cluster data
	sClusters = sGUI.sClusters;
	cellUsedFields = {'cluster_id','KSLabel','ContamPct'};
	cellAllFields = fieldnames(sClustTsv);
	for intField=1:numel(cellAllFields)
		strField = cellAllFields{intField};
		if ~ismember(strField,cellUsedFields)
			cellData = {sClustTsv.(strField)};
			if isnumeric(cellData{1})
				cellData = cell2vec(cellData);
			end
			sClusters.(strField) = cellData;
		end
	end
	
	%update gui data
	sGUI.sClusters = sClusters;
	guidata(hObject,sGUI);
	
	%plot new data
	PH_PlotProbeEphys(hObject,sClusters);
end