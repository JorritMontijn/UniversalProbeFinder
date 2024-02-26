function PH_DisableButtons(hObject,varargin)
	%PH_DisableButtons Summary of this function goes here
	%   PH_DisableButtons(hObject,varargin)
	
	%get data
	sGUI = guidata(hObject);
	sGUI = guidata(sGUI.handles.hMain);
	
	%disable buttons
	set(sGUI.handles.ptrButtonLoadZeta,'Enable','off');
	set(sGUI.handles.ptrButtonLoadTsv,'Enable','off');
	set(sGUI.handles.ptrButtonPlotProp,'Enable','off');
	set(sGUI.handles.ptrButtonCategProp,'Enable','off');
	set(sGUI.handles.ptrButtonShowCateg,'Enable','off');
	set(sGUI.handles.ptrButtonExportEphys,'Enable','off');
	set(sGUI.handles.ptrButtonDiscardOtherCateg,'Enable','off');
	set(sGUI.handles.ptrButtonUndoDiscard,'Enable','off');
	
end

