function PH_LoadZetaFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%select
	sZetaResp = PH_OpenZeta(sGUI.sClusters,cd());
	
	if ~isempty(sZetaResp)
		%save
		sClusters = sGUI.sClusters;
		sClusters.vecDepth = sZetaResp.vecDepth;
		sClusters.vecZeta = norminv(1-(sZetaResp.vecZetaP/2));
		sClusters.strZetaTit = 'ZETA (z-score)';
		
		%update gui data
		sGUI.sClusters = sClusters;
		guidata(hObject,sGUI);
		
		%plot new data
		PH_PlotProbeEphys(sGUI.handles.probe_zeta,sGUI.handles.probe_xcorr,sGUI.handles.probe_xcorr_im,sGUI.handles.probe_clust,sClusters);
	end
end