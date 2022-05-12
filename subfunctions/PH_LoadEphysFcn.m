function PH_LoadEphysFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%select
	sClusters = PH_OpenEphys();
	
	if ~isempty(sClusters)
		%update gui data
		sGUI.sClusters = sClusters;
		guidata(hObject,sGUI);
		
		%plot new data
		PH_PlotProbeEphys(sGUI.handles.probe_zeta,sGUI.handles.probe_xcorr,sGUI.handles.probe_xcorr_im,sGUI.handles.probe_clust,sClusters);
	end
end