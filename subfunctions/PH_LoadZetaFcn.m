function PH_LoadZetaFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%select
	sZetaResp = PH_OpenZeta(sGUI.sClusters,cd());
	
	if ~isempty(sZetaResp) && isfield(sZetaResp,'vecDepth')
		%save
		sClusters = sGUI.sClusters;
		sClusters.vecDepth = sZetaResp.vecDepth;
		sClusters.vecZeta = norminv(1-(sZetaResp.vecZetaP/2));
		sClusters.strZetaTit = 'ZETA (z-score)';
		
		%update gui data
		sGUI.sClusters = sClusters;
		guidata(hObject,sGUI);
		
		%plot new data
		PH_PlotProbeEphys(hObject,sClusters);
	end
end