function PH_ExportClusters(hMain,varargin)
	%PH_SaveProbeFile Save probe file
	%   PH_SaveProbeFile(hMain)
	
	%get data
	sGUI = guidata(hMain);
	
	% Export the probe coordinates to the workspace & save to file
	sProbeCoords = sGUI.sProbeCoords;
	
	%add depth
	dblCurrentProbeLength = sProbeCoords.sProbeAdjusted.probe_vector_sph(end);
	if isfield(sGUI.sClusters,'Clust')
		dblRescaling = (dblCurrentProbeLength / sGUI.sProbeCoords.ProbeLengthOriginal);
		sProbeCoords.sProbeAdjusted.cluster_id = [sGUI.sClusters.Clust.cluster_id];
		sProbeCoords.sProbeAdjusted.depth_per_cluster = [sGUI.sClusters.Clust.Depth] .* dblRescaling;
	else
		sProbeCoords.sProbeAdjusted.cluster_id = [];
		sProbeCoords.sProbeAdjusted.depth_per_cluster = [];
	end
	
	sClusters = sGUI.sClusters;
	if isempty(sClusters)
		%disable buttons
		set(sGUI.handles.ptrButtonLoadZeta,'Enable','off');
		set(sGUI.handles.ptrButtonLoadTsv,'Enable','off');
		set(sGUI.handles.ptrButtonPlotProp,'Enable','off');
		set(sGUI.handles.ptrButtonCategProp,'Enable','off');
		set(sGUI.handles.ptrButtonShowCateg,'Enable','off');
		set(sGUI.handles.ptrButtonExportEphys,'Enable','off');
		return;
	end
	%save
	strName = getDate();
	strClusterOut = strcat(strName,'_UPF_Cluster.mat');
	[strFile,strPath,boolAccept] = uiputfile(strClusterOut,'Save ephys data as');
	if ~isempty(strFile) && ~isempty(strPath) && boolAccept ~= 0
		hMsg=msgbox('Exporting ephys data...','Saving');
		save(fullpath(strPath,strFile),'sClusters','sProbeCoords');
		delete(hMsg);
	end
end

