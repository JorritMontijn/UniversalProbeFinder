function PH_LoadZetaFcn(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	
	%add aditional cluster data
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
	
	%select
	[sClusters,boolSuccess] = PH_OpenZeta(sClusters,cd());
	
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