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
		PH_PlotProbeEphys(hObject,sClusters);
	end
end