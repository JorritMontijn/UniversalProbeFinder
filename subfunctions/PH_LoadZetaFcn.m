function PH_LoadZetaFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%select
	[sClusters,boolSuccess] = PH_OpenZeta(sGUI.sClusters,cd());
	
	if boolSuccess
		%update gui data
		sGUI.sClusters = sClusters;
		guidata(hObject,sGUI);
		
		%plot new data
		PH_PlotProbeEphys(hObject,sClusters);
		
		%update plots
		PH_UpdateProbeCoordinates(hObject,PH_CartVec2SphVec(PH_GetProbeVector(hObject)));
	end
end