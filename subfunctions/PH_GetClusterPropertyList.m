function cellProps = PH_GetClusterPropertyList(hMain,eventdata)
	%UNTITLED Summary of this function goes here
	%   Detailed explanation goes here
	
	% Get guidata
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	hMain=sGUI.handles.hMain;
	
	% find eligible properties
	cellIgnoreProperties = {};
	cellAllProperties = fieldnames(sGUI.sClusters);
	
	
end

