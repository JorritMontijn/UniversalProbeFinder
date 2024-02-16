function PH_LoadTsvFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%select folder
	strText = 'Select .tsv file(s)';
	if ismac; msgbox(strText,'OK');end
	[cellTsvFiles,strTsvPath] = uigetfile(cd(),strText,'MultiSelect','on');
	if isempty(cellTsvFiles) || cellTsvFiles(1) == 0,return;end
	
	%transform to struct
	sTsvs = struct;
	for intFile=1:numel(cellTsvFiles)
		sTsvs(intFile).folder = strTsvPath;
		sTsvs(intFile).name = cellTsvFiles{intFile};
	end
	
	%loads tsvs
	sClustTsv = loadClusterTsvs(sTsvs);
	vecClustIdx = sClustTsv.cluster_id;
	
	%add aditional cluster data
	cellAllFields = sClustTsv.sCluster;
	for intField=1:numel(cellAllFields)
		strField = cellAllFields{intField};
		if ~ismember(strField,cellUsedFields)
			cellData = {sSynthData.sCluster.(strField)};
			if isnumeric(cellData{1})
				cellData = cell2vec(cellData);
			end
			sClusters.(strField) = cellData;
		end
	end
	
	%assign eligible properties to list
	
	if ~isempty(sZetaResp) && isfield(sZetaResp,'vecDepth')
		%save
		sClusters = sGUI.sClusters;
		sClusters.vecDepth = sZetaResp.vecDepth;
		sClusters.vecZeta = norminv(1-(sZetaResp.vecZetaP/2));
		sClusters.strZetaTit = 'Responsiveness ZETA (z-score)';
		
		%update gui data
		sGUI.sClusters = sClusters;
		guidata(hObject,sGUI);
		
		%plot new data
		PH_PlotProbeEphys(hObject,sClusters);
		
		%update plots
		PH_UpdateProbeCoordinates(hObject,PH_CartVec2SphVec(PH_GetProbeVector(hObject)));
	end
end